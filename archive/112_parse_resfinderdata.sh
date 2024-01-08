#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate pip3;


# bizzy
# kijken naar de layout mbt weergeven results.
# werken we vanuit de contigs? 
# optioneel reads of reads toevoegen en optioneel kijken naar de results daarvan.
# afkap waarden positief?
# wat te doen met partieel?

cnt=$(cat samples.txt | wc -l);


while getopts "w:m:l:n:r:c:u:" opt; do
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




## out of the parsed resfinder analysis files
genResfinderDraftGenomeOut="REPORTING"/all-samples-resfinder-results-draftGenome_"$ToDay".tab;
genResfinderReadsOut="REPORTING"/all-samples-resfinder-results-polishedReads_"$ToDay".tab;


#dbRES=/home/wbvr006/GIT/resfinder/cge/resfinder_db/;
#dbPoint=/home/wbvr006/GIT/resfinder/cge/pointfinder_db/
#fastaIn="$GENOMES"/"$SAMPLE"_contigs.fa;
#fastqIn1="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
#fastqIn2="$POLISHED"/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;
## select species for resfinder and pointfinder analysis
#species=$(sendsketch.sh in=$fastaIn | head -n4 | sed '3d' | cut -f12 -d$'\t' | cut -f1 -d' ');
#echo "$species";
#echo "resfinder analysis using the constructed draft genomes";
## resfinder analysis using the constructed draft genomes"
#run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/contigs -s "$species" -l "$L" -t "$T" --acquired --point -ifa "$fastaIn" -db_res "$dbRES" -db_point "$dbPoint" -u;
#echo "resfinder analysis using polished reads";
## resfinder analysis using polished reads
#run_resfinder.py -o "$RESFINDER"/"$SAMPLE"/reads -s "$species" -l "$L" -t "$T" --acquired --point -ifq "$fastqIn1" "$fastqIn2" -db_res "$dbRES" -db_point "$dbPoint" -u


## write headers to TEMP directory for general files resfinder analysis

## resfinder draft genome results files linked to the sample

## write header draft assemly resfinder analysis table to temp directory
draftHeadSample=$(cat samples.txt | head -n1 );
draftHead=$(cat "$RESFINDER"/"$draftHeadSample"/contigs/ResFinder_results_tab.txt | head -n1);
finalDraftGenomeHeader="$TMP"/finalDraftGenomeHeader.txt;

#echo -e "SAMPLE\t$draftHead" > "$finalDraftGenomeHeader";
echo -e "SAMPLE\t$draftHead" > "$genResfinderDraftGenomeOut";


## write header polished reads resfinder analysis table to temp directory
readHeadSample=$(cat samples.txt | head -n1 );
readHead=$(cat "$RESFINDER"/"$readHeadSample"/reads/ResFinder_results_tab.txt | head -n1);
finalPolishedReadHeader="$TMP"/finalPolishedReadHeader.txt;

echo -e "SAMPLE\t$readHead" > "$genResfinderReadsOut";



count0=1;
countS=$(cat samples.txt | wc -l);


## draft genome parse
while [ $count0 -le $countS ];do

		SAMPLE=$(cat samples.txt | awk 'NR=='$count0 );

	echo "$SAMPLE";


## parse the output files resfinder analysis from draft genomes
FILEin1="$TMP"/"$SAMPLE".noHead1.txt;
cat "$RESFINDER"/"$SAMPLE"/contigs/ResFinder_results_tab.txt | sed '1d' > "$FILEin1";

count1=1;
countDG1=$(cat $FILEin1 | wc -l);


echo $countDG1;

while [ $count1 -le $countDG1 ];do

	LINE1=$(cat $FILEin1 | awk 'NR=='$count1 );


	echo -e "$SAMPLE\t$LINE1" >> "$genResfinderDraftGenomeOut";

count1=$((count1+1));


done 



FILEin2="$TMP"/"$SAMPLE".noHead2.txt;
cat "$RESFINDER"/"$SAMPLE"/reads/ResFinder_results_tab.txt | sed '1d' > "$FILEin2";

count2=1;
countPR1=$(cat $FILEin2 | wc -l);

echo $countPR1;

while [ $count2 -le $countPR1 ];do

	LINE2=$(cat $FILEin2 | awk 'NR=='$count2 );


	echo -e "$SAMPLE\t$LINE2" >> "$genResfinderReadsOut";

count2=$((count2+1));


done 

count0=$((count0+1));

done 



resfinderCnt=$(ls "$GENOMES"/*_contigs.fa | wc -l);


echo -e "\nRESFINDER\nfor $resfinderCnt genomes all resfinder analysis were parsed with th ecurrent database" >> "$GenRep"; 		



exit 1





