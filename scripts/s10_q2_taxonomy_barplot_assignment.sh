#!/bin/bash
# QIIME2 - Taxonomy barplot
# Matthew Spriggs: 13Dec24
# Requires environment with QIIME2

# Assumes that the resources folder contains the claccifier recommended by QIIME2 for 515F/806R 16S region.
# The classifier was trained on Greengenes 13.8 99% OTUs ( see https://docs.qiime2.org/2022.8/data-resources/ )
# The classifier was downloaded once using the code like this:
# cd "${resources_folder}"
# wget https://data.qiime2.org/2022.8/common/gg-13-8-99-515-806-nb-classifier.qza

# PBS directives
#---------------

#PBS -N s10_q2_taxonomy_barplot_assignment
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
module load QIIME2/2022.8

# Start message
echo "QIIME2: Taxonomy barplot"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics"
results_folder="${base_folder}/results"
resources_folder="${base_folder}/resources"

# Assign taxonomy to sequences
qiime feature-classifier classify-sklearn \
--i-classifier "${resources_folder}/gg-13-8-99-515-806-nb-classifier.qza" \
--i-reads "${results_folder}/s04_rep_seqs_dada2.qza" \
--o-classification "${results_folder}/s10_taxonomy.qza"

# Show taxonimies assigned to each ASV
qiime metadata tabulate \
--m-input-file "${results_folder}/s10_taxonomy.qza" \
--o-visualization "${results_folder}/s10_taxonomy.qzv"

# Make taxonomy barplot
qiime taxa barplot \
--i-table "${results_folder}/s06b_rarefied_table.qza" \
--i-taxonomy "${results_folder}/s10_taxonomy.qza" \
--m-metadata-file "${base_folder}/data/tabsamplesheet.txt" \
--o-visualization "${results_folder}/s10_taxa_bar_plot.qzv"

# tabsamplesheet is an intermediate file, created in s06 of samplesheet.csv
# it can be deleted here

echo ""
echo "Cleaning up intermediate file(s)"
rm "${base_folder}/data/tabsamplesheet.txt"

# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID

