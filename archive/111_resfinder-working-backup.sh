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



cnt=$(cat samples.txt | wc -l);


while getopts "w:m:l:h:n:r:c:u:" opt; do
  case $opt in
     w)
      echo "-w was triggered! $OPTARG"
      WORKDIR="`echo $(readlink -m $OPTARG)`"
      echo $WORKDIR
      ;;
     a)
      echo "-a was triggered! $OPTARG"
      RAW_FASTQ="`echo $(readlink -m $OPTARG)`"
      echo $RAW_FASTQ
      ;;
     b)
      echo "-b was triggered! $OPTARG"
      RAWSTATS="`echo $(readlink -m $OPTARG)`"
      echo $RAWSTATS
      ;;
	 c)
      echo "-c was triggered! $OPTARG"
      POLISHED="`echo $(readlink -m $OPTARG)`"
      echo $POLISHED
      ;;
	 d)
      echo "-d was triggered! $OPTARG"
      TRIMMEDSTATS="`echo $(readlink -m $OPTARG)`"
      echo $TRIMMEDSTATS
      ;;
	 e)
      echo "-e was triggered! $OPTARG"
      SHOVILL="`echo $(readlink -m $OPTARG)`"
      echo $SHOVILL
      ;;
	 f)
      echo "-f was triggered! $OPTARG"
      QUAST="`echo $(readlink -m $OPTARG)`"
      echo $QUAST
      ;;
	 g)
      echo "-g was triggered! $OPTARG"
      QUASTparse="`echo $(readlink -m $OPTARG)`"
      echo $QUASTparse
      ;;
     h)
      echo "-h was triggered! $OPTARG"
      MLST="`echo $(readlink -m $OPTARG)`"
      echo $MLST
      ;;
     i)
      echo "-i was triggered! $OPTARG"
      MLSTparse="`echo $(readlink -m $OPTARG)`"
      echo $MLSTparse
      ;;	  
	 j)
      echo "-j was triggered! $OPTARG"
      ABRICATE="`echo $(readlink -m $OPTARG)`"
      echo $ABRICATE
      ;;
     k)
      echo "-k was triggered! $OPTARG"
      AMRFINDER="`echo $(readlink -m $OPTARG)`"
      echo $AMRFINDER
      ;;	  
	 l)
      echo "-l was triggered! $OPTARG"
      TMP="`echo $(readlink -m $OPTARG)`"
      echo $TMP
      ;;	  
	 m)
      echo "-l was triggered! $OPTARG"
      GENOMES="`echo $(readlink -m $OPTARG)`"
      echo $GENOMES
      ;;	  
	 n)
      echo "-n was triggered! $OPTARG"
      LOG="`echo $(readlink -m $OPTARG)`"
      echo $LOG
      ;;
     r)
      echo "-r was triggered! $OPTARG"
      REPORTING="`echo $(readlink -m $OPTARG)`"
      echo $REPORTING
      ;;
     s)
      echo "-r was triggered! $OPTARG"
      STARAMR="`echo $(readlink -m $OPTARG)`"
      echo $STARAMR
      ;;
     u)
      echo "-r was triggered! $OPTARG"
      RESFINDER="`echo $(readlink -m $OPTARG)`"
      echo $RESFINDER
      ;;	  
	\?)
      echo "-i for the folder containing assembled genome files, -o for output folder: -$OPTARG" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$GENOMES" ] || [ "x" == "x$RESFINDER" ] | [ "x" == "x$POLISHED" ] || [ "x" == "x$REPORTING" ]; then
    echo "-w $WORKDIR -c $POLISHED -e $SHOVILL -j $ABRICATE -r $REPORTING"
    echo "-w, -c, -e, -j, -r  [options] are required"
    exit 1
fi

## reporting
GenRep="$REPORTING"/general-report.txt;
ToDay=$(date +%Y-%m-%d-%T);


dateDir="$RESFINDER"_"$ToDay";
genResfinderDraftGenomeOut="REPORTING"/all-samples-resfinder-results-draftGenome.tab;
genResfinderReadsOut="REPORTING"/all-samples-resfinder-results-polishedReads.tab;
dbRES=/home/wbvr006/GIT/resfinder/cge/resfinder_db/;
dbPoint=/home/wbvr006/GIT/resfinder/cge/pointfinder_db/





rm -rf "$dbPoint";

##  resfinder variables
L=0.6;
T=0.8;

## download and install latest resfinder database
cd /home/wbvr006/GIT/resfinder/cge/;
 
git clone https://git@bitbucket.org/genomicepidemiology/resfinder_db.git;

cd ./resfinder_db;
python3 INSTALL.py;

## download and install pointfinder database
cd /home/wbvr006/GIT/resfinder/cge/;
git clone https://git@bitbucket.org/genomicepidemiology/pointfinder_db.git;

