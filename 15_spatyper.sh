#!/bin/bash

## spatyping will be on the first draft of the assembled genomes


##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-blast;

FILE=samples.txt;

## reporting
GenRep=REPORTING/general-report.txt;

workdir="$PWD";

export PATH=$PATH:/home/wbvr006/GIT/spatyper/;

scriptdir=/home/wbvr006/GIT/spatyper/;

mkdir -p databases;

# Install VirulenceFinder database with executable kma_index program

cd databases;
rm -rf spatyper_db;
## download and install latest virulencefinder database
git clone https://bitbucket.org/genomicepidemiology/spatyper_db.git
cd spatyper_db;
SPATYPER_DB=$(pwd)/;
cd "$workdir";

GENOMES=genomes;


mkdir -p 15_spatyper;
spaOUT=15_spatyper;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ $count0 -le $countS ];do

SAMPLE=$(cat "$FILE" | awk 'NR=='$count0 );

echo "sample=$SAMPLE";
	
rm -r "$spaOUT/$SAMPLE";
mkdir -p "$spaOUT/$SAMPLE";

spaIn="$GENOMES"/"$SAMPLE".fa;

	python3 "$scriptdir"/spatyper.py -i "$spaIn" -db "$SPATYPER_DB" -o "$spaOUT"/"$SAMPLE" -no_tmp False;

count0=$((count0+1));
done

exit 1

#spaTyper v1.0.0
#
#spaTyper - predicts the Staphylococcus aureus spa type from genome sequences
#Spa type sequences are used as queries to blast against a database from the genome sequences
#Subsequently, it matches the 5' and 3' ends of the spa type sequences that have 100% identity starting at position 1.
#
#
#Usage: spatyper.py <options>
#Ex: spatyper.py -i /path/to/isolate.fa.gz -db /path/to/spatyper_db/ -o /path/to/outdir
#
#
#For help, type: spatyper.py -h
#
#(amr-blast) wbvr006@lelycompute-01:/mnt/lely_scratch/wbvr006/BACT/Frank/MRSA39-4extra$ python3 /home/wbvr006/GIT/spatyper/spatyper.py -h
#usage: spatyper.py [-h] -i INPUTFILE [-db DATABASES] [-b BLASTPATH] [-o OUTDIR] [-no_tmp {True,False}] [-v]
#
#options:
#  -h, --help            show this help message and exit
#  -i INPUTFILE, --inputfile INPUTFILE
#                        FASTA files are accepted. Can be whole genome or contigs.
#  -db DATABASES, --databases DATABASES
#                        Path to the directory containing the database with the spa sequences.
#  -b BLASTPATH, --blastPath BLASTPATH
#                        Path to blast directory
#  -o OUTDIR, --outdir OUTDIR
#                        Output directory.
#  -no_tmp {True,False}, --remove_tmp {True,False}
#                        Remove temporary files after run. Default=True.
#  -v, --version         show program's version number and exit
















