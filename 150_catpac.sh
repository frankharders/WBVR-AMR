#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-compareGenomes;


#create several directories
while getopts "w:m:l:n:" opt; do
  case $opt in
    w)
      #echo "-w was triggered! $OPTARG"
      WORKDIR="`echo $(readlink -m $OPTARG)`"
      #echo $WORKDIR
      ;;
     a)
      #echo "-a was triggered! $OPTARG"
      RAW_FASTQ="`echo $(readlink -m $OPTARG)`"
      #echo $RAW_FASTQ
      ;;
     b)
      #echo "-b was triggered! $OPTARG"
      RAWSTATS="`echo $(readlink -m $OPTARG)`"
      #echo $RAWSTATS
      ;;
	 c)
      #echo "-c was triggered! $OPTARG"
      POLISHED="`echo $(readlink -m $OPTARG)`"
      #echo $POLISHED
      ;;
	 d)
      #echo "-d was triggered! $OPTARG"
      TRIMMEDSTATS="`echo $(readlink -m $OPTARG)`"
      #echo $TRIMMEDSTATS
      ;;
	 e)
      #echo "-e was triggered! $OPTARG"
      SHOVILL="`echo $(readlink -m $OPTARG)`"
      #echo $SHOVILL
      ;;
	 f)
      #echo "-f was triggered! $OPTARG"
      QUAST="`echo $(readlink -m $OPTARG)`"
      #echo $QUAST
      ;;
	 g)
      #echo "-g was triggered! $OPTARG"
      QUASTparse="`echo $(readlink -m $OPTARG)`"
      #echo $QUASTparse
      ;;
     h)
      #echo "-h was triggered! $OPTARG"
      MLST="`echo $(readlink -m $OPTARG)`"
      #echo $MLST
      ;;
     i)
      #echo "-i was triggered! $OPTARG"
      MLSTparse="`echo $(readlink -m $OPTARG)`"
      #echo $MLSTparse
      ;;	  
     j)
      #echo "-i was triggered! $OPTARG"
      ABRICATE="`echo $(readlink -m $OPTARG)`"
      #echo $ABRICATE
      ;;
	 l)
      #echo "-l was triggered! $OPTARG"
      TMP="`echo $(readlink -m $OPTARG)`"
      #echo $TMP
      ;;
	 m)
      #echo "-n was triggered! $OPTARG"
      GENOMES="`echo $(readlink -m $OPTARG)`"
      #echo $GENOMES
      ;;
	 n)
      #echo "-n was triggered! $OPTARG"
      LOG="`echo $(readlink -m $OPTARG)`"
      #echo $LOG
      ;;
	 o)
      #echo "-n was triggered! $OPTARG"
      SRAX="`echo $(readlink -m $OPTARG)`"
      #echo $SRAX
      ;;	  
	 p)
      #echo "-n was triggered! $OPTARG"
      MUMI="`echo $(readlink -m $OPTARG)`"
      #echo $MUMI
      ;;	
     r)
      #echo "-r was triggered! $OPTARG"
      REPORTING="`echo $(readlink -m $OPTARG)`"
      #echo $REPORTING
      ;;	  
     s)
      #echo "-r was triggered! $OPTARG"
      STARAMR="`echo $(readlink -m $OPTARG)`"
      #echo $STARAMR
      ;;
     t)
      #echo "-r was triggered! $OPTARG"
      RGI="`echo $(readlink -m $OPTARG)`"
      #echo $RGI
      ;;
     q)
      #echo "-r was triggered! $OPTARG"
      ARCHIVE="`echo $(readlink -m $OPTARG)`"
      #echo $ARCHIVE
      ;;	  
    \?)
      echo " Let's start some analysis" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] ; then
    echo "-w $WORKDIR "
    echo "-w, "
    exit 1
fi

## reporting
GenRep="$REPORTING"/general-report.txt;

echo -e $CATPAC;


scriptdir='/home/wbvr006/GIT/Catpac/';


count0=1;
countS1=$(cat samples.txt | wc -l);
CATPAC=$WORKDIR/15_catpac-analysis;


mkdir -p $CATPAC;



while [ $count0 -le $countS1 ];do

	SAMPLE1=$(cat samples.txt | awk 'NR=='$count0 );



count1=1;
countS2=$(cat samples.txt | wc -l);

while [ $count1 -le $countS2 ];do

	SAMPLE2=$(cat samples.txt | awk 'NR=='$count1 );

echo -e "$SAMPLE1 vs $SAMPLE2";


catpacIN1=./04_shovill/$SAMPLE1/spades.fasta;#spades.fasta
catpacIN2=./04_shovill/$SAMPLE2/spades.fasta;

catpacOUT1=$CATPAC/$SAMPLE1.catpac.fasta;
catpacOUT2=$CATPAC/$SAMPLE2.catpac.fasta;

RESULTS=$CATPAC/$SAMPLE1-$SAMPLE2-catpac-variants.tab;
LOG=./LOGS/15_catpac-$SAMPLE1-$SAMPLE2.log;

$scriptdir/catpac.py -a $catpacOUT1 -b $catpacOUT2 -v $RESULTS $catpacIN1 $catpacIN2 > $LOG 2>&1;




count1=$((count1+1));

done






count0=$((count0+1));

done



exit 1






