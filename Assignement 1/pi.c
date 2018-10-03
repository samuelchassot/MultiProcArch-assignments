/*
============================================================================
Filename    : pi.c
Author      : Samuel Chassot and Simon Wicky
SCIPER		: 270955 and 260589
============================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include "utility.h"

double calculate_pi (int num_threads, int samples);

int main (int argc, const char *argv[]) {

    int num_threads, num_samples;
    double pi;

    if (argc != 3) {
		printf("Invalid input! Usage: ./pi <num_threads> <num_samples> \n");
		return 1;
	} else {
        num_threads = atoi(argv[1]);
        num_samples = atoi(argv[2]);
	}

    set_clock();
    pi = calculate_pi (num_threads, num_samples);

    printf("- Using %d threads: pi = %.15g computed in %.4gs.\n", num_threads, pi, elapsed_time());

    return 0;
}


double calculate_pi (int num_threads, int samples) {
    omp_set_num_threads(num_threads);
    double pi;
    double nb_points = 0;
    double* result[num_threads];
    rand_gen rand = init_rand();

    #pragma omp parallel private(rand)
    {
        result[omp_get_thread_num()] = calloc(1, sizeof(double));
    }
    


    #pragma omp parallel for
    for (size_t i = 0; i < samples; ++i) {
        double x = next_rand(rand);
        double y = next_rand(rand);
        if (x*x + y*y < 1){
            *result[omp_get_thread_num()] += 1;
        }
    }
    for (size_t i = 0; i < num_threads; ++i) {
    	nb_points += *result[i];
    }
    pi = (4 * nb_points) / samples;

    return pi;
}
