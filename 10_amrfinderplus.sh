#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-amrfinderplus;


WORKDIR="$PWD";

## update the currect database 
#amrfinder -U; # force update database


mkdir -p 10_amrfinderplus;

GENOME="$PWD"/genomes/;

## general

## construct a list of accepted organisms for analysis

amrfinder -l > REPORTING/amrfinderplus.lst;
cat REPORTING/amrfinderplus.lst | sed 's/\s/\n/g' | sed 's/,//g' | sed 1,4d > REPORTING/amrfinderplus.refined.lst;

O_lst=REPORTING/amrfinderplus.refined.lst;

S_lst="$WORKDIR"/REPORTING/SamplesSpecies.log;

count0=1;
countS=$(cat "$S_lst" | wc -l);

while [ $count0 -le $countS ];do

LINE=$(cat "$S_lst" | awk 'NR=='$count0);

echo -e "$LINE";

name=$( echo "$LINE" | cut -f1 -d$'\t');
speciesTemp=$( echo "$LINE" | cut -f2 -d$'\t');
Sarg1=$( echo "$LINE" | cut -f2 -d$'\t' | cut -f1 -d' ');
Sarg2=$( echo "$LINE" | cut -f2 -d$'\t' | cut -f2 -d' ');

Sarg1_2="$Sarg1"_"$Sarg2";

if grep -R "$Sarg1_2" "$S_lst";then

	amrfinder -n genomes/"$name".fa -O "$Sarg1_2" --report_common --report_all_equal --ident_min 0.90 --coverage_min 0.60 -o 10_amrfinderplus/"$name"/"$name".amrfinderplus.out --plus --name "$name" --nucleotide_output 10_amrfinderplus/"$name"/"$name".amr.fna --mutation_all 10_amrfinderplus/"$name"/"$name".allmutations.tab --nucleotide_flank5_size 1000 --nucleotide_flank5_output 10_amrfinderplus/"$name"/"$name".amr.flank.fna;

elif grep -R "$Sarg1" "$S_lst";then

	amrfinder -n genomes/"$name".fa -O "$Sarg1" --report_common --report_all_equal --ident_min 0.90 --coverage_min 0.60 -o 10_amrfinderplus/"$name"/"$name".amrfinderplus.out --plus --name "$name" --nucleotide_output 10_amrfinderplus/"$name"/"$name".amr.fna --mutation_all 10_amrfinderplus/"$name"/"$name".allmutations.tab --nucleotide_flank5_size 1000 --nucleotide_flank5_output 10_amrfinderplus/"$name"/"$name".amr.flank.fna;

fi


count0=$((count0+1));
done


