#!/bin/bash -l
#SBATCH --job-name=Flumina-config-setup
#SBATCH --account="aap mr scicomp hpc ncah users"
#SBATCH --partition=scicomp-compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH -t 168:00:00
#SBATCH --export=none

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Read arguments from the Python script ---
new_reference_file=$1
run_mode=$2    # This will be "no_slurm"
num_threads=$3 # This will be the CPU count (e.g., "64")

# --- Define Paths ---
# This is the path to the Flumina code *as seen inside the container*
FLUMINA_CODE_PATH="/git/_github/Flumina"

# Check if the path exists
if [ ! -d "$FLUMINA_CODE_PATH" ]; then
    echo "FATAL ERROR: Flumina code path not found inside container at $FLUMINA_CODE_PATH"
    exit 1
fi

# --- Setup ---
if [[ -n "$new_reference_file" ]]; then
    echo "Using reference file: $new_reference_file"
fi

dd=$(date +"%Y-%m-%d_%H-%M-%S")
curdir=$(pwd)
flu_out=$curdir/flumina_out

# Copy and edit config file from the correct path
new_config=${curdir}/config_${dd}.cfg
new_rename=${curdir}/rename_${dd}.csv
cp "${FLUMINA_CODE_PATH}/config.cfg" ${new_config}

# Generate new rename file more robustly
printf "File,Sample\n" > ${new_rename}
# Correctly parse sample name using wildcards
sample_name=$(ls *_R1_*.fastq.gz | head -n 1 | awk -F_ '{print $1}')
echo "$sample_name,$sample_name" >> ${new_rename}

# Replace paths in the config file
sed -i "s#^READ_DIRECTORY=.*#READ_DIRECTORY=$curdir#" ${new_config}
sed -i "s#^RENAME_FILE=.*#RENAME_FILE=$new_rename#" ${new_config}
sed -i "s#^OUTPUT_DIRECTORY=.*#OUTPUT_DIRECTORY=$flu_out#" ${new_config}
sed -i "s@^METADATA=.*@#METADATA=''@" ${new_config}
sed -i "s@^GROUP_NAMES=.*@#GROUP_NAMES=''@" ${new_config}

# Replace reference file in the config file if provided
if [[ -n "$new_reference_file" ]]; then
    sed -i "s#^REFERENCE_FILE=.*#REFERENCE_FILE=${FLUMINA_CODE_PATH}/references/$new_reference_file#" ${new_config}
fi

# Check if running locally (from dvl_irma) or as a standalone Slurm job
if [ "$run_mode" == "no_slurm" ]; then
    echo "Script was run with bash. Not executing via slurm."
    sed -i "s@^CLUSTER_JOBS=.*@CLUSTER_JOBS=FALSE@" ${new_config}
    
    threads_to_use=${num_threads:-4}
    echo "Setting THREADS in config file to: $threads_to_use"
    sed -i "s@^THREADS=.*@THREADS=$threads_to_use@" ${new_config}
    
    # Run Flumina directly using 'bash' from the PATH
    cd "$FLUMINA_CODE_PATH" && bash flumina_nvsl.sh ${new_config}
else
    # This block is for running the script standalone, not from your Python pipeline
    echo "Script was run with sbatch. Submitting a new Slurm job for Flumina."
    sed -i "s@^THREADS=.*@THREADS=200@" ${new_config}
    sbatch --mem 650G --cpus-per-task=40 -W -D "$FLUMINA_CODE_PATH" "${FLUMINA_CODE_PATH}/flumina_nvsl.sh" ${new_config}
fi

# --- Post-processing and cleanup steps ---
# Only run these steps if the Snakemake workflow was successful and created the output directory
if [ -d "$flu_out/variant_analysis/aa_db" ]; then
    echo "Snakemake workflow completed. Performing post-processing..."
    
    mkdir -p "$flu_out/slurm"
    mv "${FLUMINA_CODE_PATH}/slurm"* "$flu_out/slurm/" 2>/dev/null
    mv "${curdir}/slurm"* "$flu_out/slurm/" 2>/dev/null

    sample_count=$(find "$flu_out/variant_analysis/aa_db/" -name "*.csv" | wc -l)
    analysis_file="$flu_out/variant_analysis/T271A_D701N_E627K.txt"

    echo "Number of samples in analysis: $sample_count" >> "$analysis_file"
    echo "" >> "$analysis_file"

    # Search for mutations of interest
    echo 'T271A' >> "$analysis_file"
    grep ".*PB2.*,271,.*T,A,YES" "$flu_out/variant_analysis/aa_db/"*.csv | awk -F, '{if (!($2 in max) || $10 > max[$2]) {max[$2] = $10; line[$2] = $2 " -- VAF " $10}} END {for (i in line) print line[i]}' >> "$analysis_file" || true
    echo 'D701N' >> "$analysis_file"
    grep ".*PB2.*,701,.*D,N,YES" "$flu_out/variant_analysis/aa_db/"*.csv | awk -F, '{if (!($2 in max) || $10 > max[$2]) {max[$2] = $10; line[$2] = $2 " -- VAF " $10}} END {for (i in line) print line[i]}' >> "$analysis_file" || true
    echo 'E627K' >> "$analysis_file"
    grep ".*PB2.*,627,.*E,K,YES" "$flu_out/variant_analysis/aa_db/"*.csv | awk -F, '{if (!($2 in max) || $10 > max[$2]) {max[$2] = $10; line[$2] = $2 " -- VAF " $10}} END {for (i in line) print line[i]}' >> "$analysis_file" || true
else
    echo "WARNING: Snakemake output directory not found. Skipping post-processing."
fi
