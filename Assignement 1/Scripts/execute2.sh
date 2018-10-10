#!/bin/bash
#SBATCH --workdir /scratch/swicky
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 1G

echo TEST WITH 2 CORES
echo STARTING AT `date`

for (( i = 0; i < 100; i++ )); do
	./integral 2 200000000 5 9
done
echo FINISHED AT `date`
