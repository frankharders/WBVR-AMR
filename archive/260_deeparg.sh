#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate deeparg_env;

cnt=$(cat samples.txt | wc -l);


while getopts "w:m:l:n:r:c:u:q:" opt; do
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
#GenRep="$REPORTING"/general-report.txt;
#ToDay=$(date +%Y-%m-%d-%T);

mkdir -p ./26_deeparg;

dbdir=/home/wbvr006/deeparg_db/;

echo $db;

count0=1;
countS=$(cat samples.txt | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat samples.txt | awk 'NR=='$count0);


mkdir -p ./26_deeparg/"$SAMPLE"/contigs;
mkdir -p ./26_deeparg/"$SAMPLE"/reads;

##  variables
R1=./02_polished/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
R2=./02_polished/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;
OUTr=./26_deeparg/"$SAMPLE"/contigs/"$SAMPLE";
OUTc=./26_deeparg/"$SAMPLE"/reads/"$SAMPLE";

##  using short reads for deeparg
deeparg short_reads_pipeline --forward_pe_file "$R1" --reverse_pe_file "$R2" --output_file "$OUTr" -d "$dbdir" --bowtie_16s_identity 100;

##  using draft genomes for deeparg
deeparg predict --model SS -i ./genomes/"$SAMPLE"_contigs.fa -o "$OUTc" -d "$dbdir" --type nucl --min-prob 0.8 --arg-alignment-identity 30 --arg-alignment-evalue 1e-10 --arg-num-alignments-per-entry 1000;

echo $count0;
echo $SAMPLE;

count0=$((count0+1));
done

exit 1



#### short_reads_pipeline
#usage: deeparg short_reads_pipeline [-h] --forward_pe_file FORWARD_PE_FILE
#                                    --reverse_pe_file REVERSE_PE_FILE
#                                    --output_file OUTPUT_FILE
#                                    [-d DEEPARG_DATA_PATH]
#                                    [--deeparg_identity DEEPARG_IDENTITY]
#                                    [--deeparg_probability DEEPARG_PROBABILITY]
#                                    [--deeparg_evalue DEEPARG_EVALUE]
#                                    [--gene_coverage GENE_COVERAGE]
#                                    [--bowtie_16s_identity BOWTIE_16S_IDENTITY]
#
#optional arguments:
#  -h, --help            show this help message and exit
#  --forward_pe_file FORWARD_PE_FILE
#                        forward mate from paired end library
#  --reverse_pe_file REVERSE_PE_FILE
#                        reverse mate from paired end library
#  --output_file OUTPUT_FILE
#                        save results to this file prefix
#  -d DEEPARG_DATA_PATH, --deeparg_data_path DEEPARG_DATA_PATH
#                        Path where data was downloaded [see deeparg download-
#                        data --help for details]
#  --deeparg_identity DEEPARG_IDENTITY
#                        minimum identity for ARG alignments [default 80]
#  --deeparg_probability DEEPARG_PROBABILITY
#                        minimum probability for considering a reads as ARG-
#                        like [default 0.8]
#  --deeparg_evalue DEEPARG_EVALUE
#                        minimum e-value for ARG alignments [default 1e-10]
#  --gene_coverage GENE_COVERAGE
#                        minimum coverage required for considering a full gene
#                        in percentage. This parameter looks at the full gene
#                        and all hits that align to the gene. If the overlap of
#                        all hits is below the threshold the gene is discarded.
#                        Use with caution [default 1]
#  --bowtie_16s_identity BOWTIE_16S_IDENTITY
#                        minimum identity a read as a 16s rRNA gene [default
#                        0.8]
####

#### predict
#usage: deeparg predict [-h] --model MODEL [-i INPUT_FILE] -o OUTPUT_FILE
#                       [-d DATA_PATH] [--type TYPE] [--min-prob MIN_PROB]
#                       [--arg-alignment-identity ARG_ALIGNMENT_IDENTITY]
#                       [--arg-alignment-evalue ARG_ALIGNMENT_EVALUE]
#                       [--arg-alignment-overlap ARG_ALIGNMENT_OVERLAP]
#                       [--arg-num-alignments-per-entry ARG_NUM_ALIGNMENTS_PER_ENTRY]
#                       [--model-version MODEL_VERSION]
#
#optional arguments:
#  -h, --help            show this help message and exit
#  --model MODEL         Select model to use (short sequences for reads | long
#                        sequences for genes) SS|LS [No default]
#  -i INPUT_FILE, --input-file INPUT_FILE
#                        Input file (Fasta input file)
#  -o OUTPUT_FILE, --output-file OUTPUT_FILE
#                        Output file where to store results
#  -d DATA_PATH, --data-path DATA_PATH
#                        Path where data was downloaded [see deeparg download-
#                        data --help for details]
#  --type TYPE           Molecular data type prot/nucl [Default: nucl]
#  --min-prob MIN_PROB   Minimum probability cutoff [Default: 0.8]
#  --arg-alignment-identity ARG_ALIGNMENT_IDENTITY
#                        Identity cutoff for sequence alignment in percent
#                        [Default: 50]
#  --arg-alignment-evalue ARG_ALIGNMENT_EVALUE
#                        Evalue cutoff [Default: 1e-10]
#  --arg-alignment-overlap ARG_ALIGNMENT_OVERLAP
#                        Alignment overlap cutoff between read and genes
#                        [Default: 0.8]
#  --arg-num-alignments-per-entry ARG_NUM_ALIGNMENTS_PER_ENTRY
#                        Diamond, minimum number of alignments per entry
#                        [Default: 1000]
#  --model-version MODEL_VERSION
#                        Model deepARG version [Default: v2]
####



