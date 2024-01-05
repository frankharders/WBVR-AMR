#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-test;

## change new version of resfinder 4.3 with updated databases. Install via pip instead of git clone function!
## change (2022-05-27)
## due to a error in using the "$species" variable the script is altered
## if species isn't found in point mutations db list the script will be run without this variable



# bizzy
# kijken naar de layout mbt weergeven results.
# werken we vanuit de contigs? 
# optioneel reads of reads toevoegen en optioneel kijken naar de results daarvan.
# afkap waarden positief?
# wat te doen met partieel?



cnt=$(cat samples.txt | wc -l);


while getopts "w:m:l:h:n:r:c:q:u:" opt; do
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
	 q)
      echo "-q was triggered! $OPTARG"
      ARCHIVE="`echo $(readlink -m $OPTARG)`"
      echo $ARCHIVE
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
dbRES=/home/wbvr006/GIT2/resfinder_db/;
dbPoint=/home/wbvr006/GIT2/pointfinder_db/;

rm -rf "$dbRES";
rm -rf "$dbPoint";

##  resfinder variables
L=0.6;
T=0.8;

## download and install latest resfinder database
cd /home/wbvr006/GIT2/;
 
git clone https://git@bitbucket.org/genomicepidemiology/resfinder_db.git;

cd ./resfinder_db;
python3 INSTALL.py;

## download and install pointfinder database
cd /home/wbvr006/GIT2/;
git clone https://git@bitbucket.org/genomicepidemiology/pointfinder_db.git;

cd ./pointfinder_db;
python3 INSTALL.py;

cd "$WORKDIR";


scriptPath='/home/wbvr006/miniconda3/envs/amr-test/lib/python3.11/site-packages';

while read SAMPLE; do 

	echo $SAMPLE;

fastaIn="$GENOMES"/"$SAMPLE"_contigs.fa;
fastqIn1="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
fastqIn2="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;


## select species for resfinder and pointfinder analysis
#species=$(sendsketch.sh in=$fastaIn address=refseq | head -n4 | sed '3d' | cut -f12 -d$'\t' | cut -f1 -d' ');
species=$(cat  $MLST/$SAMPLE.mlst.csv | cut -f2 -d',' );


echo "$species";

#if [ $species == 'Escherichia' ]
if [ $species != 'e.coli' ]


then
	species='Escherichia coli';
	script=1;

	
else

species=$species;
script=2;

fi

echo "resfinder analysis using the constructed draft genomes";

if [ $script == 1 ] 


then

## resfinder analysis using the constructed draft genomes"
python "$scriptPath"/resfinder -o "$RESFINDER"/"$SAMPLE"/contigs -s "$species" -l "$L" -t "$T" --acquired --point -ifa "$fastaIn" -db_res "$dbRES" -db_point "$dbPoint" -u;



echo "resfinder analysis using polished reads";

## resfinder analysis using polished reads
python "$scriptPath"/resfinder -o "$RESFINDER"/"$SAMPLE"/reads -s "$species" -l "$L" -t "$T" --acquired --point -ifq "$fastqIn1" "$fastqIn2" -db_res "$dbRES" -db_point "$dbPoint" -u;



else

## resfinder analysis using the constructed draft genomes"
python "$scriptPath"/resfinder -o "$RESFINDER"/"$SAMPLE"/contigs -l "$L" -t "$T" --acquired -ifa "$fastaIn" -db_res "$dbRES" -u;



echo "resfinder analysis using polished reads";

## resfinder analysis using polished reads
python "$scriptPath"/resfinder -o "$RESFINDER"/"$SAMPLE"/reads -l "$L" -t "$T" --acquired -ifq "$fastqIn1" "$fastqIn2" -db_res "$dbRES" -u;


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

