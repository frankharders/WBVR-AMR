#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-busco;

## change 2404-01-05
## added script to pipeline for QC purposes assembled genomes
## end

## sample file
FILE=samples.txt;

## reporting
GenRep="$REPORTING"/general-report.txt;
ToDay=$(date +%Y-%m-%d-%T);

# create directory for output
mkdir -p 06_busco;

BUSCO=06_busco;
MODE=geno;
NODES=24;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");
	echo -e "$SAMPLE";

BUSCOin=genomes/"$SAMPLE".fa;
LOG=LOGS/"$SAMPLE".busco.log;

# output will be here
mkdir -p "$BUSCO"/"$SAMPLE"/;
BUSCOdir="$BUSCO"/"$SAMPLE"/;

	busco --in "$BUSCOin" --out "$BUSCOdir" --mode "$MODE" --auto-lineage-prok --cpu "$NODES" --scaffold_composition --force > "$LOG" 2>&1;

count0=$((count0+1));
done

rm -rf busco_downloads;


exit 1


##### busco
#
#
#usage: busco -i [SEQUENCE_FILE] -l [LINEAGE] -o [OUTPUT_NAME] -m [MODE] [OTHER OPTIONS]
#
#Welcome to BUSCO 5.5.0: the Benchmarking Universal Single-Copy Ortholog assessment tool.
#For more detailed usage information, please review the README file provided with this distribution and the BUSCO user guide. Visit this page https://gitlab.com/ezlab/busco#how-to-cite-busco to see how to cite BUSCO
#
#optional arguments:
#  -i SEQUENCE_FILE, --in SEQUENCE_FILE
#                        Input sequence file in FASTA format. Can be an assembled genome or transcriptome (DNA), or protein sequences from an annotated gene set. Also possible to use a path to a directory containing multiple input files.
#  -o OUTPUT, --out OUTPUT
#                        Give your analysis run a recognisable short name. Output folders and files will be labelled with this name. The path to the output folder is set with --out_path.
#  -m MODE, --mode MODE  Specify which BUSCO analysis mode to run.
#                        There are three valid modes:
#                        - geno or genome, for genome assemblies (DNA)
#                        - tran or transcriptome, for transcriptome assemblies (DNA)
#                        - prot or proteins, for annotated gene sets (protein)
#  -l LINEAGE, --lineage_dataset LINEAGE
#                        Specify the name of the BUSCO lineage to be used.
#  --augustus            Use augustus gene predictor for eukaryote runs
#  --augustus_parameters --PARAM1=VALUE1,--PARAM2=VALUE2
#                        Pass additional arguments to Augustus. All arguments should be contained within a single string with no white space, with each argument separated by a comma.
#  --augustus_species AUGUSTUS_SPECIES
#                        Specify a species for Augustus training.
#  --auto-lineage        Run auto-lineage to find optimum lineage path
#  --auto-lineage-euk    Run auto-placement just on eukaryote tree to find optimum lineage path
#  --auto-lineage-prok   Run auto-lineage just on non-eukaryote trees to find optimum lineage path
#  -c N, --cpu N         Specify the number (N=integer) of threads/cores to use.
#  --config CONFIG_FILE  Provide a config file
#  --contig_break n      Number of contiguous Ns to signify a break between contigs. Default is n=10.
#  --datasets_version DATASETS_VERSION
#                        Specify the version of BUSCO datasets, e.g. odb10
#  --download [dataset [dataset ...]]
#                        Download dataset. Possible values are a specific dataset name, "all", "prokaryota", "eukaryota", or "virus". If used together with other command line arguments, make sure to place this last.
#  --download_base_url DOWNLOAD_BASE_URL
#                        Set the url to the remote BUSCO dataset location
#  --download_path DOWNLOAD_PATH
#                        Specify local filepath for storing BUSCO dataset downloads
#  -e N, --evalue N      E-value cutoff for BLAST searches. Allowed formats, 0.001 or 1e-03 (Default: 1e-03)
#  -f, --force           Force rewriting of existing files. Must be used when output files with the provided name already exist.
#  -h, --help            Show this help message and exit
#  --limit N             How many candidate regions (contig or transcript) to consider per BUSCO (default: 3)
#  --list-datasets       Print the list of available BUSCO datasets
#  --long                Optimization Augustus self-training mode (Default: Off); adds considerably to the run time, but can improve results for some non-model organisms
#  --metaeuk_parameters "--PARAM1=VALUE1,--PARAM2=VALUE2"
#                        Pass additional arguments to Metaeuk for the first run. All arguments should be contained within a single string with no white space, with each argument separated by a comma.
#  --metaeuk_rerun_parameters "--PARAM1=VALUE1,--PARAM2=VALUE2"
#                        Pass additional arguments to Metaeuk for the second run. All arguments should be contained within a single string with no white space, with each argument separated by a comma.
#  --miniprot            Use miniprot gene predictor for eukaryote runs
#  --offline             To indicate that BUSCO cannot attempt to download files
#  --out_path OUTPUT_PATH
#                        Optional location for results folder, excluding results folder name. Default is current working directory.
#  -q, --quiet           Disable the info logs, displays only errors
#  -r, --restart         Continue a run that had already partially completed.
#  --scaffold_composition
#                        Writes ACGTN content per scaffold to a file scaffold_composition.txt
#  --tar                 Compress some subdirectories with many files to save space
#  --update-data         Download and replace with last versions all lineages datasets and files necessary to their automated selection
#  -v, --version         Show this version and exit
#
#
