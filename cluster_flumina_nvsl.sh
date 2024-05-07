#!/bin/bash
#SBATCH --job-name=Flumina-config-setup
#SBATCH -N 1
#SBATCH -t 168:00:00

dd=`date +"%Y-%m-%d_%H-%M-%S"`
curdir=`pwd`
flu_out=$curdir/flumina_out
# module load anaconda3
# source activate /project/shared/anaconda_env/Flumina

# copy and edit config file
new_config=${curdir}/config_${dd}.cfg
new_rename=${curdir}/rename_${dd}.csv
cp ~/git/_github/Flumina/config.cfg ${new_config}

# generate new rename file, splitting on _ and grabbing the first field. Doesn't currently rename, but file is required
printf "File,Sample\n" > ${new_rename}
for i in $(ls *fastq.gz | awk -F_ '{print $1}'); do grep -q $i ${new_rename} || echo $i,$i >> ${new_rename}; done


# replace rename file and read directory in the config file
sed -i "s#^READ_DIRECTORY=.*#READ_DIRECTORY=$curdir#" ${new_config}
sed -i "s#^RENAME_FILE=.*#RENAME_FILE=$new_rename#" ${new_config}
sed -i "s#^OUTPUT_DIRECTORY=.*#OUTPUT_DIRECTORY=$flu_out#" ${new_config}

#run Flumina
sbatch -W -D ~/git/_github/Flumina ~/git/_github/Flumina/flumina_nvsl.sh ${new_config}

cd ./flumina_out
for i in ./IRMA_results/*; do name=$(basename $i); mkdir -p $flu_out/sample_gathering/$name; echo $name >> sample_list; done
while read i; do cp -r ./BAM_files/$i $flu_out/sample_gathering/$i/BAM_files; done < sample_list
while read i; do mkdir -p $flu_out/sample_gathering/$i/IRMA-consensus-contigs; cp -v ./IRMA-consensus-contigs/${i}.fasta $flu_out/sample_gathering/$i/IRMA-consensus-contigs; done < sample_list
while read i; do cp -r ./IRMA_results/$i $flu_out/sample_gathering/$i/IRMA_results; done < sample_list
while read i; do cp -r ./logs/$i $flu_out/sample_gathering/$i/logs; done < sample_list
while read i; do cp -r ./processed-reads/$i $flu_out/sample_gathering/$i/processed-reads; done < sample_list
while read i; do cp -r ./vcf_files/$i $flu_out/sample_gathering/$i/vcf_files; done < sample_list
while read i; do mkdir -p $flu_out/sample_gathering/$i/variant_analysis; cp -v ./variant_analysis/aa_db/${i}.csv $flu_out/sample_gathering/$i/variant_analysis; done < sample_list

mkdir -p $flu_out/sample_gathering/run_${dd}
mv ~/git/_github/Flumina/slurm* $flu_out/sample_gathering/run_${dd}
mv $curdir/config* $flu_out/sample_gathering/run_${dd}
mv $curdir/rename* $flu_out/sample_gathering/run_${dd}
mv $curdir/slurm* $flu_out/sample_gathering/run_${dd}
cp ./variant_analysis/*.txt $flu_out/sample_gathering/run_${dd}
cp ./variant_analysis/*.csv $flu_out/sample_gathering/run_${dd}