#####  resfinder 4.3
#
# usage: resfinder [-h] [-ifa INPUTFASTA] [-ifq INPUTFASTQ [INPUTFASTQ ...]] [--nanopore] -o OUTPUTPATH [-j OUT_JSON] [-b BLASTPATH] [-k KMAPATH] [-s SPECIES] [--ignore_missing_species] [--output_aln] [-db_res DB_PATH_RES]
#                 [-db_res_kma DB_PATH_RES_KMA] [-acq] [-ao ACQ_OVERLAP] [-l MIN_COV] [-t THRESHOLD] [-d] [-db_disinf DB_PATH_DISINF] [-db_disinf_kma DB_PATH_DISINF_KMA] [-c] [-db_point DB_PATH_POINT] [-db_point_kma DB_PATH_POINT_KMA]
#                 [-g SPECIFIC_GENE [SPECIFIC_GENE ...]] [-u] [-l_p MIN_COV_POINT] [-t_p THRESHOLD_POINT] [--ignore_indels] [--ignore_stop_codons] [-v] [--pickle]
#
#options:
#  -h, --help            show this help message and exit
#  -ifa INPUTFASTA, --inputfasta INPUTFASTA
#                        Input fasta file.
#  -ifq INPUTFASTQ [INPUTFASTQ ...], --inputfastq INPUTFASTQ [INPUTFASTQ ...]
#                        Input fastq file(s). Assumed to be single-end fastq if only one file is provided, and assumed to be paired-end data if two files are provided.
#  --nanopore            If nanopore data is used
#  -o OUTPUTPATH, --outputPath OUTPUTPATH
#                        Output directory. If it doesn't exist, it will be created.
#  -j OUT_JSON, --out_json OUT_JSON
#                        Specify JSON filename and output directory. If the directory doesn't exist, it will be created.
#  -b BLASTPATH, --blastPath BLASTPATH
#                        Path to blastn
#  -k KMAPATH, --kmaPath KMAPATH
#                        Path to KMA
#  -s SPECIES, --species SPECIES
#                        Species in the sample
#  --ignore_missing_species
#                        If set, species is provided and --point flag is set, will not throw an error if no database is found for the provided species. If species is not found. Point mutations will silently be ignored.
#  --output_aln          will add the alignments in the json output.
#  -db_res DB_PATH_RES, --db_path_res DB_PATH_RES
#                        Path to the databases for ResFinder.
#  -db_res_kma DB_PATH_RES_KMA, --db_path_res_kma DB_PATH_RES_KMA
#                        Path to the ResFinder databases indexed with KMA. Defaults to the value of the --db_res flag.
#  -acq, --acquired      Run resfinder for acquired resistance genes
#  -ao ACQ_OVERLAP, --acq_overlap ACQ_OVERLAP
#                        Genes are allowed to overlap this number of nucleotides. Default: 30.
#  -l MIN_COV, --min_cov MIN_COV
#                        Minimum (breadth-of) coverage of ResFinder within the range 0-1.
#  -t THRESHOLD, --threshold THRESHOLD
#                        Threshold for identity of ResFinder within the range 0-1.
#  -d, --disinfectant    Run resfinder for disinfectant resistance genes
#  -db_disinf DB_PATH_DISINF, --db_path_disinf DB_PATH_DISINF
#                        Path to the databases for DisinFinder.
#  -db_disinf_kma DB_PATH_DISINF_KMA, --db_path_disinf_kma DB_PATH_DISINF_KMA
#                        Path to the DisinFinder databases indexed with KMA. Defaults to the value of the --db_res flag.
#  -c, --point           Run pointfinder for chromosomal mutations
#  -db_point DB_PATH_POINT, --db_path_point DB_PATH_POINT
#                        Path to the databases for PointFinder
#  -db_point_kma DB_PATH_POINT_KMA, --db_path_point_kma DB_PATH_POINT_KMA
#                        Path to the PointFinder databases indexed with KMA. Defaults to the value of the --db_path_point flag.
#  -g SPECIFIC_GENE [SPECIFIC_GENE ...], --specific_gene SPECIFIC_GENE [SPECIFIC_GENE ...]
#                        Specify genes existing in the database to search for - if none is specified all genes are included in the search.
#  -u, --unknown_mut     Show all mutations found even if in unknown to the resistance database
#  -l_p MIN_COV_POINT, --min_cov_point MIN_COV_POINT
#                        Minimum (breadth-of) coverage of Pointfinder within the range 0-1. If None is selected, the minimum coverage of ResFinder will be used.
#  -t_p THRESHOLD_POINT, --threshold_point THRESHOLD_POINT
#                        Threshold for identity of Pointfinder within the range 0-1. If None is selected, the minimum coverage of ResFinder will be used.
#  --ignore_indels       Ignore frameshift-causing indels in Pointfinder.
#  --ignore_stop_codons  Ignore premature stop codons in Pointfinder.
#  -v, --version         Show program's version number and exit
#  --pickle              Create a pickle dump of the Isolate object. Currently needed in the CGE webserver. Dependency and this option is being removed.
#
#####


Footer
© 2023 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
WBVRpipeline/11_resfinder.sh at main · frankharders/WBVRpipeline
