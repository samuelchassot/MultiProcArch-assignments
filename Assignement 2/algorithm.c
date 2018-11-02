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

#define PINPUT(I,J) pInput[4*((I)*length+(J))]
#define POUTPUT(I,J) pOutput[4*((I)*length+(J))]


void simulate(double *input, double *output, int threads, int length, int iterations) {
    double *temp;
    size_t midIndex = length / 2 - 1;

    double *pInput =  calloc(length*length, sizeof(double));
    double *pOutput = calloc(length*length, sizeof(double));
    
    PINPUT(midIndex, midIndex) = INPUT(midIndex, midIndex);
    POUTPUT(midIndex, midIndex) = OUTPUT(midIndex, midIndex);

    
    for(int n=0; n < iterations; n++) {

        #pragma omp parallel 
        {

    		#pragma omp for
	        for(int i=1; i<length / 2; i++) {
	            
	            
	            for(int j=i; j<length / 2; j++) {

	                    if ( (i == midIndex) && (j == midIndex)){
	                        continue;
	                    }
	                    double temp2;

	                    //diagonal
	                    if (i == j){
		                    temp2 = (INPUT(i-1,j-1) + 2 * INPUT(i-1,j) + 2 * INPUT(i-1,j+1) +
                                   	 					INPUT(i,j)   + 2 * INPUT(i,j+1)   +
                               												INPUT(i+1,j+1) )/9;
	                    }

	                    //special case above diagonal in central column
	                    else if (j == midIndex && j ==  i + 1){
		                    temp2 = (INPUT(i-1,j-1) + 2 * INPUT(i-1,j) +
                                   INPUT(i,j-1)   + 3 * INPUT(i,j)   +
                                   					2 * INPUT(i+1,j) )/9;   
	                    }
	                    //above diagonal
	                    else if (j == i + 1){
		                    temp2 = (INPUT(i-1,j-1) + INPUT(i-1,j) + INPUT(i-1,j+1) +
		                                   INPUT(i,j-1)   + 2 * INPUT(i,j)   + INPUT(i,j+1)   +
		                                   					 INPUT(i+1,j) + INPUT(i+1,j+1) )/9;  	                    	
	                    }

	                    //central column
	                    else if (j == midIndex){
	                    	temp2 = (INPUT(i-1,j-1) + 2 * INPUT(i-1,j) +
	                                   INPUT(i,j-1)   + 2 * INPUT(i,j)   +
	                                   INPUT(i+1,j-1) + 2 * INPUT(i+1,j) )/9;
	                    }
	                    else {
		                    temp2 = (INPUT(i-1,j-1) + INPUT(i-1,j) + INPUT(i-1,j+1) +
		                                   INPUT(i,j-1)   + INPUT(i,j)   + INPUT(i,j+1)   +
		                                   INPUT(i+1,j-1) + INPUT(i+1,j) + INPUT(i+1,j+1) )/9;                    	
	                    }

	                     OUTPUT(i,j) = temp2;



	            }
	        }

    	}

        temp = input;
        input = output;
        output = temp;   
    }

    //output = input;
    //temp = input;
    //output = temp;

    #pragma omp parallel for
    for(int i = 0 ; i < length/2 ; ++i){
        for(int j = i ; j < length/2 ; ++j){
            if ( (i == midIndex) && (j == midIndex)){
            	continue;
            }	
            double cur = OUTPUT(i, j);

            OUTPUT(i,j) = cur;
            OUTPUT(j,i) = cur;

            OUTPUT(length-1-i, j) = cur;
            OUTPUT(j, length-1-i) = cur;

            OUTPUT(i, length-1-j) = cur;
            OUTPUT(length-1-j, i) = cur;

            OUTPUT(length-1-i, length-1-j) = cur;
            OUTPUT(length-1-j, length-1-i) = cur;
        }
    }
    free(pInput);
    free(pOutput);


    
}
