#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-typing;

cnt=$(cat samples.txt | wc -l);

## reporting
GenRep=REPORTING/general-report.txt;

# (temp) variables

##### MLST typing via https://github.com/tseemann/mlst - Torsten Seemann #####

GENOMES=genomes;
MLST=60_mlst;

mkdir -p 60_mlst;


FILEin=samples.txt;

count0=1;
countS=$(cat "$FILEin" | wc -l);

while [ $count0 -le $countS ];do

SAMPLE=$(cat "$FILEin" | awk 'NR=='$count0);

INPUTdir="$GENOMES"/;

MLSTin="$GENOMES"/"$SAMPLE"_contigs.fa;
MLSTout="$MLST"/"$SAMPLE".mlst.csv;

	mlst "$MLSTin" --quiet --csv --nopath > "$MLSTout";

count0=$((count0+1));
done


exit 1

##### manual MLST calling from assembled genomes
#
#SYNOPSIS
#  Automatic MLST calling from assembled contigs
#USAGE
#  % mlst --list                                            # list known schemes
#  % mlst [options] <contigs.{fasta,gbk,embl}[.gz]          # auto-detect scheme
#  % mlst --scheme <scheme> <contigs.{fasta,gbk,embl}[.gz]> # force a scheme
#GENERAL
#  --help            This help
#  --version         Print version and exit(default ON)
#  --check           Just check dependencies and exit (default OFF)
#  --quiet           Quiet - no stderr output (default OFF)
#  --threads [N]     Number of BLAST threads (suggest GNU Parallel instead) (default '1')
#  --debug           Verbose debug output to stderr (default OFF)
#SCHEME
#  --scheme [X]      Don't autodetect, force this scheme on all inputs (default '')
#  --list            List available MLST scheme names (default OFF)
#  --longlist        List allelles for all MLST schemes (default OFF)
#  --exclude [X]     Ignore these schemes (comma sep. list) (default 'ecoli_2,abaumannii')
#OUTPUT
#  --csv             Output CSV instead of TSV (default OFF)
#  --json [X]        Also write results to this file in JSON format (default '')
#  --label [X]       Replace FILE with this name instead (default '')
#  --nopath          Strip filename paths from FILE column (default OFF)
#  --novel [X]       Save novel alleles to this FASTA file (default '')
#  --legacy          Use old legacy output with allele header row (requires --scheme) (default OFF)
#SCORING
#  --minid [n.n]     DNA %identity of full allelle to consider 'similar' [~] (default '95')
#  --mincov [n.n]    DNA %cov to report partial allele at all [?] (default '10')
#  --minscore [n.n]  Minumum score out of 100 to match a scheme (when auto --scheme) (default '50')
#PATHS
#  --blastdb [X]     BLAST database (default '/home/harde004/.conda/envs/POPPUNK/bin/../db/blast/mlst.fa')
#  --datadir [X]     PubMLST data (default '/home/harde004/.conda/envs/POPPUNK/bin/../db/pubmlst')
#HOMEPAGE
#  https://github.com/tseemann/mlst - Torsten Seemann




