#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-rgi;

cnt=$(cat samples.txt | wc -l);


while getopts "w:r:l:m:n:t:" opt; do
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
     t)
      echo "-r was triggered! $OPTARG"
      RGI="`echo $(readlink -m $OPTARG)`"
      echo $RGI
      ;;	  
	\?)
      echo "-i for the folder containing assembled genome files, -o for output folder: -$OPTARG" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$GENOMES" ] || [ "x" == "x$RGI" ] || [ "x" == "x$REPORTING" ]; then
    echo "-w $WORKDIR -c $POLISHED -e $SHOVILL -j $ABRICATE -r $REPORTING"
    echo "-w, -c, -e, -j, -r  [options] are required"
    exit 1
fi

## reporting
GenRep="$REPORTING"/general-report.txt;


rm data;
rm card*;


## download latest-data
wget https://card.mcmaster.ca/latest/data ;

## create corrensponding json file
tar -xvf data ./card.json;

## load DB before analysis of the data

rgi load --card_json card.json --local;
rgi card_annotation -i card.json > card_annotation.log 2>&1;

cardFasta2=$(find . -name 'card_database*.*');

cardFasta=$(basename "$cardFasta2");




rgi load -i card.json --card_annotation "$cardFasta" --local;


while read SAMPLE;do

echo "$SAMPLE";



rgi main -i $GENOMES/"$SAMPLE"_contigs.fa -o $RGI/"$SAMPLE"_contigs.out --input_type contig --local --clean;




done < samples.txt


## create visual output files

echo "create heatmap";
rgi heatmap -i $RGI -cat drug_class -o $RGI/drug_class.out;

echo "create resistance_mechanism";

rgi heatmap -i $RGI -cat resistance_mechanism -o $RGI/resistance_mechanism.out;

echo "create gene_family";

rgi heatmap -i $RGI -cat gene_family -o $RGI/gene_family.out;

echo "create clustered heatmap files"
rgi heatmap -i $RGI  -o $RGI/clustered_class.fill.clus.out -d fill -clus both


## move used card files into a subdir
mkdir -p cardfiles;

mv data $RGI;
mv card* $RGI;

rgiCnt=$(ls "$GENOMES"/*_contigs.fa | wc -l);

echo -e "\nRGI\n$rgiCnt genomes are analysed with card-analysis" >> "$GenRep"; 		



rm -r "$PWD"/localDB;

exit 1
