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

GENOMES=genomes;
PROKKA=70_prokka;

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
prokka --outdir "$PROKKA"/"$SAMPLE" --prefix "$SAMPLE" "$GENOMES"/"$SAMPLE".fa --cpus "$NODES";

# Visualize it in Artemis
#art mydir/mygenome.gff

count0=$((count0+1));
done




exit 1

##### prokka
#
#Name:
#  Prokka 1.14.6 by Torsten Seemann <torsten.seemann@gmail.com>
#Synopsis:
#  rapid bacterial genome annotation
#Usage:
#  prokka [options] <contigs.fasta>
#General:
#  --help             This help
#  --version          Print version and exit
#  --citation         Print citation for referencing Prokka
#  --quiet            No screen output (default OFF)
#  --debug            Debug mode: keep all temporary files (default OFF)
#Setup:
#  --dbdir [X]        Prokka database root folders (default '/home/wbvr006/miniconda3/envs/amr-prokka/db')
#  --listdb           List all configured databases
#  --setupdb          Index all installed databases
#  --cleandb          Remove all database indices
#  --depends          List all software dependencies
#Outputs:
#  --outdir [X]       Output folder [auto] (default '')
#  --force            Force overwriting existing output folder (default OFF)
#  --prefix [X]       Filename output prefix [auto] (default '')
#  --addgenes         Add 'gene' features for each 'CDS' feature (default OFF)
#  --addmrna          Add 'mRNA' features for each 'CDS' feature (default OFF)
#  --locustag [X]     Locus tag prefix [auto] (default '')
#  --increment [N]    Locus tag counter increment (default '1')
#  --gffver [N]       GFF version (default '3')
#  --compliant        Force Genbank/ENA/DDJB compliance: --addgenes --mincontiglen 200 --centre XXX (default OFF)
#  --centre [X]       Sequencing centre ID. (default '')
#  --accver [N]       Version to put in Genbank file (default '1')
#Organism details:
#  --genus [X]        Genus name (default 'Genus')
#  --species [X]      Species name (default 'species')
#  --strain [X]       Strain name (default 'strain')
#  --plasmid [X]      Plasmid name or identifier (default '')
#Annotations:
#  --kingdom [X]      Annotation mode: Archaea|Bacteria|Mitochondria|Viruses (default 'Bacteria')
#  --gcode [N]        Genetic code / Translation table (set if --kingdom is set) (default '0')
#  --prodigaltf [X]   Prodigal training file (default '')
#  --gram [X]         Gram: -/neg +/pos (default '')
#  --usegenus         Use genus-specific BLAST databases (needs --genus) (default OFF)
#  --proteins [X]     FASTA or GBK file to use as 1st priority (default '')
#  --hmms [X]         Trusted HMM to first annotate from (default '')
#  --metagenome       Improve gene predictions for highly fragmented genomes (default OFF)
#  --rawproduct       Do not clean up /product annotation (default OFF)
#  --cdsrnaolap       Allow [tr]RNA to overlap CDS (default OFF)
#Matching:
#  --evalue [n.n]     Similarity e-value cut-off (default '1e-09')
#  --coverage [n.n]   Minimum coverage on query protein (default '80')
#Computation:
#  --cpus [N]         Number of CPUs to use [0=all] (default '8')
#  --fast             Fast mode - only use basic BLASTP databases (default OFF)
#  --noanno           For CDS just set /product="unannotated protein" (default OFF)
#  --mincontiglen [N] Minimum contig size [NCBI needs 200] (default '1')
#  --rfam             Enable searching for ncRNAs with Infernal+Rfam (SLOW!) (default '0')
#  --norrna           Don't run rRNA search (default OFF)
#  --notrna           Don't run tRNA search (default OFF)
#  --rnammer          Prefer RNAmmer over Barrnap for rRNA prediction (default OFF)
#
#
#####

