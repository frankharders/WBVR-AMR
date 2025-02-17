#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-virulencefinder;

## change (2022-05-27)
## due to a error in using the "$species" variable the script is altered
## if species isn't found in point mutations db list the script will be run without this variable
## change 2404-01-05
## create virulence db in working dir for backup
## import species via kmerfinder output per sample
## can be run also outsite the whole pipeline
## tidy up
## end


# bizzy
# kijken naar de layout mbt weergeven results.
# werken we vanuit de contigs? 
# optioneel reads of reads toevoegen en optioneel kijken naar de results daarvan.
# afkap waarden positief?
# wat te doen met partieel?

cnt=$(cat samples.txt | wc -l);

## sample file
FILE=samples.txt;

workdir="$PWD";

## renew database before use

## reporting
GenRep="$REPORTING"/general-report.txt;
ToDay=$(date +%Y-%m-%d-%T);

mkdir -p databases;

# Install VirulenceFinder database with executable kma_index program
cd databases;
rm -rf virulencefinder_db;
## download and install latest virulencefinder database
git clone https://bitbucket.org/genomicepidemiology/virulencefinder_db.git;
cd virulencefinder_db;
VIRULENCE_DB=$(pwd)/;
python3 INSTALL.py kma_index;

cd "$workdir";

# create directory for output
mkdir -p 13_virulencefinder;

VIRULENCE=13_virulencefinder;

##  virulencefinder variables
L=0.6;
T=0.8;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");
	echo -e "$SAMPLE";

mkdir -p "$VIRULENCE"/"$SAMPLE";
mkdir -p "$VIRULENCE"/"$SAMPLE"/reads;
mkdir -p "$VIRULENCE"/"$SAMPLE"/contigs;


OUTDIR1="$VIRULENCE"/"$SAMPLE"/reads;
OUTDIR2="$VIRULENCE"/"$SAMPLE"/contigs;

fastaIn=genomes/"$SAMPLE".fa;
fastqIn1=02_polished/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
fastqIn2=02_polished/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;

LOG1=LOGS/"$SAMPLE".virulencefinder.contigs.log;
LOG2=LOGS/"$SAMPLE".virulencefinder.reads.log;

## virulencefinder on reads
virulencefinder.py -i "$fastqIn1" "$fastqIn2" -o "$OUTDIR1" -p "$VIRULENCE_DB" -l "$L" -t "$T" -x > "$LOG2" 2>&1;

cat "$OUTDIR1"/results_tab.tsv > "$VIRULENCE"/"$SAMPLE"_results_tab_reads.tsv;
cat "$OUTDIR1"/Virulence_genes.fsa > "$VIRULENCE"/"$SAMPLE"_virulence_genes_reads.fsa;

## virulencefinder on contigs
virulencefinder.py -i "$fastaIn" -o "$OUTDIR2" -p "$VIRULENCE_DB" -l "$L" -t "$T" -x > "$LOG1" 2>&1;

cat "$OUTDIR2"/results_tab.tsv > "$VIRULENCE"/"$SAMPLE"_results_tab_contigs.tsv;
cat "$OUTDIR2"/Virulence_genes.fsa > "$VIRULENCE"/"$SAMPLE"_virulence_genes_contigs.fsa;

count0=$((count0+1));
done

exit 1


##### virulencefinder
#
#usage: virulencefinder.py [-h] -i INFILE [INFILE ...] [-o OUTDIR] [-tmp TMP_DIR] [-mp METHOD_PATH] [-p DB_PATH] [-d DATABASES] [-l MIN_COV] [-t THRESHOLD] [-x] [--speciesinfo_json SPECIESINFO_JSON] [-q]
#
#options:
#  -h, --help            show this help message and exit
#  -i INFILE [INFILE ...], --infile INFILE [INFILE ...]
#                        FASTA or FASTQ input files.
#  -o OUTDIR, --outputPath OUTDIR
#                        Path to blast output
#  -tmp TMP_DIR, --tmp_dir TMP_DIR
#                        Temporary directory for storage of the results from the external software.
#  -mp METHOD_PATH, --methodPath METHOD_PATH
#                        Path to method to use (kma or blastn)
#  -p DB_PATH, --databasePath DB_PATH
#                        Path to the databases
#  -d DATABASES, --databases DATABASES
#                       Databases chosen to search in - if non is specified all is used
#  -l MIN_COV, --mincov MIN_COV
#                        Minimum coverage
#  -t THRESHOLD, --threshold THRESHOLD
#                        Minimum hreshold for identity
#  -x, --extented_output
#                        Give extented output with allignment files, template and query hits in fasta and a tab seperated file with gene profile results
#  --speciesinfo_json SPECIESINFO_JSON
#                        Argument used by the cge pipeline. It takes a list in json format consisting of taxonomy, from domain -> species. A database is chosen based on the taxonomy.
#  -q, --quiet
#
#####

