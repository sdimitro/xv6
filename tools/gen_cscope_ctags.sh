#!/bin/sh

# AUTHOR: Serapheim Dimitropoulos <serapheimd@gmail.com>
# CREATED: Thu Dec 25 05:02:09 CST 2014
# CONTRIBUTORS:
# UPDATED: Thu Dec 25 05:02:09 CST 2014

# PURPOSE:
# Generates cscope.ctags files of C files
# and headers in the current directory and
# any subdirectories.


find `pwd` -name "*.c" -o -name "*.h" > cscope.files
cscope -q -R -b -i cscope.files
rm cscope.files

ctags -R ./*

