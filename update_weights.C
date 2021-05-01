#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;

// Include constants for size of layers and number of vectors
#include "constant.h"

////////////////////////////////////////////////////////////////////
//                                                                //
//               PROCEDURE update_weights                         //
//                                                                //
//   First update the output weights then back up through         //
//   the nodes.                                                   //
//                                                                //
//   Calls : none                                                 //
//                                                                //
//   Called By : train                                            //
////////////////////////////////////////////////////////////////////
extern "C" void update_weights(double x[], double o_out[], int desired[],
                    double w[maxout][maxin+1])
  {
  double    change;
  int       i;
  int       j;
  double    delta[maxout];

  // update the w matrix: w[i][j] = w[i][j] + eta*delta[i]*x[j]

  for (i = 0; i < maxout; i++)
    {
    delta[i] = o_out[i] * (1 - o_out[i]) * (desired[i] - o_out[i]);
    for (j = 0; j <= maxin; j++)
      {
      change = eta * delta[i] * x[j];
      w[i][j] += change;
      }
    }
   }
  // update_weights
