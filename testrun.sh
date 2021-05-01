#!/bin/bash

# compile
g++ -o percept percept.C update_weights.C network_response.C -Wall
g++ -o percept_arm percept.C update_weights.S network_response.S -Wall

# collect out
./percept > percept_out
./percept_arm > percept_arm_out

# diff output
diff -q percept_out percept_arm_out

# clean-up
rm percept percept_arm percept_out percept_arm_out
