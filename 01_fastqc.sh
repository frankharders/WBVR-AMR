#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-QC;

cnt=$(cat samples.txt | wc -l);

while getopts "w:a:b:r:q:" opt; do
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

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$RAW_FASTQ" ] || [ "x" == "x$RAWSTATS" ] || [ "x" == "x$REPORTING" ]; then
    echo "-w $WORKDIR -a $RAW_FASTQ -b $RAWSTATS -r $REPORTING"
    echo "-w, -a, -b, -w [options] are required"
    exit 1
fi

ToDay=$(date +%Y-%m-%d);


GenRep="$REPORTING"/general-report.txt;
echo "$Today";

echo "$Today" > "$GenRep";

while read SAMPLE; do 

OUTdir=$RAWSTATS/$SAMPLE;

mkdir -p $OUTdir;

R1=$RAW_FASTQ/$SAMPLE'_R1.fastq.gz';
R2=$RAW_FASTQ/$SAMPLE'_R2.fastq.gz';


echo "fastQC analysis on raw sequence files";
fastqc -t 8 -o $OUTdir $R1 $R2;


	let cnt--;	
	echo -e "$cnt samples to go!";
	echo "NEXT";


		done < samples.txt
		
fastQCcnt=$(ls $RAWSTATS/*/*R1* | wc -l);

echo -e "\nfastQC\nfrom $fastQCcnt samples a fastqQC report is constructed\n" >> "$GenRep"; 		
		

echo "fastqc plots are generated for all raw reads for all samples";
echo -e "output files for downstream processing can be found in the directory $RAWSTATS";

cp -r $RAWSTATS $ARCHIVE;
	
exit 1

