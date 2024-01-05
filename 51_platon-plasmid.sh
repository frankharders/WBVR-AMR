#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-platon;

## 20240105 edit script renew platon database before every run
## tidy the scripts
## end


cnt=$(cat samples.txt | wc -l);

## reporting
GenRep=REPORTING/general-report.txt;

workdir="$PWD";

mkdir -p databases;
mkdir -p 51_platon;

cd databases;
# renew database
wget https://zenodo.org/record/4066768/files/db.tar.gz;
tar -xzf db.tar.gz;
rm db.tar.gz;

cd "$workdir";

# (temp) variables
DEPTH=100;
MINlen="$CONTIGLENGTH";
MINcov=0;
NODES=24;

DBin=databases/db/;
GENOME="$PWD"/genomes/;

count0=1;
countS=$(cat samples.txt | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat samples.txt | awk 'NR=='"$count0");
	echo -e "$SAMPLE";

GENOMEin="$GENOME"/"$SAMPLE"'_contigs.fa';
DIRout=51_platon;
	platon --db "$DBin" --prefix "$SAMPLE" --output "$DIRout" --threads "$NODES" --verbose "$GENOMEin";

count0=$((count0+1));
done
exit 1


##### platon
#usage: platon [--db DB] [--prefix PREFIX] [--output OUTPUT] [--mode {sensitivity,accuracy,specificity}] [--characterize] [--help] [--verbose] [--threads THREADS] [--version] <genome>
#
#Identification and characterization of bacterial plasmid contigs from short-read draft assemblies.
#
#Input / Output:
#  <genome>              draft genome in fasta format
#  --db DB, -d DB        database path (default = <platon_path>/db)
#  --prefix PREFIX, -p PREFIX
#                        Prefix for output files
#  --output OUTPUT, -o OUTPUT
#                        Output directory (default = current working directory)
#
#Workflow:
#  --mode {sensitivity,accuracy,specificity}, -m {sensitivity,accuracy,specificity}
#                        applied filter mode: sensitivity: RDS only (>= 95% sensitivity); specificity: RDS only (>=99.9% specificity); accuracy: RDS & characterization heuristics
#                        (highest accuracy) (default = accuracy)
#  --characterize, -c    deactivate filters; characterize all contigs
#
#General:
#  --help, -h            Show this help message and exit
#  --verbose, -v         Print verbose information
#  --threads THREADS, -t THREADS
#                        Number of threads to use (default = number of available CPUs)
#  --version             show program's version number and exit
#
#Citation:
#Schwengers O., Barth P., Falgenhauer L., Hain T., Chakraborty T., & Goesmann A. (2020).
#Platon: identification and characterization of bacterial plasmid contigs in short-read draft assemblies exploiting protein sequence-based replicon distribution scores.
#Microbial Genomics, 95, 295. https://doi.org/10.1099/mgen.0.000398
#
#GitHub:
#https://github.com/oschwengers/platon
#
#####

