#!/bin/sh

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copyright (c) 2022, 2023 Enrico Sorichetti
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file BOOST_LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

Usage()
{
  exit $1
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Usage() {
  exit $1
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function __yesno() {
  for ((;;)) ; do
    echo "${1} Enter [y](ENTER) to continue"
    echo "${1}       [n/q]      to Exit"
    read z
    if [ "${z}". == . ] ; then
        return 0
    fi
    case ${z} in
      y | Y | yes | YES )  return 0
          ;;
      *)  return 1
          ;;
    esac
  done
}

me="startup          "
hd="@@  ${me:0:8} - "

if [ 1 -eq 0 ] ; then
  echo  "${hd}at entry"
  echo  "${hd}pwd   "$(pwd)
  echo  "${hd}PATH  "$PATH
  echo  "${hd}\$0    "$0
  echo  "${hd}SELF  "$(basename $0)
  echo  "${hd}argc  "$#
  echo  "${hd}args  "$@
  echo "@@"
fi

clear
echo  ""
echo  "${hd} ooRexx has been installed into \"$(pwd)\" "
echo  "${hd} cd to \"$(pwd)/bin\" "
echo  "${hd} enter the command \"source path.here\" "
echo  "${hd} it will prepend the current path to the PATH "
echo  "${hd} should work both for zsh and bash"
echo  "${hd} nothing else has to be done"
echo  ""
echo  "${hd} to check if things work as they should"
echo  "${hd} cd to one of the api samples and  enter the command \"make\" "
echo  "${hd} the relevant rexx script shoud run as planned"
echo  "${hd} a very good test would be the call.example"
echo  ""
echo  "${hd} this script is not needed any longer... "
echo  "${hd} you can \"rm $(pwd)/bin/$(basename $0)\" "
echo  ""
echo  "${hd} you might want to update the PATH/path definition in \"~/.zprofile/~/.bash_profile\" "
echo  "${hd} adding the ooRexx binary dir \"$(pwd)/bin\" "
echo  ""
echo  "${hd} enjoy your fresh installation of \"Open Object Rexx\" "
__yesno "${hd}"

exit
