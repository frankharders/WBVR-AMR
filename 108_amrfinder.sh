#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-amrfinder;

cnt=$(cat samples.txt | wc -l);


while getopts "w:r:k:l:m:n:" opt; do
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
	\?)
      echo "-i for the folder containing assembled genome files, -o for output folder: -$OPTARG" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$GENOMES" ] || [ "x" == "x$AMRFINDER" ] || [ "x" == "x$REPORTING" ]; then
    echo "-w $WORKDIR -c $POLISHED -e $SHOVILL -j $ABRICATE -r $REPORTING"
    echo "-w, -c, -e, -j, -r  [options] are required"
    exit 1
fi

## reporting
GenRep="$REPORTING"/general-report.txt;


ToDay=$(date +%Y-%m-%d-%T);

dateDir="$AMRFINDER"_"$ToDay";
 
echo -e "today is $ToDay";

echo -e "amrfinder is updated $ToDay" >> $GenRep;

amrfinder --force_update;


mkdir -p "$dateDir";

while read SAMPLE;do

echo $SAMPLE;

FILEin="$GENOMES"/"$SAMPLE"_contigs.fa;

amrfinder --plus -n $FILEin --log "$LOG"/"$SAMPLE".amr.log --threads 48 > "$dateDir"/"$SAMPLE"_amrfinder.got;
#diff test_dna.expected test_dna.got

	let cnt--;	
	echo -e "$cnt samples to go!";
	echo "NEXT";

done < samples.txt

cat "$dateDir"/*.got > $REPORTING/All_results_amrfinder."$ToDay".tab;


amrfinderCnt=$(ls "$dateDir"/*.got | wc -l);

echo -e "\nAMRFINDER\n$amrfinderCnt genomes are analysed with amrfinder" >> "$GenRep"; 		





# LATEN STAAN AMRFINDER ZET ALLE FILES HIER NEER EN DIT LOOPT BIJ ELK GEBRUIK OP!
rm -rf /tmp/amrfinder*.*;
exit 1


#USAGE:   amrfinder [--update] [--protein PROT_FASTA] [--nucleotide NUC_FASTA] [--gff GFF_FILE] [--pgap] [--database DATABASE_DIR] [--ident_min MIN_IDENT] [--coverage_min MIN_COV] [--organism ORGANISM] [--list_organisms] [--translation_table TRANSLATION_TABLE] [--plus] [--report_common] [--mutation_all MUT_ALL_FILE] [--blast_bin BLAST_DIR] [--output OUTPUT_FILE] [--quiet] [--gpipe_org] [--parm PARM] [--threads THREADS] [--debug] [--log LOG]
#HELP:    amrfinder --help or amrfinder -h
#VERSION: amrfinder --version

#OPTIONAL PARAMETERS:
#-u, --update
#    Update the AMRFinder database
#-p PROT_FASTA, --protein PROT_FASTA
#    Protein FASTA file to search
#-n NUC_FASTA, --nucleotide NUC_FASTA
#    Nucleotide FASTA file to search
#-g GFF_FILE, --gff GFF_FILE
#    GFF file for protein locations. Protein id should be in the attribute 'Name=<id>' (9th field) of the rows with type 'CDS' or 'gene' (3rd field).
#--pgap
#    Input files PROT_FASTA, NUC_FASTA and GFF_FILE are created by the NCBI PGAP
#-d DATABASE_DIR, --database DATABASE_DIR
#    Alternative directory with AMRFinder database. Default: $AMRFINDER_DB
#-i MIN_IDENT, --ident_min MIN_IDENT
#    Minimum identity for nucleotide hit (0..1). -1 means use a curated threshold if it exists and 0.9 otherwise
#    Default: -1
#-c MIN_COV, --coverage_min MIN_COV
#    Minimum coverage of the reference protein (0..1)
#    Default: 0.5
#-O ORGANISM, --organism ORGANISM
#    Taxonomy group. To see all possible taxonomy groups use the --list_organisms flag
#-l, --list_organisms
#    Print the list of all possible taxonomy groups for mutations identification and exit
#-t TRANSLATION_TABLE, --translation_table TRANSLATION_TABLE
#    NCBI genetic code for translated BLAST
#    Default: 11
#--plus
#    Add the plus genes to the report
#--report_common
#    Report proteins common to a taxonomy group
#--mutation_all MUT_ALL_FILE
#    File to report all mutations
#--blast_bin BLAST_DIR
#    Directory for BLAST. Deafult: $BLAST_BIN
#-o OUTPUT_FILE, --output OUTPUT_FILE
#    Write output to OUTPUT_FILE instead of STDOUT
#-q, --quiet
#    Suppress messages to STDERR
#--gpipe_org
#    NCBI internal GPipe organism names
#--parm PARM
#    amr_report parameters for testing: -nosame -noblast -skip_hmm_check -bed
#--threads THREADS
#    Max. number of threads
#    Default: 4
#--debug
#    Integrity checks
#--log LOG
#    Error log file, appended, opened on application start

