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

#define PINPUT(I,J) pInput[8*((I)*length+(J))]
#define POUTPUT(I,J) pOutput[8*((I)*length+(J))]


void simulate(double *input, double *output, int threads, int length, int iterations) {
    double *temp;
    double midIndex = length / 2 - 1;

    double *pInput = calloc(8*length*length, sizeof(double));
    double *pOutput = calloc(8*length*length, sizeof(double));
    for(int i=1; i<length / 2; i++) {
        for(int j=1; j<length / 2; j++) {
            PINPUT(i,j) = INPUT(i,j);
            POUTPUT(i,j) = OUTPUT(i,j);
        }
    }

    
    // Parallelize this!!
    for(int n=0; n < iterations; n++) {

        #pragma omp parallel 
        {

    		#pragma omp for
	        for(int i=1; i<length / 2; i++) {
	            
	            
	            for(int j=1; j<length / 2; j++) {

	                    if ( (i == midIndex) && (j == midIndex)){
	                        continue;
	                    }
	                    double temp2;

	                    if (j == midIndex){
	                    	temp2 = (PINPUT(i-1,j-1) + 2 * PINPUT(i-1,j) +
	                                   PINPUT(i,j-1)   + 2 * PINPUT(i,j)   +
	                                   PINPUT(i+1,j-1) + 2 * PINPUT(i+1,j) )/9;
	                    }
	                    else if (i == midIndex){
	                    	temp2 = (PINPUT(i-1,j-1) + PINPUT(i-1,j) + PINPUT(i-1,j+1) +
	                                   2 *PINPUT(i,j-1)   + 2 *PINPUT(i,j)   + 2 *PINPUT(i,j+1) )/9;
	                    }
	                    else {
		                    temp2 = (PINPUT(i-1,j-1) + PINPUT(i-1,j) + PINPUT(i-1,j+1) +
		                                   PINPUT(i,j-1)   + PINPUT(i,j)   + PINPUT(i,j+1)   +
		                                   PINPUT(i+1,j-1) + PINPUT(i+1,j) + PINPUT(i+1,j+1) )/9;                    	
	                    }

	                     POUTPUT(i,j) = temp2;



	            }
	        }

    	}

        if (n != iterations -1){
                temp = pInput;
                pInput = pOutput;
                pOutput = temp;
            }    
    }


    
    for(int i = 0 ; i < length/2 ; ++i){
        for(int j = 0 ; j < length/2 ; ++j){
            double cur = POUTPUT(i, j);
            //OUTPUT(i,j) = cur;
            //OUTPUT(length-1-i, j) = cur;
            //OUTPUT(i, length-1-j) = cur;
            //OUTPUT(length-1-i, length-1-j) = cur;
        }
    }

    
}
