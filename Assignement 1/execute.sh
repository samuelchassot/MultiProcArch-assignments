#!/bin/bash
#SBATCH --workdir /scratch/swicky
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem 1G
echo STARTING AT `date`

./pi 1 100000000
./pi 2 100000000
./pi 4 100000000
./pi 8 100000000
./pi 16 100000000
echo FINISHED AT `date`
