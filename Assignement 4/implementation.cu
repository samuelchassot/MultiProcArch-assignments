/*
============================================================================
Filename    : algorithm.c
Author      : Samuel Chassot and Simon Wicky
SCIPER      : 270955, 260589
============================================================================
*/

#include <iostream>
#include <iomanip>
#include <sys/time.h>
#include <cuda_runtime.h>
using namespace std;

#define INPUT(X,Y) input[(X) * length + (Y)]
#define OUTPUT(X,Y) output[(X) * length + (Y)] 

// CPU Baseline
void array_process(double *input, double *output, int length, int iterations)
{
    double *temp;

    for(int n=0; n<(int) iterations; n++)
    {
        for(int i=1; i<length-1; i++)
        {
            for(int j=1; j<length-1; j++)
            {
                output[(i)*(length)+(j)] = (input[(i-1)*(length)+(j-1)] +
                                            input[(i-1)*(length)+(j)]   +
                                            input[(i-1)*(length)+(j+1)] +
                                            input[(i)*(length)+(j-1)]   +
                                            input[(i)*(length)+(j)]     +
                                            input[(i)*(length)+(j+1)]   +
                                            input[(i+1)*(length)+(j-1)] +
                                            input[(i+1)*(length)+(j)]   +
                                            input[(i+1)*(length)+(j+1)] ) / 9;

            }
        }
        output[(length/2-1)*length+(length/2-1)] = 1000;
        output[(length/2)*length+(length/2-1)]   = 1000;
        output[(length/2-1)*length+(length/2)]   = 1000;
        output[(length/2)*length+(length/2)]     = 1000;

        temp = input;
        input = output;
        output = temp;
    }
}

__global__ void array_process_GPU(double *input, double *output, int length){
    //double *temp;
    int x = (blockIdx.x * blockDim.x) + threadIdx.x;
    int y = (blockIdx.y * blockDim.y) + threadIdx.y;
    if(y > 0 && y < length-1 && x > 0 && x < length - 1 ){
        OUTPUT(x,y) = (INPUT(x-1,y-1) +
                            INPUT(x-1,y)   +
                            INPUT(x-1,y+1) +
                            INPUT(x,y-1)   +
                            INPUT(x,y)     +
                            INPUT(x,y+1)   +
                            INPUT(x+1,y-1) +
                            INPUT(x+1,y)   +
                            INPUT(x+1,y+1) ) / 9;
    }
    if ((x == length / 2 || x == length / 2 - 1) &&  (y == length / 2 || y == length / 2 - 1)){
    	OUTPUT(x,y) = 1000;
    }
    INPUT(x,y) = 1000;
    OUTPUT(x,y) = 1000;

    //temp = input;
    //input = output;
    //output = temp;
}


// GPU Optimized function
void GPU_array_process(double *input, double *output, int length, int iterations)
{
    //Cuda events for calculating elapsed time
    cudaEvent_t cpy_H2D_start, cpy_H2D_end, comp_start, comp_end, cpy_D2H_start, cpy_D2H_end;
    cudaEventCreate(&cpy_H2D_start);
    cudaEventCreate(&cpy_H2D_end);
    cudaEventCreate(&cpy_D2H_start);
    cudaEventCreate(&cpy_D2H_end);
    cudaEventCreate(&comp_start);
    cudaEventCreate(&comp_end);

    /* Preprocessing goes here */
    double* input_GPU;
    double* output_GPU;
    int size = length * length;
    cudaMalloc((void**) &input_GPU, size);
    cudaMalloc((void**) &output_GPU, size);

    cudaEventRecord(cpy_H2D_start);


    /* Copying array from host to device goes here */

    cudaMemcpy(input_GPU, input, size, cudaMemcpyHostToDevice);
    cudaEventRecord(cpy_H2D_end);
    cudaEventSynchronize(cpy_H2D_end);

    //Copy array from host to device


    cudaEventRecord(comp_start);
    /* GPU calculation goes here */
    for(int n=0; n < iterations; n++) {
    	array_process_GPU <<<100,100>>> (input_GPU, output_GPU, length);
    }


    cudaEventRecord(comp_end);
    cudaEventSynchronize(comp_end);

    cudaEventRecord(cpy_D2H_start);


    /* Copying array from device to host goes here */
    cudaMemcpy(output_GPU, output, size, cudaMemcpyDeviceToHost);

    cudaEventRecord(cpy_D2H_end);
    cudaEventSynchronize(cpy_D2H_end);

    /* Postprocessing goes here */



    float time;
    cudaEventElapsedTime(&time, cpy_H2D_start, cpy_H2D_end);
    cout<<"Host to Device MemCpy takes "<<setprecision(4)<<time/1000<<"s"<<endl;

    cudaEventElapsedTime(&time, comp_start, comp_end);
    cout<<"Computation takes "<<setprecision(4)<<time/1000<<"s"<<endl;

    cudaEventElapsedTime(&time, cpy_D2H_start, cpy_D2H_end);
    cout<<"Device to Host MemCpy takes "<<setprecision(4)<<time/1000<<"s"<<endl;
}