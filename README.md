This program constructs a single layer perceptron network where the sigmoid
activation function ( f(x) = 1 / [1 + e^-x] ) is calculated. The network is
trained with gradient descent, and tested with inputs which have not been seen
the program.

Gradient descent optimization factor of 0.2.

The weight modifications and output layer response calculations are performed in
AArch64 assembly language with specific optimizations for efficiency. The
network response is implemented in such a way that the network can effortlessly
be extended for multiple layers.
