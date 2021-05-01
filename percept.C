////////////////////////////////////////////////////////////////////
//                                                                //
//      to-from weight version                                    //
//                                                                //
//                'VANILLA' Perceptron  [2008]                    //
//                                                                //
//  Program to do gradient descent.  Assumes two layers :         //
//  input, output [no hidden layer].                              //
//                                                                //
////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;

// Include constants for size of layers and number of vectors
#include "constant.h"

#define DEBUG false
#define CLOCK false

// Include for clocking update_weights and network_response
#include <chrono>
using namespace std::chrono;

extern "C" void update_weights(double x[], double o_out[], int desired[],
        double w[maxout][maxin+1]);

extern "C" void network_response(double x[maxin+1], double w[maxout][maxin+1],
        double o_out[maxout]);


////////////////////////////////////////////////////////////////////
//                                                                //
//              function classify                                 //
//              pick biggest entry in output vector               //
//                                                                //
////////////////////////////////////////////////////////////////////
int classify(double o_out[maxout])
  {
  int    guess;
  int    i;

  guess = 0;
  for (i = 0; i < maxout; i++)
    if (o_out[i] > o_out[guess])
      guess = i;

  return guess;
  }  // classify


////////////////////////////////////////////////////////////////////
//                                                                //
//             function make_expected                             //
//                                                                //
//  converts the class number into an expected vector             //
//                                                                //
////////////////////////////////////////////////////////////////////

void make_expected(int fclass[], int n, int target[][maxout])
  {
  int i;
  int j;
  int class_num;

  for (i = 0; i < n; i++)
    {
    class_num = fclass[i];
    for (j = 0; j < maxout; j++)
      target[i][j] = 0;
    target[i][class_num] = 1;
#if DEBUG
      cout << "target[" << i << "][" << class_num 
           << "] = " << 1 << endl;
#endif
    }
  }
  // make_expected


////////////////////////////////////////////////////////////////////
//                                                                //
//             function test_feature_vectors                      //
//                                                                //
//   Test that the matrix gives the right answers for             //
//   the training vectors.                                        //
//                                                                //
//   Calls : network_response                                     //
//                                                                //
//   Called By : main program                                     //
////////////////////////////////////////////////////////////////////

void test_vectors(double fv[][maxin+1], int numv,
  double w[maxout][maxin+1], 
  int fclass[], int desired[][maxout])
  {
  int     i;
  int     net_guess;
  int     correct;
  double  o_out[maxout];

  correct = 0;
  for (i = 0; i < numv; i++)
    {
    network_response(fv[i], w, o_out);
#if DEBUG
    if (i == 0)
      {
      cout << "o_out: ";
      for (int j = 0; j < maxout; j++)
        cout << o_out[j] << "  ";
      cout << endl;
      }
#endif

    net_guess = classify(o_out);
    if (net_guess == fclass[i])
      correct ++;
#if DEBUG
      {
      cout << "vector " << i << " class " << fclass[i]
           << ", net_guess " << net_guess;
      if (net_guess == fclass[i])      
        cout << ", correct";
      else
        cout << ", WRONG";
      cout << ", correct = " << correct;
      cout << endl;
      }
#endif
    }
  cout << "Number correct = " << correct << "  ["
       << 100.0 * correct / numv << "%]   |  ";
  cout << "Number wrong   = " << numv - correct << endl;
  }
  // test_vectors




////////////////////////////////////////////////////////////////////
//                                                                //
//       function initialize_feature_vectors                      //
//                                                                //
//   Reads the feature vectors from a file.                       //
//                                                                //
//   Called By : main program                                     //
//                                                                //
////////////////////////////////////////////////////////////////////

void initialize_feature_vectors(double fv[numfv][maxin+1], 
   int fclass[maxout], int ftarget[numfv][maxout], 
   double uv[numuv][maxin+1], int uclass[maxout], 
   int utarget[numuv][maxout])
  {
  int        i;
  int        j;
  ifstream   invect;      // training and test vectors

  //-----open the vector file-----
  invect.open(fv_in);
  if (!invect)
    {
    cout << "***** vector file not found. ******" << endl;
    exit(1);
    }

  //----------read training vectors ------
  for (i = 0; i < numfv; i++)
    {
    fv[i][0] = 1;  // bias
    invect >> fclass[i];
    
    for (j = 1; j <= maxin; j++)
      invect >> fv[i][j];

    }
  make_expected(fclass, numfv, ftarget); 

  //-----------read testing vectors------
  for (i = 0; i < numuv; i++)
    {
    uv[i][0] = 1;  // bias
    invect >> uclass[i];
 
    for (j = 1; j <= maxin; j++)
      invect >> uv[i][j];
    }
  make_expected(uclass, numuv, utarget);

  invect.close();
  }
  // initialize_feature_vectors


////////////////////////////////////////////////////////////////////
//                                                                //
//              function initialize                               //
//                                                                //
////////////////////////////////////////////////////////////////////
void initialize(double w[maxout][maxin+1])
  {
  int       i;
  int       j;
  ifstream  infile;

  //-------open weight file-------------
  infile.open(weights_in);
  if (!infile)
    {
    cout << "***** weight file not found. ******" << endl;
    exit(1);
    }

  //-----note [to][from]-----------
  for (i = 0; i < maxout; i++)
    for (j = 0; j <= maxin; j++)
      infile >> w[i][j];

  infile.close();
  }
  // initialize



