#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-typing;

# Functie voor logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE & ARGUMENTEN ---
SAMPLES_FILE="samples.txt"
WORKDIR="$PWD"
GENOMES="$PWD/genomes"
MLST_OUT="$PWD/60_mlst"
REPORTING="$PWD/REPORTING"

# Opvangen van vlaggen vanuit de wrapper
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:m:r:q:p:" opt; do
  case $opt in
     w) WORKDIR="$(readlink -m "$OPTARG")" ;;
     m) GENOMES="$(readlink -m "$OPTARG")" ;;
     r) REPORTING="$(readlink -m "$OPTARG")" ;;
     p) SAMPLES_FILE="$OPTARG" ;;
     # Overige vlaggen negeren voor wrapper-compatibiliteit
     a|b|c|d|e|f|g|h|i|j|k|l|n|q) : ;;
  esac
done

## Setup mappen
mkdir -p "$MLST_OUT" "$REPORTING"
GenRep="$REPORTING/general-report.txt"
SUMMARY_CSV="$REPORTING/mlst_summary_report.csv"

# Maak de verzamel-CSV leeg
> "$SUMMARY_CSV"

count0=1
countS=$(cat "$SAMPLES_FILE" | wc -l)

log "Start MLST typing op $countS samples."

# --- 2. DE LOOP ---
while [ $count0 -le $countS ]; do

    SAMPLE=$(cat "$SAMPLES_FILE" | awk 'NR=='$count0)
    log "---------------------------------------------------"
    log "BEZIG MET: $SAMPLE ($count0/$countS)"

    # Input: Gebruik .fa extensie (zoals afgesproken in Shovill stap)
    MLSTin="$GENOMES/${SAMPLE}.fa"
    MLSTout="$MLST_OUT/${SAMPLE}.mlst.csv"

    if [ ! -f "$MLSTin" ]; then
        log "SKIP: $SAMPLE - Geen FASTA gevonden in $GENOMES"
        count0=$((count0+1))
        continue
    fi

    # Run mlst (Torsten Seemann)
    # --nopath zorgt dat alleen de filenaam in de output komt
    mlst "$MLSTin" --quiet --csv --nopath > "$MLSTout"

    # Voeg resultaat toe aan de verzamel-CSV
    if [ -s "$MLSTout" ]; then
        cat "$MLSTout" >> "$SUMMARY_CSV"
    fi

    sync # NFS stabiliteit
    count0=$((count0+1))

done

# --- 3. AFSLUITING ---
log "MLST typing voltooid. Samenvatting staat in $SUMMARY_CSV"

# Update general report
mlstCnt=$(ls "$MLST_OUT"/*.csv 2>/dev/null | wc -l)
echo -e "\nMLST Typing\nVan $mlstCnt samples is het Sequence Type (ST) bepaald via PubMLST.\n" >> "$GenRep"

# Sanitizer
tr -d '\15\302\240' < "$0" > "$0.tmp" && mv "$0.tmp" "$0"
chmod +x "$0"

exit 0