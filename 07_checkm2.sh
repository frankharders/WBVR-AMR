#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate checkm2;

## change 2024-12-14
## added script to pipeline for QC purposes assembled genomes
## end

## reporting
GenRep="$REPORTING"/general-report.txt;
ToDay=$(date +%Y-%m-%d-%T);

# create directory for output
mkdir -p 07_checkm2;

CHECKM2=07_checkm2;
INPUT=genomes/;
EXT=fa;
NODES=24;
DB=/home/wbvr006/home_db/checkm2/CheckM2_database/uniref100.KO.1.dmnd;


checkm2 predict --threads "$NODES" --input "$INPUT" --output-directory "$CHECKM2" --force --database_path "$DB" --allmodels -x "$EXT";


exit 1


##### checkm2
#
#
#Predict the completeness and contamination of genome bins in a folder. Example usage:
#
#        checkm2 predict --threads 30 --input <folder_with_bins> --output-directory <output_folder>
#
#optional arguments:
#  -h, --help            show this help message and exit
#  --debug               output debug information
#  --version             output version information and quit
#  --quiet               only output errors
#  --lowmem              Low memory mode. Reduces DIAMOND blocksize to significantly reduce RAM usage at the expense of longer runtime
#
#required arguments:
#  --input INPUT [INPUT ...], -i INPUT [INPUT ...]
#                        Path to folder containing MAGs or list of MAGS to be analyzed
#  --output-directory OUTPUT_DIRECTORY, --output_directory OUTPUT_DIRECTORY, -o OUTPUT_DIRECTORY
#                        Path output to folder
#
#additional arguments:
#  --general             Force the use of the general quality prediction model (gradient boost)
#  --specific            Force the use of the specific quality prediction model (neural network)
#  --allmodels           Output quality prediction for both models for each genome.
#  --genes               Treat input files as protein files. [Default: False]
#  -x EXTENSION, --extension EXTENSION
#                        Extension of input files. [Default: .fna]
#  --tmpdir TMPDIR       specify an alternative directory for temporary files
#  --force               overwrite output directory [default: do not overwrite]
#  --resume              Reuse Prodigal and DIAMOND results found in output directory [default: not set]
#  --threads num_threads, -t num_threads
#                        number of CPUS to use [default: 1]
#  --stdout              Print results to stdout [default: write to file]
#  --remove_intermediates
#                        Remove all intermediate files (protein files, diamond output) [default: don't]
#  --ttable ttable       Provide a specific progidal translation table for bins [default: automatically determine either 11 or 4]
#  --database_path DATABASE_PATH
#                        Provide a location for the CheckM2 database for a given predict run [default: use either internal path set via <checkm2 database> or CHECKM2DB environmental variable]
#  --dbg_cos             DEBUG: write cosine similarity values to file [default: don't]
#  --dbg_vectors         DEBUG: dump pickled feature vectors to file [default: don't]
#
#
#