#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-prokka;

cnt=$(cat samples.txt | wc -l);

FILE=samples.txt;

NODES=24;

## reporting
GenRep=REPORTING/general-report.txt;

mkdir -p 70_prokka;

ToDay=$(date +%Y-%m-%d-%T);


echo -e "today is $ToDay";

echo -e "prokka has run $ToDay" >> $GenRep;

mkdir -p "$dateDir";



count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");
	echo -e "$SAMPLE";

# Choose the names of the output files
prokka --outdir "$PROKKA"/"$SAMPLE" --prefix "$SAMPLE" "$GENOMES"/"$SAMPLE"_contigs.fa --cpus "$NODES";

# Visualize it in Artemis
#art mydir/mygenome.gff

count0=$((count0+1));
done




exit 1


