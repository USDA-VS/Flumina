#!/bin/bash
#SBATCH --job-name=Flumina-nvsl
#SBATCH -N 1
#SBATCH -p prod-compute-mem
#SBATCH -t 168:00:00


date

module purge
module load slurm
#module load anaconda3
source /project/shared/miniconda3/etc/profile.d/conda.sh

#source activate /project/shared/anaconda_env/Flumina
conda activate /project/shared/anaconda_env/Flumina
export PATH="/project/shared/anaconda_env/Flumina/bin:$PATH"

date
# Verify conda R is being used
echo "Rscript path: $(which Rscript)"
echo "R path: $(which R)"

 bash ~/git/_github/Flumina/Flumina ${1}

# End of file
