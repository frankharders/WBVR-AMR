#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-QC;

cnt=$(cat samples.txt | wc -l);

while getopts "w:c:e:f:r:m:" opt; do
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
	 m)
      echo "-n was triggered! $OPTARG"
      GENOMES="`echo $(readlink -m $OPTARG)`"
      echo $GENOMES
      ;;
     r)
      echo "-r was triggered! $OPTARG"
      REPORTING="`echo $(readlink -m $OPTARG)`"
      echo $REPORTING
      ;;
	 y)
      echo "-y was triggered! $OPTARG"
      ASSEMBLER=$OPTARG
      echo $ASSEMBLER
      ;;
     z)
      echo "-r was triggered! $OPTARG"
      CONTIGLENGTH=$OPTARG
      echo $CONTIGLENGTH
      ;;
    \?)
      echo "-i for the folder containing fastq files, -o for output folder: -$OPTARG" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$POLISHED" ] || [ "x" == "x$SHOVILL" ] || [ "x" == "x$QUAST" ] || [ "x" == "x$REPORTING" ] ; then
    echo "-w $WORKDIR -c $POLISHED -e $SHOVILL -f $QUAST -r $REPORTING"
    echo "-w, -c, -e, -f, -r [options] are required"
    exit 1
fi

## reporting
GenRep="$REPORTING"/general-report.txt;

# (temp) variables
today=$(date +%Y%m%d);
METRICS=./REPORTING/"$today"-assemblymetrics.tab;

FASTAarchive=/mnt/lely_archive/wbvr006/2021/assembled-genomes-2021/;



echo -e "#sample\tContigs>500bp\tLargestContig\tTotalLength\tN50" > "$METRICS";

while read SAMPLE; do 

	echo $SAMPLE;
	
OUTPUTdir=$SHOVILL/$SAMPLE/;
R1=$POLISHED/$SAMPLE/$SAMPLE'_R1.QTR.adapter.correct.fq.gz';
R2=$POLISHED/$SAMPLE/$SAMPLE'_R2.QTR.adapter.correct.fq.gz';

THREADS=24;


FASTAout=$OUTPUTdir/$SAMPLE'.fa';

quast $FASTAout -1 $R1 -2 $R2 --threads $THREADS -o $QUAST/$SAMPLE --strict-NA;


cat $QUAST/$SAMPLE/'report.pdf' > $QUAST/$SAMPLE/$SAMPLE'.report.pdf';
cat $QUAST/$SAMPLE/'report.tsv' > $QUAST/$SAMPLE/$SAMPLE'.report.tsv';


REPORT=$QUAST/$SAMPLE/$SAMPLE'.report.tsv';

echo "$SAMPLE";
cat "$REPORT" | grep -P "# contigs\t";

No=$(cat $REPORT | grep -P "# contigs\t" | cut -f2 -d$'\t');
LC=$(cat $REPORT | grep 'Largest contig' | cut -f2 -d$'\t');
TL=$(cat $REPORT | grep -P "Total length\t" | cut -f2 -d$'\t');
N50=$(cat $REPORT | grep 'N50' | cut -f2 -d$'\t');


cp "$FASTAout" "$GENOMES";
cp "$FASTAout" "$FASTAarchive";


## test every value
#echo -e "sample=$SAMPLE";
#echo -e "No=$No";
#echo -e "LC=$LC";
#echo -e "TL=$TL";
#echo -e "N50=$N50";


#sample contigs>500bp largestContig N50
echo -e "$SAMPLE\t$No\t$LC\t$TL\t$N50" >> "$METRICS";


	let cnt--;	
	echo -e "$cnt samples to go!";
	echo "NEXT";
				
done < samples.txt

echo "quast analysis is done for all assemblies for all samples";
echo -e "output files for downstream processing can be found in the directory $QUAST";

quastCnt=$(ls $QUAST/*/report.pdf | wc l);

echo -e "\nQUAST\nfrom $quastCnt samples a quast & icarus report is constructed\n" >> "$GenRep"; 		


echo "Quast script is finished";

exit 1



