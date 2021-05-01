#!/bin/bash

# compile
g++ -o percept percept.C weighandRespond.C -Wall
g++ -o percept_arm percept.C weighandRespond.S -Wall

# collect out
./percept > percept_out
./percept_arm > percept_arm_out

# diff output
diff -q percept_out percept_arm_out

# clean-up
rm percept percept_arm percept_out percept_arm_out
