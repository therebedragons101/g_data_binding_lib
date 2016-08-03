#!/bin/sh

# This script is convenience run when library is not installed in order to
# make demo and tutorial as accessible as possible

# Temporary hack
export LD_LIBRARY_PATH=.

DIR=`pwd`
cd ../bin
./demo_and_tutorial 
cd "$DIR"
