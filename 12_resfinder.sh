#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate pip3;

## change (2022-05-27)
## due to a error in using the "$species" variable the script is altered
## if species isn't found in point mutations db list the script will be run without this variable

## change (2023-10-19)
## species will be found with the use of kmerfinder, output will be used for finding the appropiate species name for resfinder
## this speciesLoopUp.log file can be found in the root of the resfinder folder ~/GIT/resfinder


# bizzy
# kijken naar de layout mbt weergeven results.
# werken we vanuit de contigs? 
# optioneel reads of reads toevoegen en optioneel kijken naar de results daarvan.
# afkap waarden positief?
# wat te doen met partieel?



############################################### NEW 10-11-2023

#!/bin/bash
##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)"; 
conda activate pip3;

WORKDIR="$PWD";

# Create environment
python3 -m venv resfinder_env;

# Activate environment
source resfinder_env/bin/activate;

pip install resfinder

# get rid of the old databases before new analysis

rm -rf "$WORKDIR"/databases;

mkdir -p ./databases;

cd ./databases;

git clone https://bitbucket.org/genomicepidemiology/resfinder_db/;
cd "$WORKDIR"/databases/resfinder_db/;
python3 INSTALL.py;

cd "$WORKDIR"/databases;
git clone https://bitbucket.org/genomicepidemiology/pointfinder_db/;
cd "$WORKDIR"/databases/pointfinder_db/;
python3 INSTALL.py;

cat config | grep -v '#' | cut -f1 -d$'\t' > dir.lst;

countP=1;
countD=$(cat dir.lst | wc -l);

while [ $countP -le $countD ];do

