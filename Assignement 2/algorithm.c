/*
============================================================================
Filename    : algorithm.c
Author      : Samuel Chassot and Simon Wicky
SCIPER      : 270955 - 260589

============================================================================
*/
#include <math.h>

#define INPUT(I,J) input[(I)*length+(J)]
#define OUTPUT(I,J) output[(I)*length+(J)]

void simulate(double *input, double *output, int threads, int length, int iterations)
{
    double *temp;
    
    // Parallelize this!!
    for(int n=0; n < iterations; n++)
    {
        #pragma omp parallel for
        for(int i=1; i<length / 2; i++)
        {
            #pragma omp parallel for
            for(int j=1; j<length / 2; j++)
            {
                    if ( (i == length/2-1)
                        && (j == length/2-1))
                        continue;

                    double temp2 = (INPUT(i-1,j-1) + INPUT(i-1,j) + INPUT(i-1,j+1) +
                                   INPUT(i,j-1)   + INPUT(i,j)   + INPUT(i,j+1)   +
                                   INPUT(i+1,j-1) + INPUT(i+1,j) + INPUT(i+1,j+1) )/9;
                    OUTPUT(i,j) = temp2;
                    OUTPUT(length-1-i,j) = temp2;
                    OUTPUT(i,length-1-j) = temp2;
                    OUTPUT(length-1-i,length-1-j) = temp2;

            }
        }

        temp = input;
        input = output;
        output = temp;
    }
}
