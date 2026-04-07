#!/usr/bin/env bash
set -euo pipefail

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- 1. INITIALISATIE ---
SAMPLES_FILE="samples.txt"
DEPTH=100
MINCOV=0
WORKDIR="$PWD"
POLISHED="$PWD/02_polished"
SHOVILL="$PWD/04_shovill"
ASSEMBLER="spades"
CONTIGLENGTH="300"
GENOMES2="$PWD/genomes"
REPORTING=""
ARCHIVE=""

# --- 2. ARGUMENTEN PARSEN ---
while getopts "w:c:e:m:r:y:z:p:d:v:q:h" opt; do
    case "$opt" in
        w) WORKDIR="$(readlink -m "$OPTARG")" ;;
        c) POLISHED="$(readlink -m "$OPTARG")" ;;
        e) SHOVILL="$(readlink -m "$OPTARG")" ;;
        y) ASSEMBLER="$OPTARG" ;;
        z) CONTIGLENGTH="$OPTARG" ;;
        p) SAMPLES_FILE="$OPTARG" ;;
        d) DEPTH="$OPTARG" ;;
        v) MINCOV="$OPTARG" ;;
        m) GENOMES2="$(readlink -m "$OPTARG")" ;; 
        r) REPORTING="$OPTARG" ;;
        q) ARCHIVE="$OPTARG" ;;
        h) exit 0 ;;
        *) exit 1 ;;
    esac
done

# --- 3. CONDA ACTIVATIE ---
if [ -f "/home/wbvr006/miniconda3/etc/profile.d/conda.sh" ]; then
    source "/home/wbvr006/miniconda3/etc/profile.d/conda.sh"
    conda activate amr-assembly
fi

mkdir -p "$SHOVILL" "$GENOMES2"

log "Start Shovill loop. Output formaat: \${SAMPLE}.fa"

# --- 4. DE LOOP ---
while IFS= read -r SAMPLE <&3 || [[ -n "$SAMPLE" ]]; do
    [[ -z "${SAMPLE// }" ]] && continue
    
    log "---------------------------------------------------"
    log "BEZIG MET: $SAMPLE"

    OUTPUTDIR="$SHOVILL/$SAMPLE"
    R1="$POLISHED/$SAMPLE/${SAMPLE}_R1.QTR.adapter.correct.fq.gz"
    R2="$POLISHED/$SAMPLE/${SAMPLE}_R2.QTR.adapter.correct.fq.gz"

    # --- Check of bestanden bestaan EN niet leeg zijn ---
    if [[ ! -f "$R1" ]]; then
        log "SKIP: $SAMPLE - R1 niet gevonden"
        continue
    fi

    FILE_SIZE=$(stat -c%s "$R1")
    if [ "$FILE_SIZE" -lt 100 ]; then
        log "SKIP: $SAMPLE - R1 is leeg ($FILE_SIZE bytes). Check je trimming stap!"
        continue
    fi

    # Run Shovill
    if ! shovill --outdir "$OUTPUTDIR" --depth "$DEPTH" --minlen "$CONTIGLENGTH" \
                --mincov "$MINCOV" --keepfiles --assembler "$ASSEMBLER" \
                --namefmt "${SAMPLE}_contig%05d" --force --R1 "$R1" --R2 "$R2" </dev/null; then
        log "ERROR: Shovill gefaald voor $SAMPLE"
        continue
    fi

    sync
    sleep 2

    FASTAIN="$OUTPUTDIR/contigs.fa"
    # Aangepast naar simpele .fa extensie zonder _contigs
    FASTAOUT_LOCAL="$OUTPUTDIR/${SAMPLE}.fa"
    FASTAOUT_FINAL="$GENOMES2/${SAMPLE}.fa"

    if [[ -s "$FASTAIN" ]]; then
        log "Stap 1: Formatteren lokaal naar ${SAMPLE}.fa..."
        cat "$FASTAIN" | perl -ne 'if(/^>/){print "\n" if $i; print $_; $i=1}else{s/\s+//g; print $_} END{print "\n"}' > "$FASTAOUT_LOCAL"
        
        log "Stap 2: Publiceren naar genomes folder via rsync..."
        rsync -a "$FASTAOUT_LOCAL" "$FASTAOUT_FINAL"
        
        sync
        sleep 1
    fi

done 3< "$SAMPLES_FILE"

log "Loop succesvol afgerond. Alle genomes staan in $GENOMES2"