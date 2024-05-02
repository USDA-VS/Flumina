# Flumina

A pipeline for processing and calling high-frequency and low-frequency variants from Illumina sequence data for Influenza viruses

The pipeline accomplishes the following:

1) Organize raw read data
2) Remove adaptor contamination and trims low quality reads and bases
4) Assemble cleaned reads into consensus contigs 
5) Calls high-frequency variants using GATK4
6) Calls low-freuqency variants using LoFreq
7) Summarizes variant calling data
8) Link variants to curated amino acids of interest


# Quick installation instructions

First, clone this repository to your computer to obtain the setup files and run script. Or alternatively go to the green "Code" button in top right of this repository and select "download ZIP".

```bash
git clone https://github.com/flu-crew/Flumina.git
```

Second, change your working directory in the terminal to the downloaded repository. The key file here is the "environment.yaml" anaconda environment file, which must be present in the working directory being used. 

```bash
cd /PATH/TO/Flumina
```

The outside programs can be installed manually or more easily through the anaconda environment file provided (version numbers are provided in environment file for reporting and exact replication). To install with the environment file, the easiest and quickest way is to first install the Anaconda package manager. Anaconda can be downloaded and installed for different operating systems from https://anaconda.org. Miniconda is recommended as it has a smaller footprint (smaller size and fewer files). Once installed, you can create a new environment for Flumina by: 

```bash
conda env create -f environment.yaml -n Flumina
```

To use the environment, it must first be activated in your current terminal session or placed in your cluster job script. 

```bash
conda activate Flumina
```

If the environment is to be installed in a specific location, like a project directory on a cluster:

```bash
conda env create -f environment.yaml -p /PATH/TO/Flumina
```

```bash
conda activate /PATH/TO/Flumina
```


# Using Flumina


## Create renaming file 

Often the case with multiplexed samples in sequence capture projects, you will find that the names of the reads often are not the desired final names for the sample. PhyloProcessR offers a function to rename and organize all your samples given a spreadsheet of the file name and desired sample name. To create the renaming file, a .csv file is needed with only two columns: "File" and "Sample". An example is included in the setup-configuration_files folder in the main branch ("file_rename.csv"). 

The "File" column: the unique string that is part of the file name for the two read pairs, while excluding read and lane information. Example:

> ``AX1212_L001_R1.fastq.gz``

> ``AX1212_L001_R2.fastq.gz``

Are the two sets of reads for a given sample. Your "File" column value would then be:

> ``AX1212``


The "Sample" column: What you would like your sample name to be. This will be used up in all downstream analyses unless changed. Ensure that your samples all have unique names and are not contained within each other (e.g. Name_0 is contained within Name_01). Also exclude special characters and replace spaces with underscores. Hyphens are also ok. 
In this example, the "Sample" Column would be: 
>
>Influenza_virus_AX1212
>

An example is provided in the main repo (file_rename_example.csv)

## Setting up configuration file

Flumina uses a configuration file to keep track of the parameters and easily add new ones. They are included in an example config file in the main repo, "config.cfg"

```bash
#The directory where your raw reads are located
READ_DIRECTORY="/PATH-TO/Flumina/test_dataset"

#CSV with the file name that matches to both read pairs in the "File column" and sample name in the "Sample" column
RENAME_FILE="/PATH-TO/Flumina/example_file_rename.csv"

REFERENCE_FILE="/PATH-TO/Flumina_test/Flumina/ancestral_reference.fa"

#Whether to overwrite or not
OVERWRITE=FALSE

#number of threads to use
THREADS=6

#multi-job cluster mode, add in cluster job details. THREADS above becomes number of jobs. Set to FALSE to run without new jobs
CLUSTER_JOBS="sbatch -p priority --qos=vpru -A nadc_iav -D /PATH-TO/Flumina_test/Flumina --mem 40G --cpus-per-task=2"
```


## Running pipeline 

After setting up the file rename configuration file 

```bash
bash Flumina config.cfg
```

## Running pipeline with multi-job submission




# Upcoming features

1) Apptainer installation (Singularity)
2) Code refinement and speedups


