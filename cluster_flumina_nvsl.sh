#!/bin/bash
#SBATCH --job-name=Flumina-config-setup
#SBATCH -N 1
#SBATCH -t 168:00:00

dd=`date +"%Y-%m-%d_%H-%M-%S"`
curdir=`pwd`
module load anaconda3
source activate /project/shared/anaconda_env/Flumina

# copy and edit config file
new_config=${curdir}/config_${dd}.cfg
new_rename=${curdir}/rename_${dd}.csv
cp ~/git/_github/Flumina/config.cfg ${new_config}

# generate new rename file, splitting on _ and grabbing the first field. Doesn't currently rename, but file is required
printf "File,Sample\n" > ${new_rename}
ls -1 *fastq.gz| awk -F_ '{print $1","$1}' >> ${new_rename}

# replace rename file and read directory in the config file
sed -i "s#^READ_DIRECTORY=.*#READ_DIRECTORY=$curdir#" ${new_config}
sed -i "s#^RENAME_FILE=.*#RENAME_FILE=$new_rename#" ${new_config}

#run Flumina
sbatch -D ~/git/_github/Flumina ~/git/_github/Flumina/flumina_nvsl.sh ${new_config}

