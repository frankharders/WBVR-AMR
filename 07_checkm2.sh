#!/usr/bin/env bash
set -euo pipefail

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate checkm2;

# Functie voor logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE & ARGUMENTEN ---
WORKDIR="$PWD"
GENOMES="$PWD/genomes"
CHECKM2_OUT="$PWD/07_checkm2"
REPORTING="$PWD/REPORTING"
NODES=24
EXT="fa"

# HET NIEUWE DATABASE PAD
DB="/mnt/lely_DB/COMMUNITY_CONTRIBUTED/harde004/CheckM2_database/uniref100.KO.1.dmnd"

# Opvangen van vlaggen vanuit de wrapper
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:m:r:q:p:" opt; do
  case $opt in
     w) WORKDIR="$(readlink -m "$OPTARG")" ;;
     m) GENOMES="$(readlink -m "$OPTARG")" ;;
     r) REPORTING="$(readlink -m "$OPTARG")" ;;
     # Overige vlaggen negeren om wrapper-compatibel te blijven
     a|b|c|d|e|f|g|h|i|j|k|l|n|q|p) : ;;
  esac
done

## reporting setup
GenRep="$REPORTING/general-report.txt"
mkdir -p "$CHECKM2_OUT"

log "Start CheckM2 op folder: $GENOMES"
log "Gebruikte DB: $DB"

# --- 2. RUN CHECKM2 ---
# We controleren eerst of er wel .fa bestanden zijn om DIAMOND-errors te voorkomen
if [ -d "$GENOMES" ] && [ "$(ls -A "$GENOMES"/*."$EXT" 2>/dev/null)" ]; then
    
    log "Draaien CheckM2 predict..."
    
    checkm2 predict \
        --threads "$NODES" \
        --input "$GENOMES" \
        --output-directory "$CHECKM2_OUT" \
        --force \
        --database_path "$DB" \
        --allmodels \
        -x "$EXT" \
        --remove_intermediates;

    # Belangrijk voor NFS stabiliteit (leegmaken buffers)
    sync
    log "CheckM2 predictie voltooid."

else
    log "FOUT: Geen .$EXT bestanden gevonden in $GENOMES!"
    exit 1
fi

# --- 3. RAPPORTAGE ---
if [ -f "$CHECKM2_OUT/quality_report.tsv" ]; then
    echo -e "\nCheckM2\nCompleteness en Contamination stats zijn berekend voor alle genomes in $GENOMES.\n" >> "$GenRep"
    log "Rapportage bijgewerkt in $GenRep"
fi

# Sanitizer (verwijder verborgen karakters)
tr -d '\15\302\240' < "$0" > "$0.tmp" && mv "$0.tmp" "$0"
chmod +x "$0"

log "CheckM2 script is gereed."
exit 0