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


while getopts "w:m:l:n:r:c:q:" opt; do
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

genomadDB=/home/wbvr006/home_db/genomad_db/;

outputdir="$WORKDIR"/25_genomad/;

count0=1;
countS=$(cat samples.txt | wc -l);

while [ "$count0" -le "$countS" ];do

SAMPLE=$(cat samples.txt | awk 'NR=='"$count0");

	echo $SAMPLE;

mkdir -p "$outputdir"/"$SAMPLE";


OUTDIR1="$outputdir"/"$SAMPLE";


fileIn="$GENOMES"/"$SAMPLE"_contigs.fa;


genomad end-to-end --cleanup --splits 8 $fileIn $OUTDIR1 $genomadDB;

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