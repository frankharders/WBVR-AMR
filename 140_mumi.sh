#!/bin/bash


##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-sraX;


#create several directories
while getopts "w:m:l:n:p:" opt; do
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


mkdir -p $MUMI;

scriptdir='/home/wbvr006/general-scripts';


cnt=$(cat samples.txt | wc -l);

#rm -r -f MUMIanalysis;

mkdir -p "$WORKDIR"/13_MUMIinputfiles;
#mkdir -p MUMIanalysis;
# VARIABLES
MUMIinput="$WORKDIR"/13_MUMIinputfiles;
#MUMIout='MUMIanalysis';

echo -e "if additional strains/references analysed please add the fasta2 file to the directory $MUMIinput";

# prepare files for MUMI analysis

while read SAMPLE; do 

	echo $SAMPLE;

mkdir -p $MUMIinput/$SAMPLE/;
		
	echo -e ">$SAMPLE" > $MUMIinput/$SAMPLE/$SAMPLE'.fasta2';
	
	grep -o -P '^[acgtnACGTN]+' $GENOMES/$SAMPLE'_contigs.fa' >> $MUMIinput/$SAMPLE/$SAMPLE'.fasta2';


	let cnt--;	
	echo -e "$cnt samples to go!";
	echo "NEXT";
				
		done < samples.txt

mumiscript=$scriptdir/'07_run_mummers-mumi.sh';
		
if [ -f $mumiscript ];
	then		

#MUMIoutdir='MUMIanalysis';	
	
# run mumi script		
sh $mumiscript -i $MUMIinput/$SAMPLE -o $MUMI;		

#./4a_run_mummers-mumi.sh -i MUMIinputfiles -o MUMIanalysis;



#remove all intermediate files used for building the analysis matrix
rm $MUMI/*.mum 	
		
# get current directory
echo -e $PWD;

project=$(echo $PWD | rev | cut -f1 -d'/' | rev);
echo -e "$project";

cd $MUMI;

rename "s/mumi/"$project"/g" *.*;
		

# rename mumi output files
#for i in $MUMI/mumi.*;do
#	rename "s/mumi/"$project"/g" $i;
#done		
		
else
   echo "MUMI script is lost"
fi
	
exit 1
