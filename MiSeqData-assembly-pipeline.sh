#!/bin/bash

## info
## 20240105 change
## change adapterpath to the adapters within the conda env used
## tidy up
## 20260402: Samengevoegde versie met alle tools en verbeterde foutafhandeling
## end

# Dependencies: fastqc, SHOVILL, etc.

### manual input of some info regarding working directories
ADAPTERPATH="/home/wbvr006/miniconda3/envs/amr-bbmap/opt/bbmap-38.98-1/resources"; # v
ADAPTER="nextera";                                                              # x
ASSEMBLER="spades";                                                             # y
CONTIGLENGTH=300;                                                               # z

### standard output directories
WORKDIR="$PWD";                                                                 # w
RAW_FASTQ="$WORKDIR/RAWREADS/";                                                 # a
RAWSTATS="$WORKDIR/01_rawstats/";                                               # b
POLISHED="$WORKDIR/02_polished/";                                               # c
TRIMMEDSTATS="$WORKDIR/03_trimmedstats/";                                       # d
SHOVILL="$WORKDIR/04_shovill/";                                                 # e
QUAST="$WORKDIR/05_quast_analysis/";                                           # f
QUASTparse="$WORKDIR/REPORTING/";                                               # g
MLST="$WORKDIR/06_mlst/";                                                       # h
MLSTparse="$WORKDIR/REPORTING/";                                                # i
PROKKA="$WORKDIR/07a_prokka/";                                                  # j
TMP="$WORKDIR/TEMP/";                                                           # l
ASSEMBLY_DIR="$WORKDIR/genomes/";                                               # m (was GENOMES)
LOG="$WORKDIR/LOGS/";                                                           # n
REPORTING="$WORKDIR/REPORTING/";                                                # r
ARCHIVE="/mnt/lely_scratch/wbvr006/BACT/2021/";                                 # q

GenRep="$REPORTING"/general-report.txt;

# Mappen aanmaken voor de start
for d in "$RAWSTATS" "$POLISHED" "$TRIMMEDSTATS" "$SHOVILL" "$QUAST" "$TMP" "$ASSEMBLY_DIR" "$LOG" "$REPORTING" "$MLST" "$PROKKA"; do
    mkdir -p "$d"
done

echo "This wrapper is only suitable for MiSeq Raw data!!!";
echo "If raw data is from GenomeScan use the other wrapper";

## file containing the sample names
SAMPLEFILE=samples.txt;

if [ ! -f "$SAMPLEFILE" ]; then
    echo "Error: $SAMPLEFILE niet gevonden!";
    exit 1
fi

echo -e "list of all sampleNames\n\n\n";
cat "$SAMPLEFILE"; 

samplecnt=$(cat "$SAMPLEFILE" | wc -l);
echo -e "Current analysis project consists of $samplecnt samples\n" > "$GenRep";

# Functie voor foutcontrole
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed. Check logs for details."
        exit 1
    fi
}

filecnt=$(ls ./RAWREADS/*R1* 2>/dev/null | wc -l)
DIR="RAWREADS/"

if [ -d "$DIR" ] && [ "$filecnt" -gt 0 ]; then
  echo "Directory is present and contains files. Starting pipeline..."

# 00 Structure (voor de zekerheid, hoewel mappen hierboven al gemaakt worden)
#./00_structure.sh -w "$WORKDIR" -a "$RAW_FASTQ" -b "$RAWSTATS" -c "$POLISHED" -d "$TRIMMEDSTATS" -e "$SHOVILL" -f "$QUAST" -g "$QUASTparse" -l "$TMP" -n "$LOG" -m "$ASSEMBLY_DIR"
check_status "00_structure.sh"

# 01 QC Raw reads
#./01_fastqc.sh -w "$WORKDIR" -a "$RAW_FASTQ" -b "$RAWSTATS" -r "$REPORTING" -q "$ARCHIVE"
check_status "01_fastqc.sh"

# 02 Trimming / Polishing (Nu met expliciete paden voor de zekerheid)
#./02_polishdata.sh -w "$WORKDIR" -a "$RAW_FASTQ" -c "$POLISHED" -l "$TMP" -n "$LOG" -r "$REPORTING" -p "$SAMPLEFILE"
check_status "02_polishdata.sh"

# 03 QC Polished reads
#./03_fastqc.sh -w "$WORKDIR" -c "$POLISHED" -d "$TRIMMEDSTATS" -r "$REPORTING" -q "$ARCHIVE"
check_status "03_fastqc.sh"

# 04 Assembly: SHOVILL
#./04_shovill.sh -w "$WORKDIR" -c "$POLISHED" -e "$SHOVILL" -y "$ASSEMBLER" -z "$CONTIGLENGTH" -r "$REPORTING" -m "$ASSEMBLY_DIR" -q "$ARCHIVE"
check_status "04_shovill.sh"

# 05 QC Assembly: QUAST
#./05_quast.sh -w "$WORKDIR" -c "$POLISHED" -e "$SHOVILL" -f "$QUAST" -r "$REPORTING" -m "$ASSEMBLY_DIR" -q "$ARCHIVE"
check_status "05_quast.sh"

# 06 & 07 Completion checks
#./06_busco.sh
#./07_checkm2.sh

# 10 AMR & Species identification
#./10_amfinderplus.sh
#./11_kmerfinder.sh
./12_resfinder.sh

# Optionele DTU Tools (staan uitgevinkt zoals in je origineel)
# ./13_virulencefinder.sh
# ./14_plasmidfinder.sh
# ./15_spatyper.sh
# ./16_spifinder.sh
# ./17_sccmec.sh
# ./18_salmonella-serotyper.sh
# ./19_genomad.sh

# 60 MLST
#./60_mlst.sh
check_status "60_mlst.sh"

# Optionele Plasmid/Annotatie Tools
# ./51_platon-plasmid.sh
# ./52_plascad.sh
# ./53_mobsuite.sh
# ./70_prokka.sh
# ./81_mashtree.sh

# 90 Taxonomic indication
#./90_sendsketch.sh -w "$WORKDIR" -m "$ASSEMBLY_DIR" -l "$TMP" -n "$LOG"
check_status "90_sendsketch.sh"

# 99 Reporting
#./99_reporting.sh
# ./versions.sh

# Opschonen tijdelijke AMRfinder bestanden
rm -rf /tmp/amrfinder*.*;

echo "Pipeline afgerond!"

else
  echo "Error: ${DIR} niet gevonden of geen R1 bestanden aanwezig. Script gestopt."
  exit 1
fi
