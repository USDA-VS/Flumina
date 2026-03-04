#!/bin/bash -l
#SBATCH --job-name=Flumina-nvsl
#SBATCH --account="aap mr scicomp hpc cnah users" 
#SBATCH --partition=scicomp-compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=100G
#SBATCH -t 168:00:00
#SBATCH --export=none

date

source /usr/local/miniforge3/etc/profile.d/conda.sh

# Activate the dedicated Flumina environment
conda activate Flumina

# FIXED: Changed ~/git to the absolute container path /git
bash /git/_github/Flumina/Flumina ${1}

date

# End of file
