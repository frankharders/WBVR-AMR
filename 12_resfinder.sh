#!/bin/bash

## change (2022-05-27): error in using $species variable - script altered
## change (2023-10-19): species found via kmerfinder, output used for resfinder species lookup
## change (2024-04-20): added error handling on git clones, consistent cd-back to $WORKDIR,
##                      added -db_res flag to resfinder calls
## change (2026-04-20): clone databases into /tmp (local disk) to avoid NFS lock issues,
##                      use rsync instead of mv to copy files into place file-by-file,
##                      bypassing NFS directory-level locks entirely

set -euo pipefail   # exit on error, unset variable, or pipe failure

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)"
conda activate pip3

WORKDIR="$PWD"

# ---------------------------------------------------------------------------
# Python virtual environment + install
# ---------------------------------------------------------------------------
python3 -m venv resfinder_env
source resfinder_env/bin/activate
pip install resfinder

# ---------------------------------------------------------------------------
# Helper: clone + install a CGE database only if not already intact.
# Clones into /tmp (local disk, no NFS), then rsyncs file-by-file into
# the NFS target - avoids directory-level NFS lock conflicts entirely.
# Usage: setup_db <db_name> <bitbucket_url> <check_file>
# ---------------------------------------------------------------------------
setup_db() {
    local db_name="$1"
    local db_url="$2"
    local check_file="$3"
    local db_path="$WORKDIR/databases/$db_name"
    local tmp_path="/tmp/${db_name}_$$"   # $$ = PID, unique per run

    mkdir -p "$WORKDIR/databases"

    if [ -f "$db_path/$check_file" ]; then
        echo "==> $db_name already intact (found $check_file), skipping clone"
        return 0
    fi

    echo "==> Setting up $db_name (cloning to /tmp first)..."

    # Clone onto local /tmp - no NFS involved
    rm -rf "$tmp_path"
    git clone "$db_url" "$tmp_path" \
        || { echo "ERROR: git clone of $db_name failed"; exit 1; }

    cd "$tmp_path"
    python3 INSTALL.py \
        || { echo "ERROR: INSTALL.py failed for $db_name"; exit 1; }
    cd "$WORKDIR"

    if [ ! -f "$tmp_path/$check_file" ]; then
        echo "ERROR: $check_file not found in $tmp_path after install"
        exit 1
    fi

    # rsync file-by-file into NFS target - no directory replacement needed,
    # so NFS locks on .git objects are not a problem
    echo "==> rsyncing $db_name into place..."
    mkdir -p "$db_path"
    rsync -a --delete "$tmp_path/" "$db_path/" \
        || { echo "ERROR: rsync failed for $db_name"; exit 1; }

    # Clean up /tmp
    rm -rf "$tmp_path"

    if [ ! -f "$db_path/$check_file" ]; then
        echo "ERROR: $check_file not found in $db_path after rsync"
        exit 1
    fi

    echo "==> $db_name installed successfully"
}

# ---------------------------------------------------------------------------
# Clone and install databases
# ---------------------------------------------------------------------------
setup_db "resfinder_db"   "https://bitbucket.org/genomicepidemiology/resfinder_db/"   "config"
setup_db "pointfinder_db" "https://bitbucket.org/genomicepidemiology/pointfinder_db/" "config"
setup_db "disinfinder_db" "https://bitbucket.org/genomicepidemiology/disinfinder_db/" "config"

# ---------------------------------------------------------------------------
# KMA index all pointfinder species
# ---------------------------------------------------------------------------
grep -v '#' "$WORKDIR/databases/pointfinder_db/config" \
    | cut -f1 -d$'\t' \
    > "$WORKDIR/databases/pointfinder_db/dir.lst"

countP=1
countD=$(wc -l < "$WORKDIR/databases/pointfinder_db/dir.lst")

