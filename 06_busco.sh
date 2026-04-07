#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-busco;

# Functie voor logging naar terminal
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE & GETOPTS ---
FILE="samples.txt";
WORKDIR="$PWD";
GENOMES="$PWD/genomes";
BUSCO_OUT="$PWD/06_busco";
LOGDIR="$PWD/LOGS";
REPORTING="$PWD/REPORTING";

# Opvangen van vlaggen vanuit de wrapper
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:m:r:q:p:" opt; do
  case $opt in
     w) WORKDIR="$(readlink -m "$OPTARG")" ;;
     m) GENOMES="$(readlink -m "$OPTARG")" ;; # De genomes folder met .fa files
     r) REPORTING="$(readlink -m "$OPTARG")" ;;
     p) FILE="$OPTARG" ;;
     # Overige vlaggen negeren
     a|b|c|d|e|f|g|h|i|j|k|l|n|q) : ;;
  esac
done

## reporting
GenRep="$REPORTING/general-report.txt";
mkdir -p "$BUSCO_OUT" "$LOGDIR";

MODE="geno";
NODES=24;

count0=1;
countS=$(cat "$FILE" | wc -l);

log "Start BUSCO analyse op geassembleerde genomen. Totaal: $countS samples."

# --- 2. DE LOOP ---
while [ "$count0" -le "$countS" ]; do 

    SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0");
    log "---------------------------------------------------"
    log "BEZIG MET: $SAMPLE ($count0/$countS)"

    # Pad naar de input FASTA (let op de extensie uit stap 04/05)
    BUSCOin="$GENOMES/${SAMPLE}_contigs.fa";
    
    # Als de bovenstaande naam niet matcht met je schijf, probeer deze fallback:
    if [ ! -f "$BUSCOin" ]; then
        BUSCOin="$GENOMES/${SAMPLE}.fa";
    fi

    if [ ! -f "$BUSCOin" ]; then
        log "SKIP: $SAMPLE - Geen FASTA gevonden in $GENOMES"
        count0=$((count0+1))
        continue
    fi

    BUSCOlog="$LOGDIR/${SAMPLE}.busco.log";
    
    # BUSCO maakt zelf de output folder aan met de naam die je geeft bij --out
    # Om vervuiling te voorkomen draaien we BUSCO binnen de 06_busco hoofdmap
    cd "$BUSCO_OUT" || exit

    log "Draaien BUSCO voor $SAMPLE..."
    busco --in "$BUSCOin" \
          --out "$SAMPLE" \
          --mode "$MODE" \
          --auto-lineage-prok \
          --cpu "$NODES" \
          --scaffold_composition \
          --force > "$BUSCOlog" 2>&1;

    sync # Voorkom NFS stalls na de intensieve BUSCO run
    
    cd "$WORKDIR" || exit
    
    count0=$((count0+1));
    log "Sample $SAMPLE klaar. Volgende..."
done

# --- 3. AFSLUITING ---
rm -rf busco_downloads;

log "BUSCO analyse voltooid."
echo -e "\nBUSCO\nDe kwaliteit van de genomen is gecontroleerd met BUSCO (prokaryote tree).\n" >> "$GenRep";

# Sanitizer
tr -d '\15\302\240' < "$0" > "$0.tmp" && mv "$0.tmp" "$0"
chmod +x "$0"

exit 0