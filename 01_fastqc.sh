#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-QC;

# Totaal aantal samples bepalen voor de teller
if [ -f samples.txt ]; then
    cnt=$(cat samples.txt | wc -l);
else
    echo "Error: samples.txt niet gevonden!"
    exit 1
fi

# Uitgebreide getopts om alle doorgegeven vlaggen op te vangen
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:r:q:" opt; do
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
    k) ABRICATEparse="$(readlink -m $OPTARG)" ;;
    l) TMP="$(readlink -m $OPTARG)" ;;
    n) LOG="$(readlink -m $OPTARG)" ;;
    r) REPORTING="$(readlink -m $OPTARG)" ;;
    q) ARCHIVE="$(readlink -m $OPTARG)" ;;
    \?) echo "Ongeldige optie: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Check verplichte parameters
if [ -z "$WORKDIR" ] || [ -z "$RAW_FASTQ" ] || [ -z "$RAWSTATS" ] || [ -z "$REPORTING" ]; then
    echo "Fout: Verplichte opties (-w, -a, -b, -r) ontbreken."
    exit 1
fi

ToDay=$(date +%Y-%m-%d);
GenRep="$REPORTING/general-report.txt";

# Initialiseer General Report als het nog niet bestaat
echo "FastQC start op: $ToDay" >> "$GenRep";

echo "Start FastQC analyse op de raw sequence files..."

while read -r SAMPLE; do
    # Sla lege regels over
    [ -z "$SAMPLE" ] && continue

    OUTdir="$RAWSTATS/$SAMPLE"
    mkdir -p "$OUTdir"

    # Definieer de paden naar de fastq bestanden
    R1="$RAW_FASTQ/${SAMPLE}_R1.fastq.gz"
    R2="$RAW_FASTQ/${SAMPLE}_R2.fastq.gz"

    # Controleer of de bestanden daadwerkelijk bestaan voor we FastQC starten
    if [ -f "$R1" ] && [ -f "$R2" ]; then
        echo "Processing sample: $SAMPLE"
        fastqc -t 8 -o "$OUTdir" "$R1" "$R2"
    else
        echo "Waarschuwing: Bestanden voor $SAMPLE niet gevonden in $RAW_FASTQ"
    fi

    ((cnt--))
    echo -e "$cnt samples te gaan!"
done < samples.txt

# Tel hoeveel reports er daadwerkelijk zijn gemaakt
fastQCcnt=$(find "$RAWSTATS" -name "*_fastqc.zip" | wc -l);
# Delen door 2 omdat elke sample R1 en R2 heeft
sampleDone=$((fastQCcnt / 2))

echo -e "\n--- FastQC Rapportage ---" >> "$GenRep"
echo "Datum: $ToDay" >> "$GenRep"
echo "FastQC succesvol uitgevoerd voor $sampleDone samples (totaal $fastQCcnt zip bestanden)." >> "$GenRep"

echo "FastQC plots zijn gegenereerd in: $RAWSTATS"

# Archiveer de resultaten als ARCHIVE is opgegeven
if [ -n "$ARCHIVE" ]; then
    echo "Kopiëren naar archief: $ARCHIVE"
    mkdir -p "$ARCHIVE"
    cp -r "$RAWSTATS" "$ARCHIVE/"
fi

exit 0