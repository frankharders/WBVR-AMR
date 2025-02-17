#!/bin/bash
#
##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate Plascad;

## 20240105 tidy up the script;
## end

FILE=samples.txt;


cnt=$(cat samples.txt | wc -l);

## reporting
GenRep=REPORTING/general-report.txt;


# (temp) variables

mkdir -p 52_plascad-plasmids;

GENOME=genomes;
PLASMID=52_plascad-plasmids;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");
	echo -e "$SAMPLE";

mkdir -p "$PLASMID"/"$SAMPLE";

cp "$GENOME"/"$SAMPLE"'.fa' "$PLASMID";

GENOMEin="$PLASMID"/"$SAMPLE".fasta;

mv "$PLASMID"/"$SAMPLE"'.fa' "$GENOMEin";

	Plascad -i "$GENOMEin" ;


count0=$((count0+1));
done
exit 1

##### Plascad
#
#usage: Plascad [-h] [-i I] [-n] [-cMOBB CMOBB] [-cMOBC CMOBC] [-cMOBF CMOBF] [-cMOBT CMOBT] [-cMOBPB CMOBPB] [-cMOBH CMOBH] [-cMOBP CMOBP] [-cMOBV CMOBV] [-cMOBQ CMOBQ]
#
#options:
#  -h, --help      show this help message and exit
#  -i I            input plasmids file for classification
#  -n              prodigal normal mode
#  -cMOBB CMOBB    alignment coverage for MOBB HMM profile
#  -cMOBC CMOBC    alignment coverage for MOBC HMM profile
#  -cMOBF CMOBF    alignment coverage for MOBF HMM profile
#  -cMOBT CMOBT    alignment coverage for MOBT HMM profile
#  -cMOBPB CMOBPB  alignment coverage for MOBPB HMM profile
#  -cMOBH CMOBH    alignment coverage for MOBH HMM profile
#  -cMOBP CMOBP    alignment coverage for MOBP HMM profile
#  -cMOBV CMOBV    alignment coverage for MOBV HMM profile
#  -cMOBQ CMOBQ    alignment coverage for MOBQ HMM profile
#
#####
