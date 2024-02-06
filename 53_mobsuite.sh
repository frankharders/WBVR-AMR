#!/bin/bash
#
##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-mobsuite;

## 20240206 added to standard pipeline;
## end

FILE=samples.txt;
NODES=24;

cnt=$(cat samples.txt | wc -l);

## reporting
GenRep=REPORTING/general-report.txt;


# (temp) variables

mkdir -p 53_mobsuite;

GENOME=genomes;
MOBSUITE=53_mobsuite;

count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ]; do 

SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");
	echo -e "$SAMPLE";

mkdir -p "$MOBSUITE"/"$SAMPLE";
mkdir -p "$MOBSUITE"/"$SAMPLE"/mob_recon;
DIRout="$MOBSUITE"/"$SAMPLE"/mob_recon;
FILEout="$MOBSUITE"/"$SAMPLE"/"$SAMPLE".mobtyper.txt;

GENOMEin="$GENOME"/"$SAMPLE"_contigs.fa;
MGEreport="$MOBSUITE"/"$SAMPLE"/"$SAMPLE".MGE.report.txt;


mob_typer -i "$GENOMEin" --multi -o "$FILEout" -n "$NODES" -g "$MGEreport" -s "$SAMPLE" --analysis_dir TEMP/;

mob_recon -i "$GENOMEin" -o "$DIRout" -n "$NODES" -s "$SAMPLE" --force;

count0=$((count0+1));
done
exit 1

##### mobsuite

