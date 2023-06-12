/* CMPSCDBG.C   (C) Copyright "Fish" (David B. Trout), 2012-2014     */
/*              Compression Call Debugging Functions                 */
/*                                                                   */
/*   Released under "The Q Public License Version 1"                 */
/*   (http://www.hercules-390.org/herclic.html) as modifications to  */
/*   Hercules.                                                       */

#include "hstdinc.h"    // (MUST be first #include in EVERY source file)

#define _CMPSCDBG_C_
#define _HENGINE_DLL_

#if !defined( NOT_HERC )        // (building Hercules?)
#include "hercules.h"
#include "opcode.h"
#endif
#include "cmpsc.h"              // (Master header)

#ifdef FEATURE_CMPSC

///////////////////////////////////////////////////////////////////////////////
//
//  FILE: cmpscdbg.c
//
//      Compression Call debugging functions implementation
//
//  FUNCTIONS:
//
//      cmpsc_Report() - Formatted dump of internal structures
//
//  PARAMETERS:
//
//      dbg     Pointer to debugging context
//
//  RETURNS:
//
//      int     0 if success, errno on failure.
//
//  COMMENTS:
//
///////////////////////////////////////////////////////////////////////////////
/*

Formatted Compression Dictionary Entries:
(blank after every 16 lines)

HHHH CCE CCT=0 ACT=4 EC=HHHHHHHH "XXXX"
HHHH CCE CCT=1 X=1 ACT=4 CPTR=HHHH EC=HHHHHHHH "XXXX" CC=HH ' '
HHHH CCE CCT=5 X=11111 Y=11 D=1 CPTR=HHHH EC=HH ' ' CC=HH HH HH HH HH "XXXXX"
HHHH SD  SCT=7 Y=11111 SC=HH HH HH HH HH HH HH "XXXXXXX"
HHHH SD1 SCT=15 Y=111111111111 SC=HH HH HH HH HH HH "XXXXXX"

-------------------------------------------------------------------------------

Formatted Expansion Dictionary Entries:
(blank after every 16 lines)

HHHH ECE PSL=9 CSL=9 PPTR=HHHH EC=HHHHHHHHHH "XXXXX" OFST=HH
HHHH SD2 SC=HH HH HH HH HH HH HH HH "XXXXXXXX"

-------------------------------------------------------------------------------

Symbol Translation Table:
(blank after every 16 lines)

0000=HHHH 0010=HHHH 0020=HHHH 0030=HHHH 0040=HHHH 0050=HHHH 0060=HHHH 0070=HHHH
0001=HHHH 0011=HHHH 0021=HHHH 0031=HHHH 0041=HHHH 0051=HHHH 0061=HHHH 0071=HHHH
0002=HHHH 0012=HHHH 0022=HHHH 0032=HHHH 0042=HHHH 0052=HHHH 0062=HHHH 0072=HHHH
0003=HHHH 0013=HHHH 0023=HHHH 0033=HHHH 0043=HHHH 0053=HHHH 0063=HHHH 0073=HHHH
0004=HHHH 0014=HHHH 0024=HHHH 0034=HHHH 0044=HHHH 0054=HHHH 0064=HHHH 0074=HHHH
0005=HHHH 0015=HHHH 0025=HHHH 0035=HHHH 0045=HHHH 0055=HHHH 0065=HHHH 0075=HHHH
0006=HHHH 0016=HHHH 0026=HHHH 0036=HHHH 0046=HHHH 0056=HHHH 0066=HHHH 0076=HHHH
0007=HHHH 0017=HHHH 0027=HHHH 0037=HHHH 0047=HHHH 0057=HHHH 0067=HHHH 0077=HHHH
0008=HHHH 0018=HHHH 0028=HHHH 0038=HHHH 0048=HHHH 0058=HHHH 0068=HHHH 0078=HHHH
0009=HHHH 0019=HHHH 0029=HHHH 0039=HHHH 0049=HHHH 0059=HHHH 0069=HHHH 0079=HHHH
000A=HHHH 001A=HHHH 002A=HHHH 003A=HHHH 004A=HHHH 005A=HHHH 006A=HHHH 007A=HHHH
000B=HHHH 001B=HHHH 002B=HHHH 003B=HHHH 004B=HHHH 005B=HHHH 006B=HHHH 007B=HHHH
000C=HHHH 001C=HHHH 002C=HHHH 003C=HHHH 004C=HHHH 005C=HHHH 006C=HHHH 007C=HHHH
000D=HHHH 001D=HHHH 002D=HHHH 003D=HHHH 004D=HHHH 005D=HHHH 006D=HHHH 007D=HHHH
000E=HHHH 001E=HHHH 002E=HHHH 003E=HHHH 004E=HHHH 005E=HHHH 006E=HHHH 007E=HHHH
000F=HHHH 001F=HHHH 002F=HHHH 003F=HHHH 004F=HHHH 005F=HHHH 006F=HHHH 007F=HHHH

-------------------------------------------------------------------------------

*REVERSE* Symbol Translation Table (sorted by value):
(blank after every 16 lines)

0000=HHHH 0010=HHHH 0020=HHHH 0030=HHHH 0040=HHHH 0050=HHHH 0060=HHHH 0070=HHHH
0001=HHHH 0011=HHHH 0021=HHHH 0031=HHHH 0041=HHHH 0051=HHHH 0061=HHHH 0071=HHHH
0002=HHHH 0012=HHHH 0022=HHHH 0032=HHHH 0042=HHHH 0052=HHHH 0062=HHHH 0072=HHHH
0003=HHHH 0013=HHHH 0023=HHHH 0033=HHHH 0043=HHHH 0053=HHHH 0063=HHHH 0073=HHHH
0004=HHHH 0014=HHHH 0024=HHHH 0034=HHHH 0044=HHHH 0054=HHHH 0064=HHHH 0074=HHHH
0005=HHHH 0015=HHHH 0025=HHHH 0035=HHHH 0045=HHHH 0055=HHHH 0065=HHHH 0075=HHHH
0006=HHHH 0016=HHHH 0026=HHHH 0036=HHHH 0046=HHHH 0056=HHHH 0066=HHHH 0076=HHHH
0007=HHHH 0017=HHHH 0027=HHHH 0037=HHHH 0047=HHHH 0057=HHHH 0067=HHHH 0077=HHHH
0008=HHHH 0018=HHHH 0028=HHHH 0038=HHHH 0048=HHHH 0058=HHHH 0068=HHHH 0078=HHHH
0009=HHHH 0019=HHHH 0029=HHHH 0039=HHHH 0049=HHHH 0059=HHHH 0069=HHHH 0079=HHHH
000A=HHHH 001A=HHHH 002A=HHHH 003A=HHHH 004A=HHHH 005A=HHHH 006A=HHHH 007A=HHHH
000B=HHHH 001B=HHHH 002B=HHHH 003B=HHHH 004B=HHHH 005B=HHHH 006B=HHHH 007B=HHHH
000C=HHHH 001C=HHHH 002C=HHHH 003C=HHHH 004C=HHHH 005C=HHHH 006C=HHHH 007C=HHHH
000D=HHHH 001D=HHHH 002D=HHHH 003D=HHHH 004D=HHHH 005D=HHHH 006D=HHHH 007D=HHHH
000E=HHHH 001E=HHHH 002E=HHHH 003E=HHHH 004E=HHHH 005E=HHHH 006E=HHHH 007E=HHHH
000F=HHHH 001F=HHHH 002F=HHHH 003F=HHHH 004F=HHHH 005F=HHHH 006F=HHHH 007F=HHHH

-------------------------------------------------------------------------------

Compression Indexes (*TRANSLATED*):
(blank after every 16 lines)

HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH
HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH    HHHHHHHH.9  HHHH

-------------------------------------------------------------------------------
*/

///////////////////////////////////////////////////////////////////////////////
// (future/todo)

int (CMPSC_FASTCALL ARCH_DEP( cmpsc_Report ))( void* dbg )
{
    UNREFERENCED( dbg );
    return 0;
}

///////////////////////////////////////////////////////////////////////////////
#endif /* FEATURE_CMPSC */

#ifndef _GEN_ARCH
  #ifdef _ARCH_NUM_1
    #define _GEN_ARCH _ARCH_NUM_1
    #include "cmpscdbg.c"
  #endif /* #ifdef _ARCH_NUM_1 */
  #ifdef _ARCH_NUM_2
    #undef _GEN_ARCH
    #define _GEN_ARCH _ARCH_NUM_2
    #include "cmpscdbg.c"
  #endif /* #ifdef _ARCH_NUM_2 */
#endif /* #ifndef _GEN_ARCH */