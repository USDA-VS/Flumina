#!/bin/bash
#SBATCH --job-name=Flumina-config-setup
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH -t 168:00:00

new_reference_file=$1

# if altered reference file is provided, echo it
if [[ -n $new_reference_file ]]; then
    echo "Using reference file: $new_reference_file"
fi

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
sed -i "s@^METADATA=.*@#METADATA=''@" ${new_config}
sed -i "s@^GROUP_NAMES=.*@#GROUP_NAMES=''@" ${new_config}

# replace reference file in the config file if new_reference_file is provided
if [[ -n $new_reference_file ]]; then
    sed -i "s#^REFERENCE_FILE=.*#REFERENCE_FILE=./references/$new_reference_file#" ${new_config}
fi

# check if ran with bash (from inside dvl_irma) or sbatch (standalone)
if [ "$2" == "no_slurm" ]; then
    echo "Script was run with bash. Not executing via slurm"
    sed -i "s@^CLUSTER_JOBS=.*@CLUSTER_JOBS=FALSE@" ${new_config}
    sed -i "s@^THREADS=.*@THREADS=4@" ${new_config}
    #run Flumina
    cd ~/git/_github/Flumina && /usr/bin/bash ~/git/_github/Flumina/flumina_nvsl.sh ${new_config}
else
    echo "Script was run with sbatch"
    /cm/shared/apps/slurm/current/bin/sbatch --mem 700G --cpus-per-task=40 -W -D ~/git/_github/Flumina ~/git/_github/Flumina/flumina_nvsl.sh ${new_config}
fi



# cd ./flumina_out
# for i in ./BAM_files/*; do name=$(basename $i); mkdir -p $flu_out/sample_gathering/$name; echo $name >> sample_list; done
# while read i; do cp -r ./BAM_files/$i $flu_out/sample_gathering/$i/BAM_files; done < sample_list
# while read i; do mkdir -p $flu_out/sample_gathering/$i/IRMA-consensus-contigs; cp -v ./IRMA-consensus-contigs/${i}.fasta $flu_out/sample_gathering/$i/IRMA-consensus-contigs; done < sample_list
# while read i; do cp -r ./IRMA_results/$i $flu_out/sample_gathering/$i/IRMA_results; done < sample_list
# while read i; do cp -r ./logs/$i $flu_out/sample_gathering/$i/logs; done < sample_list
# while read i; do cp -r ./processed-reads/$i $flu_out/sample_gathering/$i/processed-reads; done < sample_list
# while read i; do cp -r ./vcf_files/$i $flu_out/sample_gathering/$i/vcf_files; done < sample_list
# while read i; do mkdir -p $flu_out/sample_gathering/$i/variant_analysis; cp -v ./variant_analysis/aa_db/${i}.csv $flu_out/sample_gathering/$i/variant_analysis; done < sample_list
# while read i; do grep "$i" $flu_out/variant_analysis/curated_amino_acids.txt > $flu_out/sample_gathering/"$i"/variant_analysis/"$i"_curated_amino_acids.txt; done < sample_list

mkdir -p $flu_out/slurm
mv ~/git/_github/Flumina/slurm* $flu_out/slurm
mv $curdir/slurm* $flu_out/slurm
# mv $curdir/config* $flu_out/sample_gathering/run_${dd}
# mv $curdir/rename* $flu_out/sample_gathering/run_${dd}
# cp ./variant_analysis/*.txt $flu_out/sample_gathering/run_${dd}
# cp ./variant_analysis/*.csv $flu_out/sample_gathering/run_${dd}
# mkdir $flu_out/sample_gathering/run_${dd}/slurm_out
# mv $flu_out/sample_gathering/run_${dd}/slurm* $flu_out/sample_gathering/run_${dd}/slurm_out

grep -l ".*PB2.*,271,.*T,A,YES" $flu_out/variant_analysis/aa_db/*.csv | awk -F/ '{ gsub(".csv", "", $NF); print $NF }' > $flu_out/variant_analysis/T271A.txt
grep -l ".*PB2.*,701,.*D,N,YES" $flu_out/variant_analysis/aa_db/*.csv | awk -F/ '{ gsub(".csv", "", $NF); print $NF }' > $flu_out/variant_analysis/D701N.txt
grep -l ".*PB2.*,627,.*E,K,YES" $flu_out/variant_analysis/aa_db/*.csv | awk -F/ '{ gsub(".csv", "", $NF); print $NF }' > $flu_out/variant_analysis/E627K.txt