##### mob_typer
#
#usage: mob_typer [-h] -i INFILE -o OUT_FILE [--biomarker_report_file BIOMARKER_REPORT_FILE] [-g MGE_REPORT_FILE] [-a ANALYSIS_DIR] [-n NUM_THREADS] [-s SAMPLE_ID] [-x]
#                 [--min_rep_evalue MIN_REP_EVALUE] [--min_mob_evalue MIN_MOB_EVALUE] [--min_con_evalue MIN_CON_EVALUE] [--min_length MIN_LENGTH] [--min_rep_ident MIN_REP_IDENT]
#                 [--min_mob_ident MIN_MOB_IDENT] [--min_con_ident MIN_CON_IDENT] [--min_rpp_ident MIN_RPP_IDENT] [--min_rep_cov MIN_REP_COV] [--min_mob_cov MIN_MOB_COV]
#                 [--min_con_cov MIN_CON_COV] [--min_rpp_cov MIN_RPP_COV] [--min_rpp_evalue MIN_RPP_EVALUE] [--min_overlap MIN_OVERLAP] [-k] [--debug]
#                 [--plasmid_mash_db PLASMID_MASH_DB] [-m PLASMID_META] [--plasmid_db_type PLASMID_DB_TYPE] [--plasmid_replicons PLASMID_REPLICONS] [--repetitive_mask REPETITIVE_MASK]
#                 [--plasmid_mob PLASMID_MOB] [--plasmid_mpf PLASMID_MPF] [--plasmid_orit PLASMID_ORIT] [-d DATABASE_DIRECTORY] [--primary_cluster_dist PRIMARY_CLUSTER_DIST] [-V]
#
#MOB-Typer: Plasmid typing and mobility prediction: 3.1.8
#
#options:
#  -h, --help            show this help message and exit
#  -i INFILE, --infile INFILE
#                        Input assembly fasta file to process (default: None)
#  -o OUT_FILE, --out_file OUT_FILE
#                        Output file to write results (default: None)
#  --biomarker_report_file BIOMARKER_REPORT_FILE
#                        Output file for biomarker blast results (default: None)
#  -g MGE_REPORT_FILE, --mge_report_file MGE_REPORT_FILE
#                        Output file for MGE results (default: None)
#  -a ANALYSIS_DIR, --analysis_dir ANALYSIS_DIR
#                        Working directory for storing temporary results (default: None)
#  -n NUM_THREADS, --num_threads NUM_THREADS
#                        Number of threads to be used (default: 1)
#  -s SAMPLE_ID, --sample_id SAMPLE_ID
#                        Sample Prefix for reports (default: None)
#  -x, --multi           Treat each sequence as an independant plasmid (default: False)
#  --min_rep_evalue MIN_REP_EVALUE
#                        Minimum evalue threshold for replicon blastn (default: 1e-05)
#  --min_mob_evalue MIN_MOB_EVALUE
#                        Minimum evalue threshold for relaxase tblastn (default: 1e-05)
#  --min_con_evalue MIN_CON_EVALUE
#                        Minimum evalue threshold for contig blastn (default: 1e-05)
#  --min_length MIN_LENGTH
#                        Minimum length of blast hits (default: 500)
#  --min_rep_ident MIN_REP_IDENT
#                        Minimum sequence identity for replicons (default: 80)
#  --min_mob_ident MIN_MOB_IDENT
#                        Minimum sequence identity for relaxases (default: 80)
#  --min_con_ident MIN_CON_IDENT
#                        Minimum sequence identity for contigs (default: 80)
#  --min_rpp_ident MIN_RPP_IDENT
#                        Minimum sequence identity for MGE (default: 80)
#  --min_rep_cov MIN_REP_COV
#                        Minimum percentage coverage of replicon query by input assembly (default: 80)
#  --min_mob_cov MIN_MOB_COV
#                        Minimum percentage coverage of relaxase query by input assembly (default: 80)
#  --min_con_cov MIN_CON_COV
#                        Minimum percentage coverage of assembly contig by the plasmid reference database to be considered (default: 70)
#  --min_rpp_cov MIN_RPP_COV
#                        Minimum percentage coverage of MGE (default: 80)
#  --min_rpp_evalue MIN_RPP_EVALUE
#                        Minimum evalue threshold for repetitve elements blastn (default: 1e-05)
#  --min_overlap MIN_OVERLAP
#                        Minimum overlap of fragments (default: 10)
#  -k, --keep_tmp        Do not delete temporary file directory (default: False)
#  --debug               Show debug information (default: False)
#  --plasmid_mash_db PLASMID_MASH_DB
#                        Companion Mash database of reference database (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/ncbi_plasmid_full_seqs.fas.msh)
#  -m PLASMID_META, --plasmid_meta PLASMID_META
#                        MOB-cluster plasmid cluster formatted file matched to the reference plasmid db (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/clusters.txt)
#  --plasmid_db_type PLASMID_DB_TYPE
#                        Blast database type of reference database (default: blastn)
#  --plasmid_replicons PLASMID_REPLICONS
#                        Fasta of plasmid replicons (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/rep.dna.fas)
#  --repetitive_mask REPETITIVE_MASK
#                        Fasta of known repetitive elements (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/repetitive.dna.fas)
#  --plasmid_mob PLASMID_MOB
#                        Fasta of plasmid relaxases (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/mob.proteins.faa)
#  --plasmid_mpf PLASMID_MPF
#                        Fasta of known plasmid mate-pair proteins (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/mpf.proteins.faa)
#  --plasmid_orit PLASMID_ORIT
#                        Fasta of known plasmid oriT dna sequences (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/orit.fas)
#  -d DATABASE_DIRECTORY, --database_directory DATABASE_DIRECTORY
#                        Directory you want to use for your databases. If the databases are not already downloaded, they will be downloaded automatically. Defaults to
#                        /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases (default: /home/wbvr006/miniconda3/envs/amr-
#                        mobsuite/lib/python3.11/site-packages/mob_suite/databases)
#  --primary_cluster_dist PRIMARY_CLUSTER_DIST
#                        Mash distance for assigning primary cluster id 0 - 1 (default: 0.06)
#  -V, --version         show program's version number and exit
#
#####

