#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-bbmap;


## reporting
GenRep=REPORTING/general-report.txt;

FILE=samples.txt;

mkdir -p 90_sendsketch-analysis;

SEND=90_sendsketch-analysis;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ $count0 -le $countS ];do

	SAMPLE=$(cat "$FILE" | awk 'NR=='$count0 );

sketchIn=genomes/"$SAMPLE".fa;
LOG1=LOGS/"$SAMPLE".sendsketch.log;

	sendsketch.sh in="$sketchIn" out="$SEND"/"$SAMPLE".sendsketch.tab outsketch="$SEND"/"$SAMPLE".outsketch.tab ow > "$LOG1" 2>&1;

count0=$((count0+1));

done

exit 1






