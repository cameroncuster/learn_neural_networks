////////////////////////////////////////////////////////////////////
//      Generate Weights for single layer perceptron Network      //
////////////////////////////////////////////////////////////////////

#include <iostream>
#include <iomanip>
#include <ctime>
#include <fstream>
#include <stdlib.h>
#include "constant.h"
using namespace std;

const double MAX = double(RAND_MAX);

int main()
  {
  float double_off;
  int i;
  int num_weights;
  float offset;
  ofstream outfile;
  float x;

  offset = 1;
  double_off = offset * 2.0;
  outfile.open(weight_file_name);
  srand(time(NULL));

  outfile.setf(ios::fixed);
  num_weights = (maxin +1) * maxout;
  for (i = 0; i < num_weights; i++)
    {
    x = (rand() / MAX) * double_off - offset;
    outfile << setprecision(6);
    outfile << setw(10) << x;
    if ( (i+1) % 7 == 0)
      outfile << endl;
    }

  outfile << endl;
   
  outfile << "0 iterations" << endl;
  outfile << "Random weights above" << endl;
  outfile << "==============================================";
  outfile << endl;
  outfile.close();
  }

////////////////////////////////////////////////////////////////////
//                 end of generate weights                        //
////////////////////////////////////////////////////////////////////

