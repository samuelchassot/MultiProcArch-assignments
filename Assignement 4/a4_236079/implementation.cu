/*
============================================================================
Filename    : algorithm.c
Author      : Olivier Cloux
SCIPER      : 236079
============================================================================
*/

#include <iostream>
#include <iomanip>
#include <sys/time.h>
#include <cuda_runtime.h>
using namespace std;

#define CENTER_VAL 1000

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
        output[(length/2-1)*length+(length/2-1)] = CENTER_VAL;
        output[(length/2)*length+(length/2-1)]   = CENTER_VAL;
        output[(length/2-1)*length+(length/2)]   = CENTER_VAL;
        output[(length/2)*length+(length/2)]     = CENTER_VAL;

        temp = input;
        input = output;
        output = temp;
    }
}

__global__ void heattransfer(double *input, double *output, int length)
{
  int i = blockIdx.x + 1; //shifting to not consider
  int j = threadIdx.x + 1;
  output[i*length + j] = (input[(i-1)*(length)+(j-1)] +
                      input[(i-1)*(length)+(j)]   +
                      input[(i-1)*(length)+(j+1)] +
                      input[(i)*(length)+(j-1)]   +
                      input[(i)*(length)+(j)]     +
                      input[(i)*(length)+(j+1)]   +
                      input[(i+1)*(length)+(j-1)] +
                      input[(i+1)*(length)+(j)]   +
                      input[(i+1)*(length)+(j+1)] ) / 9;

  output[(length/2-1)*length+(length/2-1)] = CENTER_VAL;
  output[(length/2)*length+(length/2-1)]   = CENTER_VAL;
  output[(length/2-1)*length+(length/2)]   = CENTER_VAL;
  output[(length/2)*length+(length/2)]     = CENTER_VAL;
}

__global__ void heattransfer2(double *input, double *output, int length, int casePerBlock)
{
  int i = blockIdx.x + 1; //shifting to not consider
  int j = threadIdx.x*casePerBlock + 1;
  for (size_t k = 0; k < casePerBlock; k++) {
      // j = max((j + k) % length-2, 1);

      output[i*length + j] = (input[(i-1)*(length)+(j-1)] +
                          input[(i-1)*(length)+(j)]   +
                          input[(i-1)*(length)+(j+1)] +
                          input[(i)*(length)+(j-1)]   +
                          input[(i)*(length)+(j)]     +
                          input[(i)*(length)+(j+1)]   +
                          input[(i+1)*(length)+(j-1)] +
                          input[(i+1)*(length)+(j)]   +
                          input[(i+1)*(length)+(j+1)] ) / 9;

      output[(length/2-1)*length+(length/2-1)] = CENTER_VAL;
      output[(length/2)*length+(length/2-1)]   = CENTER_VAL;
      output[(length/2-1)*length+(length/2)]   = CENTER_VAL;
      output[(length/2)*length+(length/2)]     = CENTER_VAL;
  }
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
  size_t size = length*length*sizeof(double);
  double* in;
  double* out;
  double* temp;
  int casePerBlock = ((length-2)*(length-2) + 512 - 1) / 512;
  int threadePerBlock = 0;
  if(length-2 > 512){
    threadePerBlock = 512;
  } else {
    threadePerBlock = length-2;
  }
  if(cudaMalloc((void **) &in, size) != cudaSuccess){
    return;
  }

  if(cudaMalloc((void **) &out, size) != cudaSuccess){
    cudaFree(in);
    return;
  }

  cudaEventRecord(cpy_H2D_start);
  /* Copying array from host to device goes here */
  if(cudaMemcpy(in, input, size, cudaMemcpyHostToDevice) != cudaSuccess){
    cudaFree(in);
    cudaFree(out);
    return;
  };

  cudaEventRecord(cpy_H2D_end);
  cudaEventSynchronize(cpy_H2D_end);

  cudaEventRecord(comp_start);
  /*GPU computation*/
  for (size_t k = 0; k < iterations; k++) {
    /*Starting a kernel with each iteration to ensure synchronization
    * between blocks*/
    heattransfer<<<length-2, length-2>>>(in, out, length);
    // heattransfer2<<<length-2, threadePerBlock>>>(in, out, length, casePerBlock);
    temp = in;
    in = out;
    out = temp;
  }
  cudaEventRecord(comp_end);
  cudaEventSynchronize(comp_end);

  cudaEventRecord(cpy_D2H_start);
  /*copy result from device to host*/
  if(iterations%2 == 0){
    cudaMemcpy(output, in, size, cudaMemcpyDeviceToHost);
  } else{
    cudaMemcpy(output, out, size, cudaMemcpyDeviceToHost);
  }

  cudaEventRecord(cpy_D2H_end);
  cudaEventSynchronize(cpy_D2H_end);

  cudaFree(in);
  cudaFree(out);

  float time;
  cudaEventElapsedTime(&time, cpy_H2D_start, cpy_H2D_end);
  cout<<"Host to Device MemCpy takes "<<setprecision(4)<<time/1000<<"s"<<endl;

  cudaEventElapsedTime(&time, comp_start, comp_end);
  cout<<"Computation takes "<<setprecision(4)<<time/1000<<"s"<<endl;

  cudaEventElapsedTime(&time, cpy_D2H_start, cpy_D2H_end);
  cout<<"Device to Host MemCpy takes "<<setprecision(4)<<time/1000<<"s"<<endl;
}
