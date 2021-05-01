#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;

// Include constants for size of layers and number of vectors
#include "constant.h"

////////////////////////////////////////////////////////////////////
//                                                                //
//                function network_response                       //
//                                                                //
//   Calculate the responses of the hidden layer and feed         //
//   these into the output layer.                                 //
//                                                                //
//   Calls : none                                                 //
//                                                                //
//   Called By : train                                            //
//               test_uniform                                     //
////////////////////////////////////////////////////////////////////
extern "C" void network_response (double x[maxin+1], double w[maxout][maxin+1], 
                       double o_out[maxout])
  {
  int      i;
  int      j;
  double   temp;

  // calculate the output layer response
  for (i = 0; i < maxout; i++)
    {
    temp = 0;
    for (j = 0; j <= maxin; j++)
      temp += w[i][j] * x[j];

    o_out[i] = 1.0 / (1 + exp(-temp));
    }

  }
  // network_response
