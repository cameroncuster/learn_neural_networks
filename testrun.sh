#!/bin/bash

# compile
g++ -o percept_arm_none.out             percept.C update_weights.C network_response.C -Wall
g++ -o percept_arm_update_weights.out   percept.C update_weights.S network_response.C -Wall
g++ -o percept_arm_network_response.out percept.C update_weights.C network_response.S -Wall
g++ -o percept_arm_all.out              percept.C update_weights.S network_response.S -Wall

# collect out
./percept_arm_none.out > percept_arm_none_out.dat
./percept_arm_update_weights.out > percept_arm_update_weights_out.dat
./percept_arm_network_response.out > percept_arm_network_response_out.dat
./percept_arm_all.out > percept_arm_all_out.dat

# diff output - 2 should always fail at a time (exhaustive)
diff -q percept_arm_none_out.dat percept_arm_update_weights_out.dat
diff -q percept_arm_none_out.dat percept_arm_network_response_out.dat
diff -q percept_arm_none_out.dat percept_arm_all_out.dat

# clean-up
rm *.out *.dat
