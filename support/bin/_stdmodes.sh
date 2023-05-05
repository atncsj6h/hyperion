#! /usr/bin/env bash

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copyright (c) 2022, 2023 Enrico Sorichetti
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file BOOST_LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#       directories     ==> rwx/r.x/r.x

find .  -type d -print0  | xargs -0 chmod 755

# exclude files in .hg .git .svn

# files ==> rw./r../r..
find .  ! -regex '^.*/.hg/.*$' !  -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -print0  | xargs -0 chmod 644

# executables ==> rwx/r.x/r.x
# everything  ==> bin
find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -regex '^.*/bin/.*$' \
        -type f -print0 | xargs -0 chmod 755

# Libraries   ==> rwx/r.x/r.x
# everything  ==> lib
find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -regex '^.*/bin/.*$' \
        -type f -print0 | xargs -0 chmod 755

# executables ==> rwx/r.x/r.x
# anywhere by extension
find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.sh"    -print0  | xargs -0 chmod 755

find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.pl"    -print0  | xargs -0 chmod 755

find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.py"    -print0  | xargs -0 chmod 755

find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.rb"    -print0  | xargs -0 chmod 755

find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.rex"   -print0  | xargs -0 chmod 755

find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.cls"   -print0  | xargs -0 chmod 755

find .  ! -regex '^.*/.hg/.*$'  ! -regex '^.*/.git/.*$' ! -regex '^.*/.svn/.*$' \
        -type f -name "*.run"   -print0  | xargs -0 chmod 755
