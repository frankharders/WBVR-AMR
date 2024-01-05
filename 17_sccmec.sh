#!/bin/bash
#
##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-sccmec;

## change 20240115
## create 1 table instead of sample specific tables with results
## tidy up
## end

## reporting
GenRep="$REPORTING"/general-report.txt;

FILE=samples.txt;

# (temp) variables

mkdir -p 17_sccmec;

GENOME=genomes;
SCCMEC=17_sccmec;

SCCMEC1="$SCCMEC"/project.tsv;

	staphopia-sccmec --assembly "$GENOME" --ext fa > "$SCCMEC1";#--sccmec "$SCCMECout" --ext fasta ;



exit 1

##### staphopia-sccmec
#
#usage: staphopia-sccmec [-h] [--assembly ASSEMBLY|ASSEMBLY_DIR|STAPHOPIA_DIR] [--staphopia STAPHOPIA_DIR] [--sccmec SCCMEC_DATA] [--ext STR] [--hamming] [--json] [--debug] [--depends] [--test] [--citation] [--version]
#
#Determine SCCmec Type/SubType
#
#options:
#  -h, --help            show this help message and exit
#
#Options:
#
#  --assembly ASSEMBLY|ASSEMBLY_DIR|STAPHOPIA_DIR
#                        Input assembly (FASTA format), directory of assemblies to predict SCCmec. (Cannot be used with --staphopia)
#  --staphopia STAPHOPIA_DIR
#                        Input directory of samples processed by Staphopia. (Cannot be used with --assembly)
#  --sccmec SCCMEC_DATA  Directory where SCCmec reference data is stored (Default: /home/wbvr006/miniconda3/envs/amr-sccmec/share/staphopia-sccmec/data).
#  --ext STR             Extension used by assemblies. (Default: fna)
#  --hamming             Report the hamming distance of each type.
#  --json                Report the output as JSON (Default: tab-delimited)
#  --debug               Print debug related text.
#  --depends             Verify dependencies are installed/found.
#  --test                Run with example test data.
#  --citation            Print citation information for using Staphopia SCCmec
#  --version             show program's version number and exit
#
#
#####
