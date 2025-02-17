#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-speciesfinder;

scriptdir=/home/wbvr006/GIT/kmerfinder/;
DB=/home/wbvr006/home_db/kmerfinder_db/bacteria/bacteria.ATG;
TAX=/home/wbvr006/home_db/kmerfinder_db/bacteria/bacteria.tax;
GENOMES="$PWD"/genomes;

speciesLog=REPORTING/SamplesSpecies.log;

rm "$speciesLog";
mkdir -p 11_kmerfinder;

KMER=11_kmerfinder;

count0=1
countW=$(cat samples.txt | wc -l);

while [ $count0 -le $countW ];do

SAMPLE=$(cat samples.txt | awk 'NR=='$count0);

mkdir -p "$KMER"/"$SAMPLE";

FILEin="$GENOMES"/"$SAMPLE".fa;
DIRout="$KMER"/"$SAMPLE";


python "$scriptdir"/kmerfinder.py -i "$FILEin" -db "$DB" -o "$DIRout" -tax "$TAX" -x;

speciesCnt=1;
#speciesCnt=$(cat "$DIRout"/results.txt | sed '1d' | cut -f19 -d$'\t' | sort -u | wc -l);
#species=$(cat "$DIRout"/results.txt | sed '1d' | cut -f19 -d$'\t' | sort -u);
species=$(cat "$DIRout"/results.txt | sed '1d' | cut -f6,19 -d$'\t' | sort -k1,1 -nr | head -n1 | cut -f2 -d$'\t');



if [ "$speciesCnt" == 1 ];then

echo -e "$SAMPLE\t$species" >> "$speciesLog";

else

echo -e "$SAMPLE\t999" >> "speciesLog";

fi

count0=$((count0+1));
done

exit 1

##### kmerfinder
#
#usage: kmerfinder.py [-h] [-i INFILE [INFILE ...]] [-batch BATCH_FILE]
#                     [-o OUTPUT_FOLDER] [-db DB_PATH] [-db_batch DB_BATCH]
#                     [-kma KMA_ARGUMENTS] [-tax TAX] [-x] [-kp KMA_PATH] [-q]
#
#optional arguments:
#  -h, --help            show this help message and exit
#  -i INFILE [INFILE ...], --infile INFILE [INFILE ...]
#                        FASTA(.gz) or FASTQ(.gz) file(s) to run KmerFinder on.
#  -batch BATCH_FILE, --batch_file BATCH_FILE
#                        OPTION NOT AVAILABLE:file with multipe files listed
#  -o OUTPUT_FOLDER, --output_folder OUTPUT_FOLDER
#                        folder to store the output
#  -db DB_PATH, --db_path DB_PATH
#                        path to database and database file
#  -db_batch DB_BATCH, --db_batch DB_BATCH
#                        OPTION NOT AVAILABLE:file with paths to multiple
#                        databases
#  -kma KMA_ARGUMENTS, --kma_arguments KMA_ARGUMENTS
#                        OPTION NOT AVAILABLE:Extra arguments for KMA
#  -tax TAX, --tax TAX   taxonomy file with additional data for each template
#                        in all databases (family, taxid and organism)
#  -x, --extended_output
#                        Give extented output with taxonomy information
#  -kp KMA_PATH, --kma_path KMA_PATH
#                        Path to kma program
#  -q, --quiet
#
######
