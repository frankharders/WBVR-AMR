#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate pip3;

# create several directories
# Toegevoegd: m: voor GENOMES en r: voor REPORTING in de getopts string
while getopts "w:a:b:c:d:e:f:g:h:i:j:l:m:n:r:s:t:q:" opt; do
  case $opt in
    w) WORKDIR="$(readlink -m $OPTARG)" ;;
    a) RAW_FASTQ="$(readlink -m $OPTARG)" ;;
    b) RAWSTATS="$(readlink -m $OPTARG)" ;;
    c) POLISHED="$(readlink -m $OPTARG)" ;;
    d) TRIMMEDSTATS="$(readlink -m $OPTARG)" ;;
    e) SHOVILL="$(readlink -m $OPTARG)" ;;
    f) QUAST="$(readlink -m $OPTARG)" ;;
    g) QUASTparse="$(readlink -m $OPTARG)" ;;
    h) MLST="$(readlink -m $OPTARG)" ;;
    i) MLSTparse="$(readlink -m $OPTARG)" ;;
    j) ABRICATE="$(readlink -m $OPTARG)" ;;
    l) TMP="$(readlink -m $OPTARG)" ;;
    m) GENOMES="$(readlink -m $OPTARG)" ;;
    n) LOG="$(readlink -m $OPTARG)" ;;
    r) REPORTING="$(readlink -m $OPTARG)" ;;
    s) STARAMR="$(readlink -m $OPTARG)" ;;
    t) RGI="$(readlink -m $OPTARG)" ;;
    q) ARCHIVE="$(readlink -m $OPTARG)" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Validatie: Controleer of de belangrijkste variabelen gevuld zijn
if [ -z "$WORKDIR" ] || [ -z "$RAW_FASTQ" ] || [ -z "$RAWSTATS" ]; then
    echo "Usage: $0 -w WORKDIR -a RAW_FASTQ -b RAWSTATS -c POLISHED -d TRIMMEDSTATS [and other options]"
    exit 1
fi

# 1. Ga naar de RAWREADS map voor hernoeming en sample-lijst generatie
if [ -d "RAWREADS" ]; then
    cd RAWREADS || exit 1
    
    # Hernoem MiSeq bestanden naar een simpeler formaat
    # Verwijdert _S123_ en _001
    rename 's/_S[0-9]+_/_/g' *.gz 2>/dev/null
    rename 's/_001\././g' *.gz 2>/dev/null

    # Maak de samples.txt aan (pakt alles voor de eerste underscore)
    ls *R1* 2>/dev/null | cut -f1 -d'_' > ../samples.txt
    
    cd ..
else
    echo "Error: RAWREADS directory niet gevonden!"
    exit 1
fi

# 2. Mappen aanmaken
# We gebruiken de variabelen die via getopts zijn binnengekomen
echo "Creating directory structure..."

mkdir -p "$RAWSTATS" "$POLISHED" "$TRIMMEDSTATS" "$SHOVILL" "$QUAST" "$QUASTparse" "$TMP" "$LOG" "$REPORTING" "$GENOMES" "$MLST";

# Optionele extra mappen als de variabelen gezet zijn
[ -n "$ABRICATE" ] && mkdir -p "$ABRICATE"
[ -n "$STARAMR" ] && mkdir -p "$STARAMR"
[ -n "$RGI" ] && mkdir -p "$RGI"

echo "Structure generation complete."
exit 0