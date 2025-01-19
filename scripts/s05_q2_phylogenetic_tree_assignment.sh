# QIIME2 - Phylogenetic tree
# Matthew Spriggs: 12Dec24
# Requires environment with QIIME2

# PBS directives
#---------------

#PBS -N s05_q2_phylogenetic_tree_assignment
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
echo "QIIME2: Phylogenetic tree"
date
echo ""

# Folders
# Base folder 
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics"
results_folder="${base_folder}/results"

# Perform multiple alignments and build phylogenetic trees
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences "${results_folder}/s04_rep_seqs_dada2.qza" \
  --o-alignment "${results_folder}/s05_aligned_rep_seqs.qza" \
  --o-masked-alignment "${results_folder}/s05_masked_aligned_rep_seqs.qza" \
  --o-tree "${results_folder}/s05_unrooted_tree.qza" \
  --o-rooted-tree "${results_folder}/s05_rooted_tree.qza"

# --- Export tree dta for plotting outside QIIME2 --- #

# Tree files are stored in a separate sub-folder in Results folder.
# They can be used to plot trees in several online tree viewers.
# For instance, tree.nwk file can be viewed using NCBI tree viewer
# https://www.ncbi.nlm.nih.gov/tools/treeviewer/

# NCBI tree viewer upload link:
# https://www.ncbi.nlm.nih.gov/projects/treeview/tv.html?appname=ncbi_tviewer&renderer=radial&openuploaddialog

# Export tree as tree.nwk
qiime tools export \
  --input-path "${results_folder}/s05_rooted_tree.qza" \
  --output-path "${results_folder}/s05_phylogenetic_tree"

# Export masked alignment as aligned-dna-sequences.fasta
# this fasta is not used by NCBI tree viewer, but may be used by other viewers
qiime tools export \
  --input-path "${results_folder}/s05_masked_aligned_rep_seqs.qza" \
  --output-path "${results_folder}/s05_phylogenetic_tree"

# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID