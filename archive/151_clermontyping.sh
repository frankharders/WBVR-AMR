#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-clermontyping;

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


CMT="$WORKDIR"/51_clermontyping;

mkdir -p "$CMT";

rm "$REPORTING"/project.clermonTyping.tab;

count0=1;
countS=$(cat samples.txt | wc -l);


while [ "$count0" -le "$countS"  ]; do 

SAMPLE=$(cat samples.txt | awk 'NR=='"$count0");

	echo $SAMPLE;

fastaIn="$GENOMES"/"$SAMPLE"_contigs.fa;
cmtOut="$CMT"/"$SAMPLE".clermont.txt;
cmtOut2="$CMT"/"$SAMPLE".clermont.details.txt;

	ezclermont -e "$SAMPLE" "$fastaIn" > "$cmtOut2" 2>&1;
	ezclermont -e "$SAMPLE" "$fastaIn" | tee "$cmtOut";
	

name=$(cat "$cmtOut" | cut -f1);
type=$(cat "$cmtOut" | cut -f2);

cat "$cmtOut" >> "$REPORTING"/project.clermonTyping.tab;

#cat report



count0=$((count0+1));
done




































exit 1

#####  ezclermont
#
#usage: ezclermont [-m MIN_LENGTH] [-e EXPERIMENT_NAME] [-n] [--logfile LOGFILE] [-h] [--version] contigs
#
#run a 'PCR' to get Clermont 2013 phylotypes; version 0.7.0
#
#positional arguments:
#  contigs               FASTA formatted genome or set of contigs. If reading from stdin, use '-'
#
#optional arguments:
#  -m MIN_LENGTH, --min_length MIN_LENGTH
#                        minimum contig length to consider.default: 500
#  -e EXPERIMENT_NAME, --experiment_name EXPERIMENT_NAME
#                        name of experiment; defaults to file name without extension. If reading from stdin, uses the first contig's ID
#  -n, --no_partial      If scanning contigs, breaks between contigs could potentially contain your sequence of interest. if --no_partial, these plausible partial matches will NOT be reported; default behaviour is to consider partial
#                        hits if the assembly has more than 4 sequnces(ie, no partial matches for complete genomes, allowing for 1 chromosome and several plasmids)
#  --logfile LOGFILE     send log messages to logfile instead stderr
#  -h, --help            Displays this help message
#  --version             show program's version number and exit
#
#####
