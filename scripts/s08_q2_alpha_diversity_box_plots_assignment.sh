# QIIME2 - Alpha-diversity box-plots
# Matthew Spriggs: 23Jan25
# Requires environment with QIIME2

# Crescent2 script
# Note: this script should be run on a compute node
# qsub script.sh

# PBS directives
#---------------

#PBS -N s08_q2_alpha_diversity_box_plots
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
echo "QIIME2: Alpha-diversity box-plots"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics"
results_folder="${base_folder}/results"
diversity_metrics_folder="${results_folder}/s07_diversity_metrics"

# Visualize relationships between alpha diversity and study metadata
# (uses some files created at the previous step)
qiime diversity alpha-group-significance \
--i-alpha-diversity "${diversity_metrics_folder}/faith_pd_vector.qza" \
--m-metadata-file "${base_folder}/data/tabsamplesheet.txt" \
--o-visualization "${results_folder}/s08_alpha_faith_pd_per_group.qzv"

qiime diversity alpha-group-significance \
--i-alpha-diversity "${diversity_metrics_folder}/evenness_vector.qza" \
--m-metadata-file "${base_folder}/data/tabsamplesheet.txt" \
--o-visualization "${results_folder}/s08_alpha_evenness_per_group.qzv"
qiime diversity alpha-group-significance \
--i-alpha-diversity "${diversity_metrics_folder}/shannon_vector.qza" \
--m-metadata-file "${base_folder}/data/tabsamplesheet.txt" \
--o-visualization "${results_folder}/s08_alpha_shannon_per_group.qzv"

# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID