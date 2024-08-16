#!/bin/bash

## info

## 20240105 change
## change adapterpath to the adapters within the conda env used
## tidy up
## end


# Dependencies:
#   fastqc, SHOVILL
#export

## Data organisation
## create data structure in directories
## MiSeq data is different in raw seq data as genomescan data
## This wrapper is ONLY for MiSeq data.
## MiSeq data name structure "[SAMPLENAME]_S[NUMBER]_R[1,2]_[001 or empty].fastq.gz"
## This structure can be simplified to "[SAMPLENAME]_R[1,2].fastq.gz" for easy use

### manual input of some info regarding working directories

ADAPTERPATH="/home/wbvr006/miniconda3/envs/amr-bbmap/opt/bbmap-38.98-1/resources";              # v
ADAPTER="nextera";							                               # x         # options: nextera Rubicon TAKARA truseq scriptseqv2
ASSEMBLER="spades";                                                        # y         #options: velvet megahit skesa spades
CONTIGLENGTH=300;                                                          # z

### standard output directories
WORKDIR="$PWD";									                           # w
RAW_FASTQ="$WORKDIR/RAWREADS/";                                            # a
RAWSTATS="$WORKDIR/01_rawstats/";                                          # b
POLISHED="$WORKDIR/02_polished/";                                          # c
TRIMMEDSTATS="$WORKDIR/03_trimmedstats/";                                  # d
SHOVILL="$WORKDIR/04_shovill/";                                            # e
QUAST="$WORKDIR/05_quast_analysis/";                                       # f
QUASTparse="$WORKDIR/REPORTING/";                                          # g
MLST="$WORKDIR/06_mlst/";                                                  # h
MLSTparse="$WORKDIR/REPORTING/";                                           # i
PROKKA="$WORKDIR/07a_prokka/";											   # j
TMP="$WORKDIR/TEMP/";                                                      # l
GENOMES="$WORKDIR/genomes/";											   # m
LOG="$WORKDIR/LOGS/";                                                      # n
REPORTING="$WORKDIR/REPORTING/";                                           # r
ARCHIVE="/mnt/lely_scratch/wbvr006/BACT/2021/";				        			   # q

GenRep="$REPORTING"/general-report.txt;

echo "This wrapper is only suitable for MiSeq Raw data!!!";
echo "If raw data is from GenomeScan use the other wrapper";
echo "If data from a unknown source just ask around which wrapper to use";


## file containing the sample names
SAMPLEFILE=samples.txt;

echo -e "list of all sampleNames\n\n\n";

cat "$SAMPLEFILE"; 

echo "if the sampleNames are NOT correct, ie punctuation, correct de renaming script lines! and start all over!!!!";

samplecnt=$(cat "$SAMPLEFILE" | wc -l);

echo -e "Current analysis project consists of $samplecnt samples\n" > "$GenRep";


filecnt=$(ls ./RAWREADS/*R1* | wc -l)

DIR="RAWREADS/"
if [ -d "$DIR" ] && [ "$filecnt" -gt 0 ]; then
  ### Take action if $DIR exists ###
  echo "directory is present"

# go to the root of the project

# sets most of the parameters used for the whoel pipeline
#./00_structure.sh -w $WORKDIR -a $RAW_FASTQ -b $RAWSTATS -c $POLISHED -d $TRIMMEDSTATS -e $SHOVILL -f $QUAST -g $QUASTparse -l $TMP -n $LOG -m $GENOMES; 

# qc of the raw sequencing reads 
#./01_fastqc.sh -w $WORKDIR -a $RAW_FASTQ -b $RAWSTATS -r $REPORTING -q $ARCHIVE

# will trim artefacts from the raw reads
#./02_polishdata.sh

# qc of the polished rawreads
#./03_fastqc.sh -w $WORKDIR -c $POLISHED -d $TRIMMEDSTATS -r $REPORTING -q $ARCHIVE

# assemble the genomes from the individual bacterial isolates
#./04_shovill.sh -w $WORKDIR -c $POLISHED -e $SHOVILL -y $ASSEMBLER -z $CONTIGLENGTH -r $REPORTING -m $GENOMES -q $ARCHIVE

# qc of the assmbld genomes
#./05_quast.sh -w $WORKDIR -c $POLISHED -e $SHOVILL -f $QUAST -r $REPORTING -m $GENOMES -q $ARCHIVE

## QC of the assembled genome, it checks if it's complete. Input will only be the assembled genome
#./06_busco.sh


##### ncbi-amrfinderplus

./10_amfinderinderplus.sh


##### DTU scripts

# determine the genome size and teh species of the sample output ni the REPORTING directory https://bitbucket.org/genomicepidemiology/kmerfinder/src/master/
#./11_kmerfinder.sh

# analyse reads/contigs for presents of AMR genes with corresponing databases https://bitbucket.org/genomicepidemiology/resfinder/src/master/
#./12_resfinder.sh

# identifies virulence genes https://bitbucket.org/genomicepidemiology/virulencefinder/src/master/
#./13_virulencefinder.sh

# plasmidfinder with corresponding database https://bitbucket.org/genomicepidemiology/plasmidfinder/src/master/
#./14_plasmidfinder.sh

# predicts S.aureus spa type with corresponding database https://bitbucket.org/genomicepidemiology/spatyper/src/main/
#./15_spatyper.sh

# find salmonella pathogen islands with corresponding database https://bitbucket.org/genomicepidemiology/spifinder/src/master/
#./16_spifinder.sh

# sccmec analysis for MRSA https://bitbucket.org/genomicepidemiology/sccmecfinder/src/master/
#./17_sccmec.sh

#./18_salmonella-serotyper.sh

# mobile element finder phage/virus finder https://github.com/apcamargo/genomad
#./19_genomad.sh


# mlst analysis input is the assembled genome
#./60_mlst.sh

## plasmid analysis
# another plasmid finder with corresponding database
#./51_platon-plasmid.sh
# plasmid analysis and draw maps from analysed data
#./52_plascad.sh
# mob_suite analysis mob_typer & mob_recon
#./53_mobsuite.sh

## anotatie draft genomes
#./70_prokka.sh

## fast simple clustering
#./81_mashtree.sh

## very fast taxonomic indication of isolate
#./90_sendsketch.sh -w $WORKDIR -m $GENOMES -l $TMP -n $LOG

##### optional scripts will run seperate and/or within the complete pipeline at any given moment
./99_reporting.sh
# all versions of the software used within the whole pipeline are reported in a file within the folder $REPORTING
#./versions.sh



################################################################################

# LATEN STAAN AMRFINDER ZET ALLE FILES HIER NEER EN DIT LOOPT BIJ ELK GEBRUIK OP!
rm -rf /tmp/amrfinder*.*;


### standard project directories


else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Error: ${DIR} can't found or files aren't present in the directory ${DIR}. Scripts can not continue."
  exit 1
fi
