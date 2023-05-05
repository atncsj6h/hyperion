#! /usr/bin/env bash

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copyright (c) 2022, 2023 Enrico Sorichetti
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file BOOST_LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Usage() {
  exit $1
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function __yesno() {
  for ((;;)) ; do
    echo "${1}Enter [y](ENTER) to continue"
    echo "${1}      [n/q]      to Exit"
    read z
    if [ "${z}". == . ] ; then
        return 0
    fi
    z=${z,,}
    case ${z} in
      y | ye |yes )  return 0
          ;;
      *)  return 1
          ;;
    esac
  done
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

me="build        "
me=${me:0:8}
hd="@@  ${me} - "

if  [ 1 -eq 1 ] ; then
echo "${hd}at entry"
echo "@@"
echo "${hd}£0    '$0'"
echo "${hd}argc  '$#'"
echo "${hd}args  '$@'"
echo "${hd}path  '$PATH'"
echo "${hd}cwd   '$(pwd)'"
echo "@@"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
while true ; do

  flag=$(printf "%s" $1 )

  case "${flag}" in

    -makeself | --makeself )
      makeself="${2}"
      shift 2 || { Usage 1 ; }
      continue
      ;;

    -project | --project )
      project="${2}"
      shift 2 || { Usage 1 ; }
      continue
      ;;

    -triplet | --triplet )
      triplet="${2}"
      shift 2 || { Usage 1 ; }
      continue
      ;;

    -version | --version )
      version="${2}"
      shift 2 || { Usage 1 ; }
      continue
      ;;

    -prefix | --prefix )
      prefix="${2}"
      shift 2 || { Usage 1 ; }
      continue
    ;;

    -- )
      shift 1  || { Usage 1 ; }
      break
    ;;

    "-"*)
	    echo "@@  $me - Unrecognized flag :"$1
      exit 1
	  ;;

    *)
	    break
	  ;;

  esac

done

__yesno "${hd}"
yesno=$?
if [ ${yesno} -eq 1 ] ; then
  echo  "${hd}canceled"
  echo  "${hd}bye"
  echo  "@@"
  exit  1
fi

echo  "${hd}installing 'portable/${project}-${triplet}' "
CMAKE_MANIFEST_PREFIX=portable cmake -DCMAKE_INSTALL_PREFIX=portable/${project}-${triplet} -P cmake_install.cmake 1>/dev/null

#   --cleanup ./support/bin/portable-cleanup.sh \
echo  "${hd}creating '${project}-${version}.run' "
${makeself} --xz --sha256 --notemp --nooverwrite \
  --tar-quietly \
  --license portable/${project}-${triplet}/share/NOTICES/CPLv1.0.txt \
  portable/${project}-${triplet} ooRexx-${version}.run "ooRexx" ./bin/portable-startup.sh

RC=$?
if [ ${RC} -ne 0 ] ; then
  echo  "${hd}makeself rc(${RC})"
  exit 1
fi

echo  "${hd}creating  the sha256 checksum for '${project}-${version}.run' "
shasum -a 256 -U  ${project}-${version}.run >${project}-${version}.run.asc
RC=$?
if [ ${RC} -ne 0 ] ; then
  echo  "${hd}shasum rc(${RC})"
  exit 1
fi

echo  "${hd}creating  the detached signature for '${project}-${version}.run' "
gpg -sb --passphrase ${passphrase} --batch --pinentry-mode loopback ${project}-${version}.run
RC=$?
if [ ${RC} -ne 0 ] ; then
  echo  "${hd}gpg sign rc(${RC})"
  exit 1
fi



echo "${hd}at exit"
echo "@@"
echo "${hd}\$0    '$0'"
echo "${hd}argc  ($#)"
echo "${hd}args  '$@'"
echo "@@"

echo "${hd}bye"
echo "@@"

exit 0

