#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-bbmap;

# Functie voor logging naar terminal
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE & ARGUMENTEN ---
SAMPLES_FILE="samples.txt"
WORKDIR="$PWD"
GENOMES="$PWD/genomes"
SEND_OUT="$PWD/90_sendsketch-analysis"
LOGDIR="$PWD/LOGS"
REPORTING="$PWD/REPORTING"

# Opvangen van vlaggen vanuit de wrapper
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:m:r:q:p:" opt; do
  case $opt in
     w) WORKDIR="$(readlink -m "$OPTARG")" ;;
     m) GENOMES="$(readlink -m "$OPTARG")" ;;
     r) REPORTING="$(readlink -m "$OPTARG")" ;;
     l) TMP="$(readlink -m "$OPTARG")" ;; # Wrapper stuurt TMP via -l
     n) LOGDIR="$(readlink -m "$OPTARG")" ;; # Wrapper stuurt LOGS via -n
     p) SAMPLES_FILE="$OPTARG" ;;
     # Overige vlaggen negeren
     a|b|c|d|e|f|g|h|i|j|k|q) : ;;
  esac
done

## Setup mappen
mkdir -p "$SEND_OUT" "$LOGDIR" "$REPORTING"
GenRep="$REPORTING/general-report.txt"
SketchSummary="$REPORTING/sendsketch_top_hits.log"

# Maak de samenvatting leeg voor de start
> "$SketchSummary"

count0=1
countS=$(cat "$SAMPLES_FILE" | wc -l)

log "Start BBMap SendSketch (Taxonomy) op $countS samples."

# --- 2. DE LOOP ---
while [ "$count0" -le "$countS" ]; do

    SAMPLE=$(cat "$SAMPLES_FILE" | awk 'NR=='$count0)
    log "---------------------------------------------------"
    log "BEZIG MET: $SAMPLE ($count0/$countS)"

    # Input: Gebruik .fa extensie (Shovill output)
    sketchIn="$GENOMES/${SAMPLE}.fa"
    LOG1="$LOGDIR/${SAMPLE}.sendsketch.log"
    OUT_TAB="$SEND_OUT/${SAMPLE}.sendsketch.tab"
    OUT_SKETCH="$SEND_OUT/${SAMPLE}.outsketch.tab"

    if [ ! -f "$sketchIn" ]; then
        log "SKIP: $SAMPLE - Geen FASTA gevonden in $GENOMES"
        count0=$((count0+1))
        continue
    fi

    # Run SendSketch (zoekt online in de BBMap database)
    # ow = overwrite
    sendsketch.sh in="$sketchIn" \
                  out="$OUT_TAB" \
                  outsketch="$OUT_SKETCH" \
                  ow > "$LOG1" 2>&1;

    # Extra: Pak de Top Hit (eerste regel na de header) voor in de samenvatting
    if [ -s "$OUT_TAB" ]; then
        # SendSketch output heeft vaak een header die begint met WKID of #
        TOP_HIT=$(grep -v "#" "$OUT_TAB" | head -n 1 | cut -f11) # Kolom 11 is vaak de taxonomy/name
        echo -e "$SAMPLE\t$TOP_HIT" >> "$SketchSummary"
    fi

    sync # NFS stabiliteit
    count0=$((count0+1))

done

# --- 3. AFSLUITING ---
log "SendSketch analyse voltooid. Top hits staan in $SketchSummary"

echo -e "\nTaxonomy (SendSketch)\nAlle genomes zijn vergeleken met de online BBMap database voor taxonomische indicatie.\n" >> "$GenRep"

# Sanitizer
tr -d '\15\302\240' < "$0" > "$0.tmp" && mv "$0.tmp" "$0"
chmod +x "$0"

exit 0