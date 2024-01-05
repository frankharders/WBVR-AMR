#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-QC;                   


cnt=$(cat samples.txt | wc -l);

while getopts "w:c:d:r:q:" opt; do
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
      ABRICATEparse="`echo $(readlink -m $OPTARG)`"
      echo $ABRICATEparse
      ;;	  
	 l)
      echo "-l was triggered! $OPTARG"
      TMP="`echo $(readlink -m $OPTARG)`"
      echo $TMP
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
     q)
      echo "-r was triggered! $OPTARG"
      ARCHIVE="`echo $(readlink -m $OPTARG)`"
      echo $ARCHIVE
      ;;
	\?)
      echo "-i for the folder containing fastq files, -o for output folder of polished data: -$OPTARG" >&2
      ;;
  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$POLISHED" ] || [ "x" == "x$TRIMMEDSTATS" ] || [ "x" == "x$REPORTING" ]; then
    echo "-w $WORKDIR -c $POLISHED -d $TRIMMEDSTATS -r $REPORTING"
    echo "-w, -c, -d, -w [options] are required"
    exit 1
fi


## reporting
GenRep="$REPORTING"/general-report.txt;


while read SAMPLE; do 

R1=$POLISHED/$SAMPLE/$SAMPLE'_R1.QTR.adapter.correct.fq.gz';
R2=$POLISHED/$SAMPLE/$SAMPLE'_R2.QTR.adapter.correct.fq.gz';

OUTdir=$TRIMMEDSTATS/$SAMPLE;

mkdir -p $OUTdir;


echo "fastQC analysis on raw sequence files";
fastqc -t 8 -o $OUTdir $R1 $R2;


	let cnt--;	
	echo -e "$cnt samples to go!";
	echo "NEXT";


		done < samples.txt

fastQCcnt=$(ls $TRIMMEDSTATS/*/*R1*.zip | wc -l);

echo -e "\nfastQC\nfrom $fastQCcnt samples a fastqQC report is constructed from polished reads\n" >> "$GenRep"; 		
	

echo "fastqc plots are generated for all polished reads for all samples";
echo -e "output files for downstream processing can be found in the directory $TRIMMEDSTATS";

cp -r $TRIMMEDSTATS $ARCHIVE;

	
exit 1