while [ "$countP" -le "$countD" ]; do
    species=$(awk "NR==$countP" "$WORKDIR/databases/pointfinder_db/dir.lst")
    echo "==> Indexing pointfinder species: $species"

    mkdir -p "$WORKDIR/databases/pointfinder_db/$species"

    kma_index \
        -i "$WORKDIR/databases/pointfinder_db/$species"/*.fsa \
        -o "$WORKDIR/databases/pointfinder_db/$species/$species" \
        || echo "WARNING: kma_index failed for species: $species (continuing)"

    countP=$((countP + 1))
done

cd "$WORKDIR"

# ---------------------------------------------------------------------------
# Export DB paths
# ---------------------------------------------------------------------------
export CGE_RESFINDER_RESGENE_DB="$WORKDIR/databases/resfinder_db"
export CGE_RESFINDER_RESPOINT_DB="$WORKDIR/databases/pointfinder_db"
export CGE_DISINFINDER_DB="$WORKDIR/databases/disinfinder_db"

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
FILE="$WORKDIR/samples.txt"
GENOME="$WORKDIR/genomes"
POLISHED="$WORKDIR/02_polished"

KMAres="$WORKDIR/databases/resfinder_db"
KMApoint="$WORKDIR/databases/pointfinder_db"
KMAdis="$WORKDIR/databases/disinfinder_db"

mkdir -p "$WORKDIR/12_resfinder"
mkdir -p "$WORKDIR/REPORTING"

# Log resfinder version once
python -m resfinder -v > "$WORKDIR/REPORTING/resfinder.version.log" 2>&1

# ---------------------------------------------------------------------------
# Per-sample loop
# ---------------------------------------------------------------------------
count0=1
countL=$(wc -l < "$FILE")

while [ "$count0" -le "$countL" ]; do

    SAMPLE=$(awk "NR==$count0" "$FILE")

    echo -e "\n\n======================================================"
    echo "==> Processing sample: $SAMPLE"
    echo "======================================================"

    speciesTemp=$(grep "$SAMPLE" "$WORKDIR/REPORTING/SamplesSpecies.log" \
                  | cut -f2 -d$'\t' || true)

    echo "==> speciesTemp=$speciesTemp"

    if [ -z "$speciesTemp" ]; then
        echo "WARNING: no species found for $SAMPLE in SamplesSpecies.log, skipping"
        count0=$((count0 + 1))
        continue
    fi

    # Recreate output directories cleanly
    rm -rf "12_resfinder/$SAMPLE"
    mkdir -p "12_resfinder/$SAMPLE/contigs"
    mkdir -p "12_resfinder/$SAMPLE/reads"

    READSin1="$POLISHED/$SAMPLE/${SAMPLE}_R1.QTR.adapter.correct.fq.gz"
    READSin2="$POLISHED/$SAMPLE/${SAMPLE}_R2.QTR.adapter.correct.fq.gz"
    CONTIGSin="$GENOME/$SAMPLE.fa"

    OUTdirContigs="12_resfinder/$SAMPLE/contigs"
    OUTdirReads="12_resfinder/$SAMPLE/reads"

    # --- Run on reads ---
    if [ -f "$READSin1" ] && [ -f "$READSin2" ]; then
        echo "==> Running resfinder on reads..."
        python -m resfinder \
            -o "$OUTdirReads" \
            -l 0.6 -t 0.8 \
            -ifq "$READSin1" "$READSin2" \
            -db_res "$KMAres" \
            -db_res_kma "$KMAres" \
            -acq \
            --disinfectant -db_disinf_kma "$KMAdis" \
            --point --species "$speciesTemp" \
            --ignore_missing_species \
            -db_point_kma "$KMApoint/$speciesTemp/" \
            -u
    else
        echo "WARNING: reads not found for $SAMPLE, skipping reads analysis"
    fi

    # --- Run on contigs ---
    if [ -f "$CONTIGSin" ]; then
        echo "==> Running resfinder on contigs..."
        python -m resfinder \
            -o "$OUTdirContigs" \
            -l 0.6 -t 0.8 \
            -ifa "$CONTIGSin" \
            -db_res "$KMAres" \
            -db_res_kma "$KMAres" \
            -acq \
            --disinfectant -db_disinf_kma "$KMAdis" \
            --point --species "$speciesTemp" \
            --ignore_missing_species \
            -db_point_kma "$KMApoint/$speciesTemp/" \
            -u
    else
        echo "WARNING: contigs file not found for $SAMPLE, skipping contigs analysis"
    fi

    count0=$((count0 + 1))

done

echo -e "\n==> All samples done."