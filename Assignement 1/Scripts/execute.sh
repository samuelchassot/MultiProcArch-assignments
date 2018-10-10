#!/bin/bash
#SBATCH --workdir /scratch/swicky
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem 1G
echo STARTING AT `date`

./integral 1 100000000 5 9
./integral 2 100000000 5 9
./integral 4 100000000 5 9
./integral 8 100000000 5 9
./integral 16 100000000 5 9
echo FINISHED AT `date`
