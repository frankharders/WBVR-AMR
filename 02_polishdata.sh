#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-bbmap;

LOG=LOGS;
RAW_FASTQ=RAWREADS;
POLISHED=02_polished;
TMP=TEMP;
ADAPTERPATH="/home/wbvr006/miniconda3/envs/amr-bbmap/opt/bbmap-38.98-1/resources";
ADAPTER=nextera;


## reporting
GenRep=REPORTING/general-report.txt;

## change 20240115
## added ktrimtips --> only look for adapters in teh region at the end of reads instead of in the whole read
## put all bbmap log files into 1 sample named log file
## tidy up
## end

FILE=samples.txt;

# (temp) variables

KTRIM='r';
TRIMQ=20;
QTRIM='rl';
TARGET=60;
TIPS=25;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ];do

SAMPLE=$(cat "$FILE" | awk 'NR=='$count0);

OUTdir="$POLISHED"/"$SAMPLE";

mkdir -p "$OUTdir";

	echo "$SAMPLE";
LOG0="$LOG"/"$SAMPLE".bbmap.log;
LOGp="$LOG"/"$SAMPLE".paired.log;

R1="$RAW_FASTQ"/"$SAMPLE"_R1.fastq.gz;
R2="$RAW_FASTQ"/"$SAMPLE"_R2.fastq.gz;	
FILTERED1="$TMP"/"$SAMPLE"_R1.filterbytile.fq.gz;
FILTERED2="$TMP"/"$SAMPLE"_R2.filterbytile.fq.gz;
CORRECTED1="$TMP"/"$SAMPLE"_R1.correct.fq.gz;
CORRECTED2="$TMP"/"$SAMPLE"_R2.correct.fq.gz;
ADAPTERout1="$TMP"/"$SAMPLE"_R1.adapter.fq.gz;
ADAPTERout2="$TMP"/"$SAMPLE"_R2.adapter.fq.gz;
QUALout1="$TMP"/"$SAMPLE"_R1.qual.fq.gz;
QUALout2="$TMP"/"$SAMPLE"_R2.qual.fq.gz;
	
	
OUTPUT1="$OUTdir"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
OUTPUT2="$OUTdir"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;	

HISTout="$OUTdir"/"$SAMPLE".ihist.txt;

echo -e "R1=$R1";
echo -e "R2=$R2";

REF="$ADAPTERPATH"/"$ADAPTER".fa.gz;
echo -e "$REF";

## verify if the raw sequence files contain the same amount of reads or contain errors
## log file will be written to the root of the project containing the name of the sample
## this checklist will develop in time

reformat.sh in1="$R1" in2="$R2" verifypaired=t ow > "$LOGp" 2>&1;

ERROR1=$(cat "$LOGp" | grep -c 'Warning');
ERROR2=$(cat "$LOGp" | grep -c 'Aborting');

ERRORcnt=$((ERROR1+ERROR2));

echo -e "errorcount=$ERRORcnt";

if [ "$ERRORcnt" -gt 0 ];then

echo -e "ERROR look at the log file $LOGp" > "$SAMPLE".error.log;

fi

# Filter bad focussed clusters from original data
filterbytile.sh in1="$R1" in2="$R2" out1="$FILTERED1" out2="$FILTERED2" ow > "$LOG0" 2>&1;

if [ -f "$FILTERED1" ] && [ -f "$FILTERED2" ];then

# READ ERROR CORRECTION
tadpole.sh in1="$FILTERED1" in2="$FILTERED2" out1="$CORRECTED1" out2="$CORRECTED2" mode=correct ow >> "$LOG0" 2>&1;
# ADAPTER TRIM
bbduk.sh -Xmx12g in1="$CORRECTED1" in2="$CORRECTED2" out1="$ADAPTERout1" out2="$ADAPTERout2" ktrimtips="$TIPS" ktrim="$KTRIM" ref="$REF" k=13 mink=6 ignorejunk=t ow >> "$LOG0" 2>&1;
# QUALITY TRIM
bbduk.sh -Xmx12g in1="$ADAPTERout1" in2="$ADAPTERout2" out1="$QUALout1" out2="$QUALout2" qtrim="$QTRIM" trimq="$TRIMQ" ow >> "$LOG0" 2>&1;
# Normalise reads for better assemblies
bbnorm.sh -Xmx12g in1="$QUALout1" in2="$QUALout2" out1="$OUTPUT1" out2="$OUTPUT2" target="$TARGET" min=5 ow >> "$LOG0" 2>&1;
# Calc insertSize from reads
bbmerge.sh in1="$OUTPUT1" in2="$OUTPUT2" ihist="$HISTout" ow >> "$LOG0" 2>&1;

else

## if whatever the reason the data can't be filtered for blurry tiles the script continues without.

# READ ERROR CORRECTION
tadpole.sh in1="$R1" in2="$R2" out1="$CORRECTED1" out2="$CORRECTED2" mode=correct ow >> "$LOG0" 2>&1; ## aangepast alleen voor deze dataset
# ADAPTER TRIM
bbduk.sh -Xmx12g in1="$CORRECTED1" in2="$CORRECTED2" out1="$ADAPTERout1" out2="$ADAPTERout2" ktrimtips="$TIPS" ktrim="$KTRIM" ref="$REF" k=13 mink=6 ignorejunk=t ow=t >> "$LOG0" 2>&1;
# QUALITY TRIM
bbduk.sh -Xmx12g in1="$ADAPTERout1" in2="$ADAPTERout2" out1="$QUALout1" out2="$QUALout2" qtrim="$QTRIM" trimq="$TRIMQ" ow >> "$LOG0" 2>&1;
# Normalise reads for better assemblies
bbnorm.sh -Xmx12g in1="$QUALout1" in2="$QUALout2" out1="$OUTPUT1" out2="$OUTPUT2" target="$TARGET" min=5 ow=t >> "$LOG0" 2>&1;
# Calc insertSize from reads
bbmerge.sh in1="$OUTPUT1" in2="$OUTPUT2" ihist="$HISTout" ow=t >> "$LOG0" 2>&1;

fi

rm "$TMP"/"$SAMPLE"*.gz;

count0=$((count0+1));
done
		
polishCnt=$(ls $POLISHED/*/*.ihist.txt | wc -l);

echo -e "\nbbmap polishing\nfrom $polishCnt samples fastq files are polished\n" >> "$GenRep";		

echo "read polishing is done for all samples";
echo -e "output files for downstream processing can be found in the directory $PROCESSED";
	
exit 1

