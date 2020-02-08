#!/bin/bash
# Assemble, link, and run an example ForwardCom assembly file
# Usage: ./make_example.sh hello

# make_example.sh
#  By Agner Fog 2020-02-08

# Stop if error:
set -e

# Assemble:
./forw -ass $1.as

# Link:
./forw -link $1.ex $1.ob libc.li math.li

# run
echo Running $1.ex:
./forw -emu $1.ex -list=out.txt

