#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-speciesfinder;

# Functie voor logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE & ARGUMENTEN ---
SAMPLES_FILE="samples.txt"
WORKDIR="$PWD"
GENOMES="$PWD/genomes"
KMER_OUT="$PWD/11_kmerfinder"
REPORTING="$PWD/REPORTING"

# --- AANGEPASTE PADEN ---
# We halen de '/' aan het einde weg om dubbele slashes te voorkomen
scriptdir="/home/wbvr006/GIT/kmerfinder"
# De exacte naam uit jouw 'ls' output
SCRIPT_BIN="$scriptdir/kmerfinder_main.py"

DB_BASE="/mnt/lely_DB/COMMUNITY_CONTRIBUTED/kmerfinder/kmerfinder_20200420/bacteria"
DB="$DB_BASE/bacteria.ATG"
TAX="$DB_BASE/bacteria.tax"

# Opvangen van vlaggen vanuit de wrapper
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:m:r:q:p:" opt; do
  case $opt in
     w) WORKDIR="$(readlink -m "$OPTARG")" ;;
     m) GENOMES="$(readlink -m "$OPTARG")" ;;
     r) REPORTING="$(readlink -m "$OPTARG")" ;;
     p) SAMPLES_FILE="$OPTARG" ;;
     a|b|c|d|e|f|g|h|i|j|k|l|n|q) : ;;
  esac
done

mkdir -p "$KMER_OUT" "$REPORTING"
speciesLog="$REPORTING/SamplesSpecies.log"
> "$speciesLog"

count0=1
countW=$(cat "$SAMPLES_FILE" | wc -l)

log "Start KmerFinder met $SCRIPT_BIN op $countW samples."

# --- 2. DE LOOP ---
while [ $count0 -le $countW ]; do

    SAMPLE=$(cat "$SAMPLES_FILE" | awk 'NR=='$count0)
    log "---------------------------------------------------"
    log "BEZIG MET: $SAMPLE ($count0/$countW)"

    FILEin="$GENOMES/${SAMPLE}.fa"
    DIRout="$KMER_OUT/$SAMPLE"

    if [ ! -f "$FILEin" ]; then
        log "SKIP: $SAMPLE - Geen FASTA gevonden in $GENOMES"
        echo -e "$SAMPLE\tNotFound" >> "$speciesLog"
        count0=$((count0+1))
        continue
    fi

    mkdir -p "$DIRout"

    # Run KmerFinder met de correcte bestandsnaam
    if [ -f "$SCRIPT_BIN" ]; then
        python "$SCRIPT_BIN" -i "$FILEin" -db "$DB" -o "$DIRout" -tax "$TAX" -x
    else
        log "FOUT: $SCRIPT_BIN niet gevonden! Controleer pad."
        exit 1
    fi

    # Parsing resultaten (Top score uit kolom 19)
    if [ -f "$DIRout/results.txt" ] && [ "$(wc -l < "$DIRout/results.txt")" -gt 1 ]; then
        species=$(sed '1d' "$DIRout/results.txt" | sort -k1,1nr | head -n1 | cut -f19 -d$'\t')
        [ -z "$species" ] && species=$(sed '1d' "$DIRout/results.txt" | sort -k1,1nr | head -n1 | cut -f2 -d$'\t')

        echo -e "$SAMPLE\t$species" >> "$speciesLog"
        log "Resultaat: $species"
    else
        echo -e "$SAMPLE\tNoHit" >> "$speciesLog"
        log "Geen hit gevonden voor $SAMPLE"
    fi

    sync
    count0=$((count0+1))

done

# --- 3. AFSLUITING ---
log "KmerFinder script voltooid."

# Sanitizer
tr -d '\15\302\240' < "$0" > "$0.tmp" && mv "$0.tmp" "$0"
chmod +x "$0"

exit 0