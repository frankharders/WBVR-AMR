#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-QC;                       

# Functie voor logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE ---
SAMPLES_FILE="samples.txt"
WORKDIR="$PWD"
POLISHED="$PWD/02_polished"
TRIMMEDSTATS="$PWD/03_trimmedstats"
REPORTING="$PWD/REPORTING"
ARCHIVE=""

if [ ! -f "$SAMPLES_FILE" ]; then
    echo "Error: $SAMPLES_FILE niet gevonden!"
    exit 1
fi

cnt=$(cat "$SAMPLES_FILE" | wc -l);

# --- 2. ARGUMENTEN PARSEN (Uitgebreid voor wrapper-compatibiliteit) ---
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:r:q:p:" opt; do
  case $opt in
     w) WORKDIR="$(readlink -m "$OPTARG")" ;;
     c) POLISHED="$(readlink -m "$OPTARG")" ;;
     d) TRIMMEDSTATS="$(readlink -m "$OPTARG")" ;;
     r) REPORTING="$(readlink -m "$OPTARG")" ;;
     q) ARCHIVE="$(readlink -m "$OPTARG")" ;;
     p) SAMPLES_FILE="$OPTARG" ;;
     # Overige vlaggen opvangen maar negeren om fouten te voorkomen
     a|b|e|f|g|h|i|j|k|l|n) : ;; 
     \?) echo "Ongeldige optie: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Check op minimale vereisten
if [ -z "$WORKDIR" ] || [ -z "$POLISHED" ] || [ -z "$TRIMMEDSTATS" ] || [ -z "$REPORTING" ]; then
    echo "Fout: -w, -c, -d en -r zijn verplicht."
    exit 1
fi

## reporting
GenRep="$REPORTING/general-report.txt";
mkdir -p "$TRIMMEDSTATS"

log "Start FastQC op polished reads. Totaal aantal samples: $cnt"

# --- 3. DE LOOP ---
while read -r SAMPLE || [[ -n "$SAMPLE" ]]; do 
    [[ -z "${SAMPLE// }" ]] && continue

    log "---------------------------------------------------"
    log "BEZIG MET: $SAMPLE"

    R1="$POLISHED/$SAMPLE/${SAMPLE}_R1.QTR.adapter.correct.fq.gz"
    R2="$POLISHED/$SAMPLE/${SAMPLE}_R2.QTR.adapter.correct.fq.gz"
    OUTdir="$TRIMMEDSTATS/$SAMPLE"

    if [[ ! -f "$R1" ]]; then
        log "SKIP: $SAMPLE - R1 niet gevonden in $POLISHED"
        ((cnt--))
        continue
    fi

    mkdir -p "$OUTdir"

    log "FastQC analyse op: $SAMPLE"
    # -t 8 voor snelheid, </dev/null om loop-stalls te voorkomen
    fastqc -t 8 -o "$OUTdir" "$R1" "$R2" </dev/null

    ((cnt--))
    log "$cnt samples te gaan!"

done < "$SAMPLES_FILE"

# --- 4. AFSLUITING EN ARCHIVERING ---

fastQCcnt=$(ls "$TRIMMEDSTATS"/*/*R1*.zip 2>/dev/null | wc -l)

echo -e "\nfastQC\nVan $fastQCcnt samples is een FastQC rapport gegenereerd op basis van polished reads.\n" >> "$GenRep"

log "FastQC plots zijn gegenereerd in $TRIMMEDSTATS"

# Gebruik rsync in plaats van cp om stalls op de archiefschijf te voorkomen
if [ -n "$ARCHIVE" ]; then
    log "Archiveren naar $ARCHIVE..."
    mkdir -p "$ARCHIVE"
    rsync -av --quiet "$TRIMMEDSTATS" "$ARCHIVE/" && sync
    log "Archivering voltooid."
fi

exit 0