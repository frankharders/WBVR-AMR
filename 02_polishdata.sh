#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-bbmap;

# Standaardwaarden
ADAPTERPATH="/home/wbvr006/miniconda3/envs/amr-bbmap/opt/bbmap-39.06-1/resources";
ADAPTER="nextera";
TRIMQ=20;
TARGET=100;
TIPS=25;
KTRIM='r';
QTRIM='rl';

# Getopts
while getopts "w:a:b:c:d:e:f:g:h:i:j:k:l:n:r:q:p:" opt; do
  case $opt in
    w) WORKDIR="$(readlink -m $OPTARG)" ;;
    a) RAW_FASTQ="$(readlink -m $OPTARG)" ;;
    c) POLISHED="$(readlink -m $OPTARG)" ;;
    l) TMP="$(readlink -m $OPTARG)" ;;
    n) LOG="$(readlink -m $OPTARG)" ;;
    r) REPORTING="$(readlink -m $OPTARG)" ;;
    q) ARCHIVE="$(readlink -m $OPTARG)" ;;
    p) FILE="$OPTARG" ;;
  esac
done

# Defaults als wrapper ze niet stuurt
[ -z "$POLISHED" ] && POLISHED="$PWD/02_polished"
[ -z "$LOG" ] && LOG="$PWD/LOGS"
[ -z "$TMP" ] && TMP="$PWD/TEMP"
[ -z "$REPORTING" ] && REPORTING="$PWD/REPORTING"
[ -z "$FILE" ] && FILE="samples.txt"

mkdir -p "$POLISHED" "$LOG" "$TMP" "$REPORTING"

GenRep="$REPORTING/general-report.txt"

echo "Start polishing met BBMap..."

while read -r SAMPLE || [[ -n "$SAMPLE" ]]; do
    [ -z "${SAMPLE// }" ] && continue

    echo "---------------------------------------------------"
    echo "Verwerken van: $SAMPLE"
    
    OUTdir="$POLISHED/$SAMPLE"
    mkdir -p "$OUTdir"
    
    LOG0="$LOG/$SAMPLE.bbmap.log"
    
    # Input
    R1="$RAW_FASTQ/${SAMPLE}_R1.fastq.gz"
    R2="$RAW_FASTQ/${SAMPLE}_R2.fastq.gz"

    if [ ! -f "$R1" ]; then
        echo "SKIP: $SAMPLE - Input $R1 niet gevonden!"
        continue
    fi

    # Definieer stappen (we hergebruiken variabelen voor robuustheid)
    CUR1="$R1"; CUR2="$R2"
    REF="$ADAPTERPATH/$ADAPTER.fa.gz"

    # 1. Filter bad focused clusters (FilterByTile)
    echo "  > Filtering tiles..."
    filterbytile.sh in1="$CUR1" in2="$CUR2" out1="$TMP/${SAMPLE}.tile.1.fq.gz" out2="$TMP/${SAMPLE}.tile.2.fq.gz" ow > "$LOG0" 2>&1
    [ -s "$TMP/${SAMPLE}.tile.1.fq.gz" ] && CUR1="$TMP/${SAMPLE}.tile.1.fq.gz" && CUR2="$TMP/${SAMPLE}.tile.2.fq.gz"

    # 2. Error Correction (Tadpole)
    echo "  > Error correction..."
    tadpole.sh in1="$CUR1" in2="$CUR2" out1="$TMP/${SAMPLE}.tad.1.fq.gz" out2="$TMP/${SAMPLE}.tad.2.fq.gz" mode=correct ow >> "$LOG0" 2>&1
    [ -s "$TMP/${SAMPLE}.tad.1.fq.gz" ] && CUR1="$TMP/${SAMPLE}.tad.1.fq.gz" && CUR2="$TMP/${SAMPLE}.tad.2.fq.gz"

    # 3. Adapter Trimming (BBDuk)
    echo "  > Adapter trimming..."
    bbduk.sh -Xmx12g in1="$CUR1" in2="$CUR2" out1="$TMP/${SAMPLE}.trim.1.fq.gz" out2="$TMP/${SAMPLE}.trim.2.fq.gz" \
    ktrimtips="$TIPS" ktrim="$KTRIM" ref="$REF" k=23 mink=11 hdist=1 tpe tbo ow >> "$LOG0" 2>&1
    [ -s "$TMP/${SAMPLE}.trim.1.fq.gz" ] && CUR1="$TMP/${SAMPLE}.trim.1.fq.gz" && CUR2="$TMP/${SAMPLE}.trim.2.fq.gz"

    # 4. Quality Trimming (BBDuk)
    echo "  > Quality trimming..."
    bbduk.sh -Xmx12g in1="$CUR1" in2="$CUR2" out1="$TMP/${SAMPLE}.qual.1.fq.gz" out2="$TMP/${SAMPLE}.qual.2.fq.gz" \
    qtrim="$QTRIM" trimq="$TRIMQ" minlen=50 ow >> "$LOG0" 2>&1
    [ -s "$TMP/${SAMPLE}.qual.1.fq.gz" ] && CUR1="$TMP/${SAMPLE}.qual.1.fq.gz" && CUR2="$TMP/${SAMPLE}.qual.2.fq.gz"

    # 5. Normalisatie (BNorm) naar Target 100x
    echo "  > Normalisatie..."
    OUTPUT1="$OUTdir/${SAMPLE}_R1.QTR.adapter.correct.fq.gz"
    OUTPUT2="$OUTdir/${SAMPLE}_R2.QTR.adapter.correct.fq.gz"
    
    bbnorm.sh -Xmx12g in1="$CUR1" in2="$CUR2" out1="$OUTPUT1" out2="$OUTPUT2" \
    target="$TARGET" min=5 ow >> "$LOG0" 2>&1

    # 6. Insert size berekening (BBMerge)
    bbmerge.sh in1="$OUTPUT1" in2="$OUTPUT2" ihist="$OUTdir/$SAMPLE.ihist.txt" ow >> "$LOG0" 2>&1

    # Belangrijk: sync voor NFS
    sync
    
    # Ruim op
    rm -f "$TMP/${SAMPLE}"*.fq.gz
    echo "  > $SAMPLE voltooid."

done < "$FILE"

# Rapportage
polishCnt=$(find "$POLISHED" -name "*.ihist.txt" | wc -l)
echo -e "\nbbmap polishing\n$polishCnt samples succesvol gepolished\n" >> "$GenRep"

echo "Read polishing voltooid."
exit 0