////////////////////////////////////////////////////////////////////
//                                                                //
//             PROCEDURE print_weights                            //
//                                                                //
//  Print the weight matrices.  Used especially for saving        //
//  a state to a file for further processing later.               //
//                                                                //
////////////////////////////////////////////////////////////////////

void print_weights(double w[maxout][maxin+1])
  {
  int i;
  int j;
  ofstream    outfile;        // save network weights

  outfile . open(weights_out);
  for (i = 0; i < maxout; i++)
    {
    for (j = 0; j <= maxin; j++)
      {
      outfile << w[i][j] << "  ";
      if (((j+1) % 5) == 0)
        outfile << endl << "             ";
      }  // for j
    outfile << endl;
    }  // for i

  outfile.close();
  }
  // print_weights


////////////////////////////////////////////////////////////////////
//                                                                //
//                  PROCEDURE find_error                          //
//                                                                //
////////////////////////////////////////////////////////////////////

void find_error(double fv[numfv][maxin+1], 
  int desired[numfv][maxout],
  double w[maxout][maxin+1])
  {
  int       i;
  int       j;
  double    total_error;
  double    error;
  double    o_out[maxout];
 
  total_error = 0.0;
  for (i = 0; i < numfv; i++)
    {
    network_response(fv[i], w, o_out);
    error = 0;
    for (j = 0; j < maxout; j++)
      {
      error += (desired[i][j] - o_out[j]) * (desired[i][j] - o_out[j]);
#if DEBUG
        {
        if (desired[i][j] > 0.5)
          cout << "desired[" << i << "][" << j << "] = " << desired[i][j]
               << ", and o_out[" << j << "] = " << o_out[j] << endl;
        }
#endif
      }
    total_error += error;
    }

  cout << "Total error = " << total_error << endl;

  }  // find error

////////////////////////////////////////////////////////////////////
//                                                                //
//                  PROCEDURE train_vectors                       //
//                                                                //
////////////////////////////////////////////////////////////////////
void train_vectors(double fv[numfv][maxin+1], int fclass[maxout],
   int ftarget[numfv][maxout], double uv[numuv][maxin+1], 
   int uclass[maxout], int utarget[numuv][maxout],
   double w[maxout][maxin+1])
  {
  int        i;
  int        n_iter;         // number of training iterations
  ofstream   results_out;    // results output
  double     o_out[maxout];

  results_out.open(results_out_name);
  if (!results_out)
    {
    cout << "unable to open results file" << endl;
    exit (1);
    }

  //---------find initial error---------------
  find_error(fv, ftarget, w);

  duration<double> totalTimeResponse, totalTimeWeights;
  high_resolution_clock::time_point t1, t2;
  int iterations = 0;

  for (n_iter = 1; n_iter <= n_iterations; n_iter++)
    {
    for (i = 0; i < numfv; i++)
      {
      t1 = high_resolution_clock::now();
      network_response(fv[i], w, o_out);
      t2 = high_resolution_clock::now();

      totalTimeResponse += duration_cast<duration<double>>(t2 - t1);

      t1 = high_resolution_clock::now();
      update_weights(fv[i], o_out, ftarget[i], w);
      t2 = high_resolution_clock::now();

      totalTimeWeights += duration_cast<duration<double>>(t2 - t1);

      iterations++;
      }

    if ((n_iter % log_mod == 0) || (n_iter == n_iterations))
      {
      cout << "Error after " << n_iter << " iterations" << endl;
      find_error(fv, ftarget, w);
      test_vectors(fv, numfv, w, fclass, ftarget);
      test_vectors(uv, numuv, w, uclass, utarget);
      }
    } // for n_iter
  results_out . close();
#if CLOCK
  cout << endl <<
      "Average time taken by update_weights: " <<
      double(totalTimeWeights.count()) / double(iterations) << endl <<
      "Average time taken by network_response: " <<
      double(totalTimeResponse.count()) / double(iterations) << endl << endl;
#endif
  }
  // train

////////////////////////////////////////////////////////////////////
//                                                                //
//                  MAIN PROGRAM                                  //
//                                                                //
////////////////////////////////////////////////////////////////////

int main()
  {
  double  w[maxout][maxin+1];      // weights to output layer from input layer
  int     fclass[numfv];           // class each feature vector belongs to
  int     uclass[numuv];           // class each test vector belongs to
  int     ftarget[numfv][maxout];  // target for each vector
  int     utarget[numuv][maxout];  // target for each test vector 
  double  fv[numfv][maxin+1];      // feature vector array
  double  uv[numuv][maxin+1];      // testing vector array

  cout << "About to initialize" << endl;
  initialize(w);
  cout << "Initializing feature vectors" << endl;
  initialize_feature_vectors(fv, fclass, ftarget, uv, uclass, utarget);

  cout << "Training vectors" << endl;
  train_vectors(fv, fclass, ftarget, uv, uclass, utarget, w);

  cout << "Printing weights" << endl;
  print_weights(w);

  cout << endl << "Done" << endl;

  }
  // main

////////////////////////////////////////////////////////////////////
//                  END BACKPROPAGATION CODE                      //
////////////////////////////////////////////////////////////////////


