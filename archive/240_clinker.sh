#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-clinker;


cnt=$(cat samples.txt | wc -l);

## reporting
GenRep="$REPORTING"/general-report.txt;

mkdir -p "$PWD"/24_clinker-out;

# (temp) variables

DEPTH=100;
MINlen=$CONTIGLENGTH;
MINcov=0;

BAKTA="$PWD"/23_bakta-out;
CLINKER="$PWD"/24_clinker-out;
NODES=48;

PROJECT=$(basename "$PWD");

BAKTAin="$GENOME"/"$SAMPLE"'_contigs.fa';

CLINKERout1="$CLINKER"/"$PROJECT".html;
CLINKERout2="$CLINKER"/"$PROJECT".csv;


clinker -j "$NODES" "$BAKTA"/*/*.gbff -p "$CLINKERout1";
clinker -j "$NODES" "$BAKTA"/*/*.gbff -o "$CLINKERout2" -dl "," -dc 4;

exit 1


##### clinker
#
#usage: clinker [-h] [--version] [-r RANGES [RANGES ...]] [-gf GENE_FUNCTIONS] [-dso] [-na] [-i IDENTITY] [-j JOBS] [-s SESSION] [-ji JSON_INDENT] [-f] [-o OUTPUT] [-p [PLOT]] [-dl DELIMITER] [-dc DECIMALS] [-hl] [-ha] [-mo MATRIX_OUT]
#               [-ufo]
#               [files ...]
#
#clinker: Automatic creation of publication-ready gene cluster comparison figures.
#
#clinker generates gene cluster comparison figures from GenBank files. It performs pairwise local or global alignments between every sequence in every unique pair of clusters and generates interactive, to-scale comparison figures using the clustermap.js library.
#
#options:
#  -h, --help            show this help message and exit
#  --version             show program's version number and exit
#
#Input options:
#  files                 Gene cluster GenBank files
#  -r RANGES [RANGES ...], --ranges RANGES [RANGES ...]
#                        Scaffold extraction ranges. If a range is specified, only features within the range will be extracted from the scaffold. Ranges should be formatted like: scaffold:start-end (e.g. scaffold_1:15000-40000)
#  -gf GENE_FUNCTIONS, --gene_functions GENE_FUNCTIONS
#                        2-column CSV file containing gene functions, used to build gene groups from same function instead of sequence similarity (e.g. GENE_001,PKS-NRPS).
#  -dso, --dont_set_origin
#                        Don't fix features which cross the origin in circular sequences (GenBank format only)
#
#Alignment options:
#  -na, --no_align       Do not align clusters
#  -i IDENTITY, --identity IDENTITY
#                        Minimum alignment sequence identity [default: 0.3]
#  -j JOBS, --jobs JOBS  Number of alignments to run in parallel (0 to use the number of CPUs) [default: 0]
#
#Output options:
#  -s SESSION, --session SESSION
#                        Path to clinker session
#  -ji JSON_INDENT, --json_indent JSON_INDENT
#                        Number of spaces to indent JSON [default: none]
#  -f, --force           Overwrite previous output file
#  -o OUTPUT, --output OUTPUT
#                        Save alignments to file
#  -p [PLOT], --plot [PLOT]
#                        Plot cluster alignments using clustermap.js. If a path is given, clinker will generate a portable HTML file at that path. Otherwise, the plot will be served dynamically using Python's HTTP server.
#  -dl DELIMITER, --delimiter DELIMITER
#                        Character to delimit output by [default: human readable]
#  -dc DECIMALS, --decimals DECIMALS
#                        Number of decimal places in output [default: 2]
#  -hl, --hide_link_headers
#                        Hide alignment column headers
#  -ha, --hide_aln_headers
#                        Hide alignment cluster name headers
#  -mo MATRIX_OUT, --matrix_out MATRIX_OUT
#                        Save cluster similarity matrix to file
#
#Visualisation options:
#  -ufo, --use_file_order
#                        Display clusters in order of input files
#
#Example usage
#-------------
#Align clusters, plot results and print scores to screen:
#  $ clinker files/*.gbk
#
#Only save gene-gene links when identity is over 50%:
#  $ clinker files/*.gbk -i 0.5
#
#Save an alignment session for later:
#  $ clinker files/*.gbk -s session.json
#
#Save alignments to file, in comma-delimited format, with 4 decimal places:
#  $ clinker files/*.gbk -o alignments.csv -dl "," -dc 4
#
#Generate visualisation:
#  $ clinker files/*.gbk -p
#
#Save visualisation as a static HTML document:
#  $ clinker files/*.gbk -p plot.html
#
#Cameron Gilchrist, 2020
#
#####