cd ./pointfinder_db;
python3 INSTALL.py;

cd "$WORKDIR";


scriptPath='/home/wbvr006/GIT/resfinder/';

while read SAMPLE; do 

	echo $SAMPLE;

fastaIn="$GENOMES"/"$SAMPLE"_contigs.fa;
fastqIn1="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
fastqIn2="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;


## select species for resfinder and pointfinder analysis
#species=$(sendsketch.sh in=$fastaIn address=refseq | head -n4 | sed '3d' | cut -f12 -d$'\t' | cut -f1 -d' ');
#species=$(cat  $MLST/$SAMPLE.mlst.csv | cut -f2 -d',' );

speciesTemp=$(cat "$REPORTING"/SamplesSpecies.log | grep "$SAMPLE" | cut -f2 -d$'\t');


species=$(cat /home/wbvr006/GIT/resfinder/speciesLookUp.tab | grep -i "$speciesTemp" | head -n1 | cut -f1 -d$'\t');

echo -e "speciesTemp= $speciesTemp";
echo -e "species = $species";

if [ "$species" == 'escherichia coli' ] || [ "$species" == 'campylobacter jejuni' ] || [ "$species" == 'campylobacter coli' ] || [ "$species" == 'salmonella enterica' ] || [ "$species" == 'staphylococcus aureus' ];


then

echo "$species";
	species="$species";
	script=1;
	
else

species="$species";
script=2;

fi

echo "resfinder analysis using the constructed draft genomes";

if [ $script == 1 ];


then

echo "species=$species is compatible"; 

## resfinder analysis using the constructed draft genomes"
#"$scriptPath"/run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/contigs -s "$species" -l "$L" -t "$T" --acquired --point -ifa "$fastaIn" -db_res "$dbRES" -db_point "$dbPoint" -u;
"$scriptPath"/run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/contigs -s "$speciesTemp" -l "$L" -t "$T" --acquired --point -ifa "$fastaIn" -db_res "$dbRES" -db_point "$dbPoint" -u;



echo "resfinder analysis using polished reads";

## resfinder analysis using polished reads
#"$scriptPath"/run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/reads -s "$species" -l "$L" -t "$T" --acquired --point -ifq "$fastqIn1" "$fastqIn2" -db_res "$dbRES" -db_point "$dbPoint" -u;
"$scriptPath"/run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/contigs -s "$speciesTemp" -l "$L" -t "$T" --acquired --point -ifa "$fastaIn" -db_res "$dbRES" -db_point "$dbPoint" -u;



else
echo "species=$species isn't compatible"; 

## resfinder analysis using the constructed draft genomes"
"$scriptPath"/run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/contigs -l "$L" -t "$T" --acquired -ifa "$fastaIn" -db_res "$dbRES" -u;



echo "resfinder analysis using polished reads";

## resfinder analysis using polished reads
"$scriptPath"/run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/reads -l "$L" -t "$T" --acquired -ifq "$fastqIn1" "$fastqIn2" -db_res "$dbRES" -u;






fi








## resfinder draft genome results files linked to the sample

contigsTemp1="$TMP"/contigs_temp_resfinder_header_tab.txt;
contigsHead="$TMP"/contigs_resfinder_header_tab.txt;

echo -e "SAMPLE\t$contigsTemp1" > "$contigsHead";

cat "$RESFINDER"/"$SAMPLE"/contigs/ResFinder_results_tab.txt | head -n1 > "$contigsTemp1";
cat "$RESFINDER"/"$SAMPLE"/contigs/ResFinder_results_tab.txt | sed '1d' > "$RESFINDER"/"$SAMPLE"/contigs/"$SAMPLE"_resfinder_noHeader_results_tab.txt;


## resfinder polished read results files linked to the sample

cat "$RESFINDER"/"$SAMPLE"/reads/ResFinder_results_tab.txt | head -n1 > "$TMP"/reads_resfinder_header_tab.txt;
cat "$RESFINDER"/"$SAMPLE"/reads/ResFinder_results_tab.txt | sed '1d' > "$RESFINDER"/"$SAMPLE"/reads/"$SAMPLE"_resfinder_noHeader_results_tab.txt;

done < samples.txt


resfinderCnt=$(ls "$GENOMES"/*_contigs.fa | wc -l);
resfinder_dbDate=$(date -r /home/wbvr006/GIT/resfinder/cge/resfinder_db/README.md);


echo -e "\nRESFINDER\n$resfinderCnt genomes are analysed with the current resfinder database" >> "$GenRep"; 		
echo -e "\ndate of the resfinder database = $resfinder_dbDate\n" >> "$GenRep"; 


exit 1



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





