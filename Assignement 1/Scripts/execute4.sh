#!/bin/bash
#SBATCH --workdir /scratch/swicky
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 1G

echo TEST WITH 4 CORES
echo STARTING AT `date`

for (( i = 0; i < 100; i++ )); do
	./pi 4 100000000
done
echo FINISHED AT `date`
