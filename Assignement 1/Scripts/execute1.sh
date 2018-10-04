#!/bin/bash
#SBATCH --workdir /scratch/swicky
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1G

echo TEST WITH 1 CORE
echo STARTING AT `date`

for (( i = 0; i < 100; i++ )); do
	./pi 1 100000000
done
echo FINISHED AT `date`
