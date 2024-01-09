#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-genomad;

## change (2022-05-27)
## due to a error in using the "$species" variable the script is altered
## if species isn't found in point mutations db list the script will be run without this variable



# bizzy
# kijken naar de layout mbt weergeven results.
# werken we vanuit de contigs? 
# optioneel reads of reads toevoegen en optioneel kijken naar de results daarvan.
# afkap waarden positief?
# wat te doen met partieel?

cnt=$(cat samples.txt | wc -l);

mkdir -p 19_genomad/;

GENOMES=genomes;

## reporting
GenRep=REPORTING/general-report.txt;
ToDay=$(date +%Y-%m-%d-%T);

## download and install fresh genomad database 

databaseDir=/home/wbvr006/home_db/;
genomadDB=/home/wbvr006/home_db/genomad_db/;

genomad download-database "$databaseDir";

outputdir=19_genomad/;

count0=1;
countS=$(cat samples.txt | wc -l);

while [ "$count0" -le "$countS" ];do

SAMPLE=$(cat samples.txt | awk 'NR=='"$count0");

	echo $SAMPLE;

mkdir -p "$outputdir"/"$SAMPLE";


OUTDIR1="$outputdir"/"$SAMPLE";


fileIn="$GENOMES"/"$SAMPLE"_contigs.fa;


	genomad end-to-end --cleanup --splits 8 "$fileIn" "$OUTDIR1" "$genomadDB";

count0=$((count0+1));
done





exit 1

##### genomad
#
#Usage: genomad [OPTIONS] COMMAND [ARGS]...
#
# geNomad: Identification of mobile genetic elements
# Read the documentation at: https://portal.nersc.gov/genomad/
#
#╭─ Options ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
#│                                                                                                                                                                                       │
#│  --version        Show the version and exit.                                                                                                                                          │
#│  --help      -h   Show this message and exit.                                                                                                                                         │
#│                                                                                                                                                                                       │
#╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
#╭─ Database download ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
#│                                                                                                                                                                                       │
#│   download-database               Download the latest version of geNomad's database and save it in the DESTINATION directory.                                                         │
#│                                                                                                                                                                                       │
#╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
#╭─ End-to-end execution ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
#│                                                                                                                                                                                       │
#│   end-to-end   Takes an INPUT file (FASTA format) and executes all modules of the geNomad pipeline for plasmid and virus identification. Output files are written in the OUTPUT       │
#│                directory. A local copy of geNomad's database (DATABASE directory), which can be downloaded with the download-database command, is required. The end-to-end command    │
#│                omits some options. If you want to have a more granular control over the execution parameters, please execute each module separately.                                  │
#│                                                                                                                                                                                       │
#╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
#╭─ Modules ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
#│                                                                                                                                                                                       │
#│   annotate                    Predict the genes in the INPUT file (FASTA format), annotate them using geNomad's markers (located in the DATABASE directory), and write the results    │
#│                               to the OUTPUT directory.                                                                                                                                │
#│                                                                                                                                                                                       │
#│   find-proviruses             Find integrated viruses within the sequences in INPUT file using the geNomad markers (located in the DATABASE directory) and write the results to the   │
#│                               OUTPUT directory. This command depends on the data generated by the annotate module.                                                                    │
#│                                                                                                                                                                                       │
#│   marker-classification       Classify the sequences in the INPUT file (FASTA format) based on the presence of geNomad markers (located in the DATABASE directory) and write the      │
#│                               results to the OUTPUT directory. This command depends on the data generated by the annotate module.                                                     │
#│                                                                                                                                                                                       │
#│   nn-classification           Classify the sequences in the INPUT file (FASTA format) using the geNomad neural network and write the results to the OUTPUT directory.                 │
#│                                                                                                                                                                                       │
#│   aggregated-classification   Aggregate the results of the marker-classification and nn-classification modules to classify the sequences in the INPUT file (FASTA format) and write   │
#│                               the results to the OUTPUT directory.                                                                                                                    │
#│                                                                                                                                                                                       │
#│   score-calibration           Performs score calibration of the sequences in the INPUT file (FASTA format) using the batch correction method and write the results to the OUTPUT      │
#│                               directory. This module requires that at least one of the classification modules was executed previously (marker-classification, nn-classification,      │
#│                               aggregated-classification).                                                                                                                             │
#│                                                                                                                                                                                       │
#│   summary                     Applies post-classification filters, generates classification reports for the sequences in the INPUT file (FASTA format), and writes them to the        │
#│                               OUTPUT directory. This module requires that at least one of the base classification modules was executed previously (marker-classification,             │
#│                               nn-classification).                                                                                                                                     │
#│                                                                                                                                                                                       │
#╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
#
#
#####