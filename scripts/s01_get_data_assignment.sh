#!/bin/bash
# Download files from NCBI SRA
# Matthew Spriggs: 18Jan2025

# PBS directives
#---------------

#PBS -N s01_get_data
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M matthew.spriggs.452@cranfield.ac.uk

#===============
#PBS -j oe
#PBS -v "CUDA_VISIBLE_DEVICES="
#PBS -W sandbox=PRIVATE
#PBS -k n
ln -s $PWD $PBS_O_WORKDIR/$PBS_JOBID
## Change to working directory
cd $PBS_O_WORKDIR
## Calculate number of CPUs and GPUs
export cpus=`cat $PBS_NODEFILE | wc -l`
## Load production modules
module use /apps2/modules/all
## =============

# Stop at runtime errors
set -e

# Load required modules
module load FastQC/0.11.9-Java-11
module load MultiQC/1.12-foss-2021b

# Base folder 
local_folder="/Users/mspriggs/Documents/Applied_Bioinformatics/modules/bioinformatics_in_epigenetics_proteomics_and_metagenomics/metagenomics_assay"
base_folder="${local_folder}/metagenomics"

# Start message
echo "Started downloading FASTQ files from SRA"
date
echo ""

# Folders
sra_folder="${base_folder}/tools/sratoolkit.3.1.1-ubuntu64/bin"
data_folder="${base_folder}/data"

# List of SRA IDs
sra_ids=$(awk -F, 'NR > 1 {print $1}' "${base_folder}/data/samplesheet.csv")

# Loop over ids
for id in $sra_ids
do
	echo "${id}"
	"${sra_folder}/fasterq-dump" $id --split-files --skip-technical --outdir "${data_folder}"
	echo ""
done

# Completion message
echo ""
echo "Done"
date

# Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID


