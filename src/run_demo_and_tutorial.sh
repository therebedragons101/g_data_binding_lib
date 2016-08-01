#!/bin/sh

# This script is convenience run when library is not installed in order to
# make demo and tutorial as accessible as possible

# Temporary hack
export LD_LIBRARY_PATH=../bin

# Temporary hack as I don't really have time to play with embedding resources
# right now (low priority bug)
DIR=`pwd`
cd ../bin
ln -s ../src/demos/demo_and_tutorial/interface.ui
ln -s ../src/demos/demo_and_tutorial/map.png
./demo_and_tutorial 
rm interface.ui
rm map.png
cd "$DIR"
