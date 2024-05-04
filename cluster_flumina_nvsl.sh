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
sbatch -W -D ~/git/_github/Flumina ~/git/_github/Flumina/flumina_nvsl.sh ${new_config}

for i in ~/git/_github/Flumina/IRMA_results/*; do name=$(basename $i); mkdir -p $curdir/sample_gathering/$name; echo $name >> sample_list; done
while read i; do cp -r ~/git/_github/Flumina/BAM_files/$i $curdir/sample_gathering/$i/BAM_files; done < sample_list
while read i; do mkdir -p $curdir/sample_gathering/$i/IRMA-consensus-contigs; cp -v ~/git/_github/Flumina/IRMA-consensus-contigs/${i}.fasta $curdir/sample_gathering/$i/IRMA-consensus-contigs; done < sample_list
while read i; do cp -r ~/git/_github/Flumina/IRMA_results/$i $curdir/sample_gathering/$i/IRMA_results; done < sample_list
while read i; do cp -r ~/git/_github/Flumina/logs/$i $curdir/sample_gathering/$i/logs; done < sample_list
while read i; do cp -r ~/git/_github/Flumina/processed-reads/$i $curdir/sample_gathering/$i/processed-reads; done < sample_list
while read i; do cp -r ~/git/_github/Flumina/vcf_files/$i $curdir/sample_gathering/$i/vcf_files; done < sample_list
while read i; do mkdir -p $curdir/sample_gathering/$i/variant_analysis; cp -v ~/git/_github/Flumina/variant_analysis/aa_db/${i}.csv $curdir/sample_gathering/$i/variant_analysis; done < sample_list

mkdir -p $curdir/sample_gathering/run_${dd}
cp ~/git/_github/Flumina/slurm* $curdir/sample_gathering/run_${dd}
cp $curdir/config* $curdir/sample_gathering/run_${dd}
cp $curdir/rename* $curdir/sample_gathering/run_${dd}
cp $curdir/slurm* $curdir/sample_gathering/run_${dd}
cp ~/git/_github/Flumina/variant_analysis/*.txt $curdir/sample_gathering/run_${dd}
cp ~/git/_github/Flumina/variant_analysis/*.csv $curdir/sample_gathering/run_${dd}