##### amrfinderplus
#
#Identify AMR and virulence genes in proteins and/or contigs and print a report
#
#DOCUMENTATION
#    See https://github.com/ncbi/amr/wiki for full documentation
#
#UPDATES
#    Subscribe to the amrfinder-announce mailing list for database and software update notifications:
#    https://www.ncbi.nlm.nih.gov/mailman/listinfo/amrfinder-announce
#
#USAGE:   amrfinder [--update] [--force_update] [--protein PROT_FASTA] [--nucleotide NUC_FASTA] [--gff GFF_FILE] [--annotation_format ANNOTATION_FORMAT] [--database DATABASE_DIR] [--database_version] [--ident_min MIN_IDENT] [--coverage_min MIN_COV] [--organism ORGANISM] [--list_organisms] [--translation_table TRANSLATION_TABLE] [--plus] [--report_common] [--report_all_equal] [--name NAME] [--print_node] [--mutation_all MUT_ALL_FILE] [--output OUTPUT_FILE] [--protein_output PROT_FASTA_OUT] [--nucleotide_output NUC_FASTA_OUT] [--nucleotide_flank5_output NUC_FLANK5_FASTA_OUT] [--nucleotide_flank5_size NUC_FLANK5_SIZE] [--blast_bin BLAST_DIR] [--hmmer_bin HMMER_DIR] [--quiet] [--pgap] [--gpipe_org] [--parm PARM] [--threads THREADS] [--debug] [--log LOG]
#HELP:    amrfinder --help or amrfinder -h
#VERSION: amrfinder --version
#
#NAMED PARAMETERS:
#-u, --update
#    Update the AMRFinder database
#-U, --force_update
#    Force updating the AMRFinder database
#-p PROT_FASTA, --protein PROT_FASTA
#    Input protein FASTA file (can be gzipped)
#-n NUC_FASTA, --nucleotide NUC_FASTA
#    Input nucleotide FASTA file (can be gzipped)
#-g GFF_FILE, --gff GFF_FILE
#    GFF file for protein locations (can be gzipped). Protein id should be in the attribute 'Name=<id>' (9th field) of the rows with type 'CDS' or 'gene' (3rd field).
#-a ANNOTATION_FORMAT, --annotation_format ANNOTATION_FORMAT
#    Type of GFF file: bakta, genbank, microscope, patric, pgap, prodigal, prokka, pseudomonasdb, rast, standard
#    Default: genbank
#-d DATABASE_DIR, --database DATABASE_DIR
#    Alternative directory with AMRFinder database. Default: $AMRFINDER_DB
#-V, --database_version
#    Print database version
#-i MIN_IDENT, --ident_min MIN_IDENT --> 90
#    Minimum proportion of identical amino acids in alignment for hit (0..1). -1 means use a curated threshold if it exists and 0.9 otherwise
#    Default: -1
#-c MIN_COV, --coverage_min MIN_COV --> 60
#    Minimum coverage of the reference protein (0..1)
#    Default: 0.5
#-O ORGANISM, --organism ORGANISM
#    Taxonomy group. To see all possible taxonomy groups use the --list_organisms flag
#-l, --list_organisms
#    Print the list of all possible taxonomy groups for mutations identification and exit
#-t TRANSLATION_TABLE, --translation_table TRANSLATION_TABLE
#    NCBI genetic code for translated BLAST
#    Default: 11
#--plus
#    Add the plus genes to the report
#--report_common
#    Report proteins common to a taxonomy group
#--report_all_equal
#    Report all equally-scoring BLAST and HMM matches
#--name NAME
#    Text to be added as the first column "name" to all rows of the report, for example it can be an assembly name
#--print_node
#    print hierarchy node (family)
#--mutation_all MUT_ALL_FILE
#    File to report all mutations
#-o OUTPUT_FILE, --output OUTPUT_FILE
#    Write output to OUTPUT_FILE instead of STDOUT
#--protein_output PROT_FASTA_OUT
#    Output protein FASTA file of reported proteins
#--nucleotide_output NUC_FASTA_OUT
#    Output nucleotide FASTA file of reported nucleotide sequences
#--nucleotide_flank5_output NUC_FLANK5_FASTA_OUT
#    Output nucleotide FASTA file of reported nucleotide sequences with 5' flanking sequences
#--nucleotide_flank5_size NUC_FLANK5_SIZE
#    5' flanking sequence size for NUC_FLANK5_FASTA_OUT
#    Default: 0
#--blast_bin BLAST_DIR
#    Directory for BLAST. Deafult: $BLAST_BIN
#--hmmer_bin HMMER_DIR
#    Directory for HMMer
#-q, --quiet
#    Suppress messages to STDERR
#--pgap
#    Input files PROT_FASTA, NUC_FASTA and GFF_FILE are created by the NCBI PGAP
#--gpipe_org
#    NCBI internal GPipe organism names
#--parm PARM
#    amr_report parameters for testing: -nosame -noblast -skip_hmm_check -bed
#--threads THREADS
#    Max. number of threads
#    Default: 4
#--debug
#    Integrity checks
#--log LOG
#   Error log file, appended, opened on application start
#
#####
