#!/bin/bash


##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-mashtree;


## reporting
GenRep="$REPORTING"/general-report.txt;


cnt=$(cat samples.txt | wc -l);

mkdir -p "$PWD"/14_mashtree-bootstrap;

IN="$PWD"/Input-Mashtree-Bootstrap;
MASH="$PWD"/14_mashtree-bootstrap;
GENOME="$PWD"/genomes;
PROJECT=$(basename "$PWD");

#variables
REPS=1000;
CPU=48;

FileCnt=$(ls "$IN" | wc -l);

if [ "$FileCnt" -le 0 ];then 

	echo -e "*.fa file count = $FileCnt";
	echo -e "change the extension of the files to *.fa or copy draft genomes and/or refs into the directory $IN";

else
	echo -e "mashtree with bootstrap analysis is started with your selection and/or refs";		

		mashtree_bootstrap.pl --reps "$REPS" --numcpus "$CPU" "$IN"/*.fa -- --min-depth 0 > "$MASH"/"$PROJECT".bootstrap.dnd;# uniq kmers were deleted (more accurate); default setting are used
fi


	
exit 1

##### mashtree
#mashtree: use distances from Mash (min-hash algorithm) to make a NJ tree
#  Usage: mashtree [options] *.fastq *.fasta *.gbk *.msh > tree.dnd
#  NOTE: fastq files are read as raw reads;
#        fasta, gbk, and embl files are read as assemblies;
#        Input files can be gzipped.
#  --tempdir            ''   If specified, this directory will not be
#                            removed at the end of the script and can
#                            be used to cache results for future
#                            analyses.
#                            If not specified, a dir will be made for you
#                            and then deleted at the end of this script.
#  --numcpus            1    This script uses Perl threads.
#  --outmatrix          ''   If specified, will write a distance matrix
#                            in tab-delimited format
#  --file-of-files           If specified, mashtree will try to read
#                            filenames from each input file. The file of
#                            files format is one filename per line. This
#                            file of files cannot be compressed.
#  --outtree                 If specified, the tree will be written to
#                            this file and not to stdout. Log messages
#                            will still go to stderr.
#  --version                 Display the version and exit
#  --citation                Display the preferred citation and exit
#
#  TREE OPTIONS
#  --truncLength        250  How many characters to keep in a filename
#  --sort-order         ABC  For neighbor-joining, the sort order can
#                            make a difference. Options include:
#                            ABC (alphabetical), random, input-order
#
#  MASH SKETCH OPTIONS
#  --genomesize         5000000
#  --mindepth           5    If mindepth is zero, then it will be
#                            chosen in a smart but slower method,
#                            to discard lower-abundance kmers.
#  --kmerlength         21
#  --sketch-size        10000
#  --seed               42   Seed for mash sketch
#  --save-sketches      ''   If a directory is supplied, then sketches
#                            will be saved in it.
#                            If no directory is supplied, then sketches
#                            will be saved alongside source files.
#
#####




