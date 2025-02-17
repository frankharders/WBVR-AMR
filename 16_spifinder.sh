#!/bin/bash

## spatyping will be on the first draft of the assembled genomes


##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate pip3;

FILE=samples.txt;

workdir="$PWD";

scriptdir='/home/wbvr006/GIT/spifinder/';

cd databases;
rm -rf spafinder_db;
## download and install latest virulencefinder database
git clone https://bitbucket.org/genomicepidemiology/spifinder_db.git
cd spifinder_db;
SPIFINDER_DB=$(pwd)/;
python3 INSTALL.py kma_index

cd "$workdir";

GENOMES=genomes;

mkdir -p 16_spifinder;

## reporting
GenRep=REPORTING/general-report.txt;


count0=1;
countS=$(cat "$FILE" | wc -l);

while [ $count0 -le $countS ];do

	SAMPLE=$(cat "$FILE" | awk 'NR=='$count0 );

echo "sample=$SAMPLE";

spiInC="$GENOMES"/"$SAMPLE".fa;
mkdir -p 16_spifinder/"$SAMPLE";
spiOUTC=16_spifinder/"$SAMPLE"/;


	python3 "$scriptdir"/spifinder.py -i "$spiInC" -p "$SPIFINDER_DB" -o "$spiOUTC" -mp blastn -x;

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
















