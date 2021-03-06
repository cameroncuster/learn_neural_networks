# Perceptron Network
This program constructs a single layer perceptron network where the sigmoid
activation function ( f(x) = 1 / [1 + e^(-x)] ) is calculated. The network is
trained with gradient descent, and tested with inputs which have not been seen
the program.

Gradient descent optimization factor of 0.2 (eta).

**Average Times**(s)
| | Update Weights | Network Response | Average |
| - | - | - | - |
| C | 6.3905e-06 | 5.5316e-06 | 1.28205e-05 |
| AArch64 | 1.21388e-06 | 2.9766e-06 | 6.41026e-06 |

**Implementation**
The weight modifications and output layer response calculations are performed in
AArch64 assembly language with specific optimizations for efficiency such as
vectorizing all operations for half the execution time. The network response is
implemented in such a way that the network can effortlessly be extended for
multiple layers, but still vectorizes instructions for a 2x speed-up as shown
in the table above.

**Testing**
[Test script](testrun.sh) was written for the files to compile, execute,
collect, and diff the output. This allowed for continuous integration (CI) and
development (CD), without an actual pipeline.
