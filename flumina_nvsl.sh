#!/bin/bash
#SBATCH --job-name=Flumina-nvsl
#SBATCH -N 1
#SBATCH -p prod-compute-mem
#SBATCH -t 168:00:00


date

module purge
module load slurm
module load anaconda3

source activate /project/shared/anaconda_env/Flumina

bash ~/git/_github/Flumina/Flumina ${1}

date

# End of file

