#!/bin/bash

## activate the environment for this downstream analysis
eval "$(conda shell.bash hook)"
conda activate amr-QC

while getopts "w:c:e:f:r:m:" opt; do
  case $opt in
     w)
      WORKDIR="$(readlink -m $OPTARG)"
      echo "-w WORKDIR=$WORKDIR"
      ;;
     c)
      POLISHED="$(readlink -m $OPTARG)"
      echo "-c POLISHED=$POLISHED"
      ;;
     e)
      SHOVILL="$(readlink -m $OPTARG)"
      echo "-e SHOVILL=$SHOVILL"
      ;;
     f)
      QUAST="$(readlink -m $OPTARG)"
      echo "-f QUAST=$QUAST"
      ;;
     r)
      REPORTING="$(readlink -m $OPTARG)"
      echo "-r REPORTING=$REPORTING"
      ;;
     m)
      GENOMES="$(readlink -m $OPTARG)"
      echo "-m GENOMES=$GENOMES"
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      ;;
  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$POLISHED" ] || [ "x" == "x$SHOVILL" ] || [ "x" == "x$QUAST" ] || [ "x" == "x$REPORTING" ]; then
    echo "ERROR: -w, -c, -e, -f, -r are required"
    echo "Usage: $0 -w WORKDIR -c POLISHED -e SHOVILL -f QUAST -r REPORTING [-m GENOMES]"
    exit 1
fi

## reporting
GenRep="$REPORTING/general-report.txt"
today=$(date +%Y%m%d)
METRICS="$REPORTING/${today}-assemblymetrics.tab"

FASTAarchive=/mnt/lely_archive/wbvr006/2021/assembled-genomes-2021/

THREADS=24

echo -e "#sample\tContigs>500bp\tLargestContig\tTotalLength\tN50" > "$METRICS"

cnt=$(wc -l < samples.txt)

while read -r SAMPLE; do

    echo -e "\n==> Processing sample: $SAMPLE ($cnt remaining)"

    R1="$POLISHED/$SAMPLE/${SAMPLE}_R1.QTR.adapter.correct.fq.gz"
    R2="$POLISHED/$SAMPLE/${SAMPLE}_R2.QTR.adapter.correct.fq.gz"
    FASTAout="$SHOVILL/$SAMPLE/$SAMPLE.fa"

    # Run quast into /tmp (local disk) to avoid NFS stalling
    TMP_QUAST="/tmp/quast_${SAMPLE}_$$"
    rm -rf "$TMP_QUAST"

    echo "==> Running quast for $SAMPLE (output to /tmp first)..."
    quast "$FASTAout" -1 "$R1" -2 "$R2" \
        --threads "$THREADS" \
        -o "$TMP_QUAST" \
        --strict-NA \
        || { echo "ERROR: quast failed for $SAMPLE"; let cnt--; continue; }

    # rsync results from /tmp to NFS target - file-by-file, no directory lock issues
    echo "==> rsyncing quast results for $SAMPLE to NFS..."
    mkdir -p "$QUAST/$SAMPLE"
    rsync -a "$TMP_QUAST/" "$QUAST/$SAMPLE/" \
        || { echo "ERROR: rsync failed for $SAMPLE"; let cnt--; continue; }

    # Clean up /tmp
    rm -rf "$TMP_QUAST"

    # Copy named report files
    cat "$QUAST/$SAMPLE/report.pdf" > "$QUAST/$SAMPLE/$SAMPLE.report.pdf"
    cat "$QUAST/$SAMPLE/report.tsv" > "$QUAST/$SAMPLE/$SAMPLE.report.tsv"

    REPORT="$QUAST/$SAMPLE/$SAMPLE.report.tsv"

    # Parse metrics
    No=$(grep -P "# contigs\t"  "$REPORT" | cut -f2 -d$'\t')
    LC=$(grep 'Largest contig'  "$REPORT" | cut -f2 -d$'\t')
    TL=$(grep -P "Total length\t" "$REPORT" | cut -f2 -d$'\t')
    N50=$(grep 'N50'            "$REPORT" | cut -f2 -d$'\t')

    echo -e "  Contigs=$No  LargestContig=$LC  TotalLength=$TL  N50=$N50"

    # Copy genome to destinations
    if [ -n "$GENOMES" ]; then
        rsync -a "$FASTAout" "$GENOMES/" \
            || echo "WARNING: rsync to GENOMES failed for $SAMPLE"
    fi

    rsync -a "$FASTAout" "$FASTAarchive/" \
        || echo "WARNING: rsync to FASTAarchive failed for $SAMPLE"

    echo -e "$SAMPLE\t$No\t$LC\t$TL\t$N50" >> "$METRICS"

    let cnt--
    echo "==> $cnt samples to go"

done < samples.txt

echo -e "\n==> Quast analysis done for all samples"
echo -e "Output: $QUAST"

quastCnt=$(ls "$QUAST"/*/report.pdf 2>/dev/null | wc -l)
echo -e "\nQUAST\nfrom $quastCnt samples a quast & icarus report is constructed\n" >> "$GenRep"

echo "==> Quast script finished"
exit 0