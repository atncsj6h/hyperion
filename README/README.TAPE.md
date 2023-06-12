![test image](images/image_header_herculeshyperionSDL.png)
[Return to master README.md](../README.md)

# Hercules Tape Support Enhancements SPE/Fixes

## Contents

1. [Version History](#Version-History)
2. [Basic ACF support](#Basic-ACF-support)
3. [Multivolume support](#Multivolume-support)
4. [Other changes and corrections](#Other-changes-and-corrections)
5. [AUTOMOUNT support](#AUTOMOUNT-support)

## Version History

    * V1.0  :  08 Mar 2003  :  ISW  :  Initial Release

## Supported Device Type emulations 
 
Device Types supported as of now:
  
* 3410/3411, 3420, 3480, 3490, 9347
  
Upcoming Device type support:
  
* 3422, 3424, 3490E, 3590, 3430, 8809  

## Basic ACF support

The ACF (Automatic Cartridge Feeder) is a feature on Cartridge type tape drives (3480, 3490, etc..) that automatically loads a new tape when a tape is removed from the drive. There is no real control over this device by the host, as it just keeps on feeding tapes one after the other. Although the ACF feature is unique to cartridge type systems, the emulation supports use of the same technique for emulated 1/2 inch tapes reel drives as well.

ACF is supported as follows:
 
Configuration file device statement syntax:

```
   CUU DEVT @filename <options..>
```

`devinit` command syntax:

```
   devinit CUU @filename <options..>
```

The `filename` (without the prefixing @) contains a list of files that will be loaded one after the other. The filenames contained in the file list cannot describe another ACF file nor an SCSI tape handle (`/dev/stX`). However, the files may be standard AWS, HET or OMA files.

To manually reset the ACF to the top of the stack, the `devinit` command can be used to "reload" the ACF feature.

If the filename in the ACF description file contains a `*` (asterisk), any option that follows the `*` is applied to each file, followed by the option(s) specified on the `devinit` command or configuration file device statement, followed by the option(s) specified on each individual entry.

Example:

hercules.cnf:

```
   180 3420 @newstack compress=1
```

File "newstack":

```
   * maxsizeM=16 eotmargin=131072
   tape01.aws compress=0
   tape02.het maxsizeM=32 eotmargin=65536
   tape03.het maxsize=0
```

This is equivalent to issuing (one at the start and one after each tape unload event):

```
   180 3420 tape01.aws maxsizeM=16 eotmargin=131072 compress=1 compress=0
   devinit 180 tape02.het maxsizeM=16 eotmargin=131072 compress=1 maxsizeM=32 eotmargin=65536
   devinit 180 tape03.het maxsizeM=16 eotmargin=131072 compress=1 maxsize=0
```

Options are processed in the order in which they appear.
Any conflicting parameter overrides the previous one.
For example, on the first entry, the resulting "compress" will be 0.

_**Care must be taken**_ to remember that all `*` lines are all processed at once, before other lines.
For example:

```
   * compress=0
   tape01.aws
   * compress=1
   tape02.aws
```

is equivalent to:

```
   * compress=0 compress=1
   tape01.aws
   tape02.aws
```

(Note: This may change in the future though, so ACF description files should not rely on this feature.)

## Multivolume support

* End of tape indication
* Tape file size limitation

Numerous requests have been made in order to support multi-volume tape handling, as well as limiting the file size generated by any individual tape file.

Because multivolume support is not necesserally VOL1/HDR1/EOV/EOF based, a certain number of new features have to be implemented in order to let the guest program manage the multivolume on it's own. (ex: VM/DDR, DOS Tape Spooled output, etc..)

Multivolume support resides in the capacity of a drive to indicate to the controling program that it is about to reach the end of the physical tape and that measures have to be taken to close the current volume and request a new media.

3 new options are introduced:


<pre>
<b>maxsize[K|M]=nnnn</b>:

        The resulting file size is limited to the amount specified. maxsize
        specifies bytes, <b>maxsizeK</b> specifies a multiple of 1024 bytes and
        <b>maxsizeM</b> specifies a multiple of 1024*1024 bytes. Specifying a size
        of 0 indicates that there is no limit on the size of the file.

        the default is 0 (unlimited file size)

<b>strictsize=0|1</b>:

        Upon reaching the tape file size limit, depending on strictsize,
        the tape file will or will not be truncated to enforce the maxsize
        limit. The limit is only enforced during a write type operation
        (that is, if the file already exists and the program only reads
        the file, then the file will NOT be truncated, regardless of the
        strictsize setting).
        
        This affects any write that starts BELOW the limit, but that would
        extend BEYOND the limit.
        
        This parameter only affects compress HET files. On AWS tapes, the
        limit is always enforced, but the file is not truncated (i.e. the
        write does not occur, because 1) AWS tapes are never truncated, 2)
        the effects of the write are known in advance (no compression)).
        Regardless of strictsize, any write operation (Write, Write TM)
        will return a Unit Check with Equip Check to the program if the file
        size exceeds the predefined limit. If strictsize is 0, the write will
        actually have been performed on the tape file. If strictsize is 1,
        the file will be truncated on the preceeding tape block boundary.
        If an attempt is made to write beyond the maxsize limit will result
        in an error.

        Care must be taken that regardless of the 'strictsize' setting,
        the tape may become unusable for the guest program should such an
        event occur (absence of a Tape Mark for example).

        This option has no effect if maxsize is 0
        This option only affects HET file tapes
        The default is 0 (do not truncate)

<b>eotmargin=nnnn</b>:

        This option specifies, in bytes, the threshold before reaching maxsize
        during which an indication will be returned to the program to indicate
        that an EOT marker has been reached for a write type operation.
        The indication of reaching near-capacity is indicated to the program
        by presenting Unit Exception in the CSW on a Write type operation,
        along with Channel End and Device End.
        
        For certain device types, sense information may also indicate this
        information independently of a write operation.
        
        The purpose of this option is to allow the program to determine that
        it is time to change to ask for a new tape. For example :

        maxsizeM=2 eotmargin=131072
        all writes up to 2Mb - 128Kb will occur normally
        All writes between 2Mb-128Kb and 2Mb will receive Unit Exception
        All writes beyond 2Mb will receive Unit Check

        This option has no effect if maxsize is 0
        The default is 131072 (128Kb)
</pre>

**Caveats:**
 
If the emulated tape file resides on a disk media that reaches full capacity before the tape image exceeds it's size limit, the tape emulation will not detect that situation and will simulate reaching physical end of tape _before_ reaching the EOT marker.
This behaviour may be changed at a later time.

## Other changes and corrections

### Device End Suppression for Tape motion CCWs on a non-ready tape drive

### Control Unit End is presented on Rewind Unload status

### Sense Pending status support

When certain conditions arise during an I/O operation, a sense is built and Unit Check is presented to the program.
The program is then responsible for retrieving the sense information.
However, if the sense is not the result of a previously occuring Unit Check, a new sense is built to reflect the current device status.
Also, this management is a necessary step in order to eventually implement multipath operations (Contengency Allegiance status).

### readonly=0|1 :

Using `readonly=1` forces an emulated tape device into read-only mode by emulating the removal of a 1/2 inch round reel tape's "write ring" or switching a 38k Cartridge's protect tab to "Read-Only", thereby protecting the data on the tape by preventing it from being written to. Using `readonly=0` disables the feature thus _allowing_ the tape to be written to.
(Note: support for this feature is still incomplete.)

## AUTOMOUNT support

Starting with Hercules version 3.06 a new `AUTOMOUNT` option is available that allows guest operating systems to directly mount, unmount and query tape device filenames for themselves, without any intervention on the part of the Hercules operator.

Automount support is enabled via the [`AUTOMOUNT`](https://sdl-hercules-390.github.io/html/hercconf.html#AUTOMOUNT) configuration file statement.

An example guest automount program for VSE called [`TMOUNT`](../util/TMOUNT.txt) is provided in the `util` subdirectory of the Hercules source code distribution.

Briefly, the 0x4B (Set Diagnose) CCW is used to mount (or unmount) a file onto a tape drive, and the 0xE4 (Sense Id) CCW opcode is used to query the name of the currently mounted file.

For mounts, the 0x4B CCW specifies the filename of the file to be mounted onto the drive. Furthermore, the file _must_ reside in one of the specified `AUTOMOUNT` directories or the request will be rejected. To unmount a file, simply do a mount of the special filename `OFFLINE`.

To query the name of the currently mounted file, the 0xE4 CCW is used. Note however that the 0xE4 (Sense Id) CCW opcode cannot be used by itself since the drive may already natively support the Sense Id CCW opcode. Instead, it _must_ be preceded by (command-chained from) a 0x4B CCW which specifies a data transfer length of exactly one byte. The 0xE4 CCW which follows it specifies the I/O buffer and buffer length of where the query function is to copy the device's currently mounted host filename into. If the 0x4B Set Diagnose CCW is not command chained, or if it is, if it does not specify a data-transfer length of exactly one byte, then it is not recognized as a Automount Query request and is instead treated as an Automount Mount/Dismount request.

As a result of this restriction, if the automount 0x4B Set Diagnose CCW is chained, the filename must be at least two bytes or longer. To mount a one byte filename the 0x4B Set Diagnose CCW _must not be chained:_


The following works okay:

```
      ONECHAR DC  C'Z'                    (one byte filename)

      CCW   X'4B',ONECHAR,X'20',L'ONECHAR        (automount)
```

The following works okay:

```
      MYFILE  DC  C'MYTAPE.AWS'             (normal filename)

      CCW   X'4B',MYFILE,X'20',L'MYFILE          (automount)
```

The following works okay:

```
      MYFILE  DC  C'MYTAPE.AWS'             (normal filename)
      VOL1LBL DC  CL80' '

      CCW   X'4B',MYFILE,X'60',L'MYFILE          (automount)
      CCW   X'07',*,X'60',1                      (rewind)
      CCW   X'02',VOL1LBL,X'60',L'VOL1LBL        (read VOL1)
      CCW   X'07',*,X'20',1                      (rewind)
```

The following will **FAIL**:

```
      ONECHAR DC  C'Z'                    (one byte filename)
      VOL1LBL DC  CL80' '

      CCW   X'4B',ONECHAR,X'60',L'ONECHAR        (automount)
      CCW   X'07',*,X'60',1                      (rewind)
      CCW   X'02',VOL1LBL,X'60',L'VOL1LBL        (read VOL1)
      CCW   X'07',*,X'20',1                      (rewind)
```


### Summary:


```
    MOUNT:      X'4B', <filename>, X'nn', <length>
                ...(other optional CCWS)...

    UNMOUNT:    (same thing but use filename "OFFLINE" instead)

    QUERY:      X'4B', <buffer>, X'nn', 1
                X'E4', <buffer>, X'nn', <buffersize>
                ...(other optional CCWS)...
```

Again, please refer to the provided [TMOUNT](../util/TMOUNT.txt) sample for a simple example.

-- Fish
28 May 2008
10 Jul 2011