species=$(cat dir.lst | awk 'NR=='$countP);
	echo -e "species=$species";

	cd "$WORKDIR"/databases/pointfinder_db/;
	mkdir -p "$WORKDIR"/databases/pointfinder_db/"$species";
	kma_index -i "$WORKDIR"/databases/pointfinder_db/"$species"/*.fsa -o "$WORKDIR"/databases/pointfinder_db/"$species"/"$species";

countP=$((countP+1));
done

cd "$WORKDIR"/databases;
git clone https://bitbucket.org/genomicepidemiology/disinfinder_db/;
cd "$WORKDIR"/databases/disinfinder_db/;
python3 INSTALL.py;

export CGE_RESFINDER_RESGENE_DB="./databases/resfinder_db";
export CGE_RESFINDER_RESPOINT_DB="./databases/pointfinder_db";
export CGE_DISINFINDER_DB="./databases/disinfinder_db";

cd "$WORKDIR";

FILE=samples.txt;
# (temp) variables

mkdir -p "$PWD"/12_resfinder;

GENOME="$PWD"/genomes/;
POLISHED="$PWD"/02_polished/;


count0=1;
countL=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countL" ];do 

SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");

rm -rf 12_resfinder/"$SAMPLE";

mkdir -p 12_resfinder/"$SAMPLE"/;
mkdir -p 12_resfinder/"$SAMPLE"/contigs;
mkdir -p 12_resfinder/"$SAMPLE"/reads;


READSin1="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
READSin2="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;

CONTIGSin="$GENOME"/"$SAMPLE"_contigs.fa;

OUTdirContigs=12_resfinder/"$SAMPLE"/contigs;
OUTdirReads=12_resfinder/"$SAMPLE"/reads;

KMAres="$WORKDIR"/databases/resfinder_db/;
KMApoint="$WORKDIR"/databases/pointfinder_db/;
KMAdis="$WORKDIR"/databases/disinfinder_db/;

speciesTemp='';
speciesTemp=$(cat "$WORKDIR"/REPORTING/SamplesSpecies.log | grep "$SAMPLE" | cut -f2 -d$'\t');

# will not be used we test this first by using the kmer finder species which is printed in a file in the directory REPORTING of the project
#speciesInUse=$(cat "$WORKDIR"/speciesLookUp.tab | grep -i "$speciesTemp" | head -n1 | cut -f1 -d$'\t');

#quote="'";

#species=$quote;
#species+=$speciesTemp;
#species+=$quote;




echo -e "\n";
echo -e "\n";
echo -e "\n";
echo -e "\n";
echo -e "$SAMPLE, speciesTemp=$speciesTemp";
echo -e "\n";
echo -e "\n";
echo -e "\n";

python -m resfinder --nanopore -o "$OUTdirReads"  -l 0.6 -t 0.8  -ifq "$READSin1" "$READSin2" -db_res_kma "$KMAres" -acq --disinfectant -db_disinf_kma "$KMAdis" --point --species "$speciesTemp" --ignore_missing_species -db_point_kma "$KMApoint"/"$speciesTemp"/ -u;

python -m resfinder -v > REPORTING/resfinder.version.log 2>&1;

python -m resfinder --nanopore -o "$OUTdirContigs"  -l 0.6 -t 0.8  -ifa "$CONTIGSin" -db_res_kma "$KMAres" -acq --disinfectant -db_disinf_kma "$KMAdis" --point --species "$speciesTemp" --ignore_missing_species -db_point_kma "$KMApoint"/"$speciesTemp"/ -u;

count0=$((count0+1));
done

#usage: run_resfinder.py [-h] [-ifa INPUTFASTA] [-ifq INPUTFASTQ [INPUTFASTQ ...]] [-o OUT_PATH] [-b BLAST_PATH] [-k KMA_PATH] [-s SPECIES] [-db_res DB_PATH_RES]
#                        [-db_res_kma DB_PATH_RES_KMA] [-d DATABASES] [-acq] [-ao ACQ_OVERLAP] [-l MIN_COV] [-t THRESHOLD] [-c] [-db_point DB_PATH_POINT]
#                        [-db_point_kma DB_PATH_POINT_KMA] [-g SPECIFIC_GENE [SPECIFIC_GENE ...]] [-u] [-l_p MIN_COV_POINT] [-t_p THRESHOLD_POINT] [--pickle]
#optional arguments:
#  -h, --help            show this help message and exit
#  -ifa INPUTFASTA, --inputfasta INPUTFASTA
#                        Input fasta file.
#  -ifq INPUTFASTQ [INPUTFASTQ ...], --inputfastq INPUTFASTQ [INPUTFASTQ ...]
#                        Input fastq file(s). Assumed to be single-end fastq if only one file is provided, and assumed to be paired-end data if two files are provided.
#  -o OUT_PATH, --outputPath OUT_PATH
#                        Path to blast output
#  -b BLAST_PATH, --blastPath BLAST_PATH
#                        Path to blastn
#  -k KMA_PATH, --kmaPath KMA_PATH
#                        Path to KMA
#  -s SPECIES, --species SPECIES
#                        Species in the sample
#  -db_res DB_PATH_RES, --db_path_res DB_PATH_RES
#                        Path to the databases for ResFinder
#  -db_res_kma DB_PATH_RES_KMA, --db_path_res_kma DB_PATH_RES_KMA
#                        Path to the ResFinder databases indexed with KMA. Defaults to the 'kma_indexing' directory inside the given database directory.
#  -d DATABASES, --databases DATABASES
#                        Databases chosen to search in - if none is specified all is used
#  -acq, --acquired      Run resfinder for acquired resistance genes
#  -ao ACQ_OVERLAP, --acq_overlap ACQ_OVERLAP
#                        Genes are allowed to overlap this number of nucleotides. Default: 30.
#  -l MIN_COV, --min_cov MIN_COV
#                        Minimum (breadth-of) coverage of ResFinder within the range 0-1.
#  -t THRESHOLD, --threshold THRESHOLD
#                        Threshold for identity of ResFinder within the range 0-1.
#  -c, --point           Run pointfinder for chromosomal mutations
#  -db_point DB_PATH_POINT, --db_path_point DB_PATH_POINT
#                        Path to the databases for PointFinder
#  -db_point_kma DB_PATH_POINT_KMA, --db_path_point_kma DB_PATH_POINT_KMA
#                        Path to the PointFinder databases indexed with KMA. Defaults to the 'kma_indexing' directory inside the given database directory.
#  -g SPECIFIC_GENE [SPECIFIC_GENE ...]
#                        Specify genes existing in the database to search for - if none is specified all genes are included in the search.
#  -u, --unknown_mut     Show all mutations found even if in unknown to the resistance database
#  -l_p MIN_COV_POINT, --min_cov_point MIN_COV_POINT
#                        Minimum (breadth-of) coverage of Pointfinder within the range 0-1. If None is selected, the minimum coverage of ResFinder will be used.
#  -t_p THRESHOLD_POINT, --threshold_point THRESHOLD_POINT
#                        Threshold for identity of Pointfinder within the range 0-1. If None is selected, the minimum coverage of ResFinder will be used.
#  --pickle              Create a pickle dump of the Isolate object. Currently needed in the CGE webserver. Dependency and this option is being removed.





