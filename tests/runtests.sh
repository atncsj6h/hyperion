#! /usr/bin/env bash
echo "*****************************"

while [ $# -gt 0 ]; do
  case $1 in
  --* )
    v=${1:2}
    eval $v=$2
    t="$v         "
    echo "using" "${t::10}" ${!v}
    shift 2
    ;;

  *)
    break
    ;;
  esac
done

rest="$*"

wfn=allTests

# Determine  the  relative path to the tests directory.  The default is
# set on the assumption that this file is in the tests directory, which
# is  where it is in the source tree.  If this is not the case, you are
# advised to write your own derivative of this script.

dir=$tstdir
fns='*'
exit=exit
ftype=tst

if [ -z "$files" ] ; then files="$tstdir/*.$ftype"; fi

# echo dir $tstdir ft $ftype fn $fname files $files all $allfiles herc $hercexec rep $repeat work $wfn vars $vars

vars="$vars ptrsize=${ptrsize}"
vars="$vars platform=${platform}"

# Verify that the configuration file and redtest.rexx are available.
if [ ! -f ${conf} ] ; then
  echo "Error: Hercules configuration file ${conf} not found."
  exit 1
fi

if [ ! -f ${tstdir}/redtest.rexx ] ; then
  echo "Error: Post processor ${tstdir}/redtest.rexx is not available."
  exit 1
fi

if [ -z $(which rexx) ] ; then
  echo "Error: REXX interpreter is not available."
  exit 1
fi

# set -x
echo Files: $files

{
  echo defsym testpath $dir
  todo=$(echo $files)

  for file in $todo; do
    mod=$(stat $file|grep 'Modify'|cut -d ' ' -f 2-)
    dir=$(dirname $file)
    full=$(cd $dir;pwd)
    first=$(echo $file|cut -c 1)
    echo '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'
    echo '*'
    echo '* Start of test file' $file date $mod in $full
    echo '*'
    cat $file
  done
} >$wfn.testin

rv=$?
if [ $rv -ne 0 ] ; then
  echo Unable to build input file rv=$rv
  exit $rv
fi

# Run  the script through Hercules.  Redirecting standard output writes
# a log file.  2>&1 disables the panel display and the ability to enter
# panel commands.

# set -x
cmd="$herc -t4.0 -f $conf -r $wfn.testin"
if [ "$exit" = "noexit" ] ; then
        $cmd >$wfn.out
        rv=$?
else
        # Run  Hercules  in  daemon mode by redirecting both stdout and
        # stderr.

        # PROGRAMMING NOTE: It's CRITICALLY IMPORTANT that we echo a blank line
        # before echoing our 'exit command to our work file ($wfn.testin) since
        # the last file might not end with a line with a LF or CRLF line ending,
        # causing the exit command to simply be appended to the end of that line
        # instead of being echoed to a new line by itself, thus causing Hercules
        # to never exit. (If the last line is "# last line" without any line-
        # ending, the last line of our file would then become "# last lineexit")

        # echo -en is not supported on all systems, or newer bash
#       echo -en '\n' >>$wfn.testin
        echo  >>$wfn.testin  # echo just a newline
        echo exit >>$wfn.testin
        $cmd -d >$wfn.out 2>&1
        rv=$?
fi

# Read entire file to allow redtest.rexx to parse the features list
if [ $rv -eq 0 ] ; then
   rexx $tstdir/redtest.rexx $wfn.out $vars $rest
   rv=$?
fi

exit $rv
