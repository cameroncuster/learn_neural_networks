#!/bin/bash

g++ -o percept weighandRespond.C percept.C -Wall
g++ -o percept_arm weighandRespond.S percept.C -Wall

./percept > percept_out
./percept_arm > percept_arm_out

diff -q percept_out percept_arm_out

rm percept percept_arm percept_out percept_arm_out
