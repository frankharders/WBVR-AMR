#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-isescan;

## reporting
#GenRep="$REPORTING"/general-report.txt;


while getopts "w:m:" opt; do
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

count0=1;
countS=$(cat samples.txt | wc -l);



mkdir -p ./20_isfinder;

ISFINDER=./20_isfinder;


while [ $count0 -le $countS ];do

	SAMPLE=$(cat samples.txt | awk 'NR=='$count0 );





ISFINDERin=./genomes/$SAMPLE'_contigs.fa';
LOG1=./LOGS/$SAMPLE.isfrinder.log;


isescan.py --seqfile $ISFINDERin --output $ISFINDER --nthread 48;




count0=$((count0+1));

done



#usage: isescan [-h] [--version] [--removeShortIS] [--no-FragGeneScan] --seqfile SEQFILE --output OUTPUT [--nthread NTHREAD]
#
#ISEScan is a python pipeline to identify Insertion Sequence elements (both complete and incomplete IS elements) in genom. A typical invocation would be:
#python3 isescan.py seqfile proteome hmm
#
#- If you want isescan to report only complete IS elements, you need to set command line option --removeShortIS.
#
#options:
#  -h, --help         show this help message and exit
#  --version          show program's version number and exit
#  --removeShortIS    Remove incomplete (partial) IS elements which include IS element with length < 400 or single copy IS element without perfect TIR.
#  --no-FragGeneScan  Use the annotated protein sequences in NCBI GenBank file (.gbk which must be in the same folder with genome sequence file), instead of the protein sequences
#                     predicted/translated by FragGeneScan. (Experimental feature!)
#  --seqfile SEQFILE  Sequence file in fasta format, '' by default
#  --output OUTPUT    Output directory, 'results' by default
#  --nthread NTHREAD  Number of CPU cores used for FragGeneScan and hmmer, 1 by default.








exit 1






