#!/bin/bash
#SBATCH --job-name=Flumina-test
#SBATCH -N 1
#SBATCH -t 168:00:00


date

module load anaconda3

source activate /project/shared/anaconda_env/Flumina

bash ~/git/_github/Flumina/Flumina ~/git/_github/Flumina/config.cfg

date

# End of file