##### mob_recon
#
#
#usage: mob_recon [-h] -o OUTDIR -i INFILE [-n NUM_THREADS] [-s SAMPLE_ID] [-f] [-b FILTER_DB] [-g GENOME_FILTER_DB_PREFIX] [-p PREFIX]
#                 [--mash_genome_neighbor_threshold MASH_GENOME_NEIGHBOR_THRESHOLD] [--max_contig_size MAX_CONTIG_SIZE] [--max_plasmid_size MAX_PLASMID_SIZE]
#                 [--min_rep_evalue MIN_REP_EVALUE] [--min_mob_evalue MIN_MOB_EVALUE] [--min_con_evalue MIN_CON_EVALUE] [--min_rpp_evalue MIN_RPP_EVALUE] [--min_length MIN_LENGTH]
#                 [--min_rep_ident MIN_REP_IDENT] [--min_mob_ident MIN_MOB_IDENT] [--min_con_ident MIN_CON_IDENT] [--min_rpp_ident MIN_RPP_IDENT] [--min_rep_cov MIN_REP_COV]
#                 [--min_mob_cov MIN_MOB_COV] [--min_con_cov MIN_CON_COV] [--min_rpp_cov MIN_RPP_COV] [--min_overlap MIN_OVERLAP] [-u] [-c] [-k] [--debug] [--plasmid_db PLASMID_DB]
#                 [--plasmid_mash_db PLASMID_MASH_DB] [-m PLASMID_META] [--plasmid_db_type PLASMID_DB_TYPE] [--plasmid_replicons PLASMID_REPLICONS] [--repetitive_mask REPETITIVE_MASK]
#                 [--plasmid_mob PLASMID_MOB] [--plasmid_mpf PLASMID_MPF] [--plasmid_orit PLASMID_ORIT] [-d DATABASE_DIRECTORY] [--primary_cluster_dist PRIMARY_CLUSTER_DIST]
#                 [--secondary_cluster_dist SECONDARY_CLUSTER_DIST] [-V]
#
#MOB-Recon: Typing and reconstruction of plasmids from draft and complete assemblies version: 3.1.8
#
#options:
#  -h, --help            show this help message and exit
#  -o OUTDIR, --outdir OUTDIR
#                        Output Directory to put results (default: None)
#  -i INFILE, --infile INFILE
#                        Input assembly fasta file to process (default: None)
#  -n NUM_THREADS, --num_threads NUM_THREADS
#                        Number of threads to be used (default: 1)
#  -s SAMPLE_ID, --sample_id SAMPLE_ID
#                        Sample Prefix for reports (default: None)
#  -f, --force           Overwrite existing directory (default: False)
#  -b FILTER_DB, --filter_db FILTER_DB
#                        Path to fasta file to mask sequences (default: None)
#  -g GENOME_FILTER_DB_PREFIX, --genome_filter_db_prefix GENOME_FILTER_DB_PREFIX
#                        Prefix of mash sketch and blastdb of closed chromosomes to use for auto selection of close genomes for filtering (default: None)
#  -p PREFIX, --prefix PREFIX
#                        Prefix to append to result files (default: None)
#  --mash_genome_neighbor_threshold MASH_GENOME_NEIGHBOR_THRESHOLD
#                        Mash distance selecting valid closed genomes to filter (default: 0.002)
#  --max_contig_size MAX_CONTIG_SIZE
#                        Maximum size of a contig to be considered a plasmid (default: 450000)
#  --max_plasmid_size MAX_PLASMID_SIZE
#                        Maximum size of a reconstructed plasmid (default: 450000)
#  --min_rep_evalue MIN_REP_EVALUE
#                        Minimum evalue threshold for replicon blastn (default: 1e-05)
#  --min_mob_evalue MIN_MOB_EVALUE
#                        Minimum evalue threshold for relaxase tblastn (default: 1e-05)
#  --min_con_evalue MIN_CON_EVALUE
#                        Minimum evalue threshold for contig blastn (default: 1e-05)
#  --min_rpp_evalue MIN_RPP_EVALUE
#                        Minimum evalue threshold for repetitve elements blastn (default: 1e-05)
#  --min_length MIN_LENGTH
#                        Minimum length of contigs to classify (default: 1000)
#  --min_rep_ident MIN_REP_IDENT
#                        Minimum sequence identity for replicons (default: 80)
#  --min_mob_ident MIN_MOB_IDENT
#                        Minimum sequence identity for relaxases (default: 80)
#  --min_con_ident MIN_CON_IDENT
#                        Minimum sequence identity for contigs (default: 80)
#  --min_rpp_ident MIN_RPP_IDENT
#                        Minimum sequence identity for repetitive elements (default: 80)
#  --min_rep_cov MIN_REP_COV
#                        Minimum percentage coverage of replicon query by input assembly (default: 80)
#  --min_mob_cov MIN_MOB_COV
#                        Minimum percentage coverage of relaxase query by input assembly (default: 80)
#  --min_con_cov MIN_CON_COV
#                        Minimum percentage coverage of assembly contig by the plasmid reference database to be considered (default: 60)
#  --min_rpp_cov MIN_RPP_COV
#                        Minimum percentage coverage of contigs by repetitive elements (default: 80)
#  --min_overlap MIN_OVERLAP
#                        Minimum overlap of fragments (default: 10)
#  -u, --unicycler_contigs
#                        Check for circularity flag generated by unicycler in fasta headers (default: False)
#  -c, --run_overhang    Detect circular contigs with assembly overhangs (default: False)
#  -k, --keep_tmp        Do not delete temporary file directory (default: False)
#  --debug               Show debug information (default: False)
#  --plasmid_db PLASMID_DB
#                        Reference Database of complete plasmids (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/ncbi_plasmid_full_seqs.fas)
#  --plasmid_mash_db PLASMID_MASH_DB
#                        Companion Mash database of reference database (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/ncbi_plasmid_full_seqs.fas.msh)
#  -m PLASMID_META, --plasmid_meta PLASMID_META
#                        MOB-cluster plasmid cluster formatted file matched to the reference plasmid db (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/clusters.txt)
#  --plasmid_db_type PLASMID_DB_TYPE
#                        Blast database type of reference database (default: blastn)
#  --plasmid_replicons PLASMID_REPLICONS
#                        Fasta of plasmid replicons (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/rep.dna.fas)
#  --repetitive_mask REPETITIVE_MASK
#                        Fasta of known repetitive elements (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/repetitive.dna.fas)
#  --plasmid_mob PLASMID_MOB
#                        Fasta of plasmid relaxases (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/mob.proteins.faa)
#  --plasmid_mpf PLASMID_MPF
#                        Fasta of known plasmid mate-pair proteins (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-
#                        packages/mob_suite/databases/mpf.proteins.faa)
#  --plasmid_orit PLASMID_ORIT
#                        Fasta of known plasmid oriT dna sequences (default: /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases/orit.fas)
#  -d DATABASE_DIRECTORY, --database_directory DATABASE_DIRECTORY
#                        Directory you want to use for your databases. If the databases are not already downloaded, they will be downloaded automatically. Defaults to
#                        /home/wbvr006/miniconda3/envs/amr-mobsuite/lib/python3.11/site-packages/mob_suite/databases (default: /home/wbvr006/miniconda3/envs/amr-
#                        mobsuite/lib/python3.11/site-packages/mob_suite/databases)
#  --primary_cluster_dist PRIMARY_CLUSTER_DIST
#                        Mash distance for assigning primary cluster id 0 - 1 (default: 0.06)
#  --secondary_cluster_dist SECONDARY_CLUSTER_DIST
#                        Mash distance for assigning primary cluster id 0 - 1 (default: 0.025)
#  -V, --version         show program's version number and exit
#
#####

