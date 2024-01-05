#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-assembly;


cnt=$(cat samples.txt | wc -l);

while getopts "w:c:e:y:z:r:m:" opt; do
  case $opt in
     w)
      echo "-w was triggered! $OPTARG"
      WORKDIR="`echo $(readlink -m $OPTARG)`"
      echo $WORKDIR
      ;;
     a)
      echo "-a was triggered! $OPTARG"
      RAW_FASTQ="`echo $(readlink -m $OPTARG)`"
      echo $RAW_FASTQ
      ;;
     b)
      echo "-b was triggered! $OPTARG"
      RAWSTATS="`echo $(readlink -m $OPTARG)`"
      echo $RAWSTATS
      ;;
	 c)
      echo "-c was triggered! $OPTARG"
      POLISHED="`echo $(readlink -m $OPTARG)`"
      echo $POLISHED
      ;;
	 d)
      echo "-d was triggered! $OPTARG"
      TRIMMEDSTATS="`echo $(readlink -m $OPTARG)`"
      echo $TRIMMEDSTATS
      ;;
	 e)
      echo "-e was triggered! $OPTARG"
      SHOVILL="`echo $(readlink -m $OPTARG)`"
      echo $SHOVILL
      ;;
	 f)
      echo "-f was triggered! $OPTARG"
      QUAST="`echo $(readlink -m $OPTARG)`"
      echo $QUAST
      ;;
	 g)
      echo "-g was triggered! $OPTARG"
      QUASTparse="`echo $(readlink -m $OPTARG)`"
      echo $QUASTparse
      ;;
     h)
      echo "-h was triggered! $OPTARG"
      MLST="`echo $(readlink -m $OPTARG)`"
      echo $MLST
      ;;
     i)
      echo "-i was triggered! $OPTARG"
      MLSTparse="`echo $(readlink -m $OPTARG)`"
      echo $MLSTparse
      ;;	  
	 j)
      echo "-j was triggered! $OPTARG"
      ABRICATE="`echo $(readlink -m $OPTARG)`"
      echo $ABRICATE
      ;;
     k)
      echo "-k was triggered! $OPTARG"
      ABRICATEparse="`echo $(readlink -m $OPTARG)`"
      echo $ABRICATEparse
      ;;	  
	 l)
      echo "-l was triggered! $OPTARG"
      TMP="`echo $(readlink -m $OPTARG)`"
      echo $TMP
      ;;	  
	 m)
      echo "-n was triggered! $OPTARG"
      GENOMES="`echo $(readlink -m $OPTARG)`"
      echo $GENOMES
      ;;
	 n)
      echo "-n was triggered! $OPTARG"
      LOG="`echo $(readlink -m $OPTARG)`"
      echo $LOG
      ;;
     r)
      echo "-r was triggered! $OPTARG"
      REPORTING="`echo $(readlink -m $OPTARG)`"
      echo $REPORTING
      ;;
	 y)
      echo "-y was triggered! $OPTARG"
      ASSEMBLER=$OPTARG
      echo $ASSEMBLER
      ;;
     z)
      echo "-r was triggered! $OPTARG"
      CONTIGLENGTH=$OPTARG
      echo $CONTIGLENGTH
      ;;
    \?)
      echo "-i for the folder containing fastq files, -o for output folder: -$OPTARG" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$POLISHED" ] || [ "x" == "x$SHOVILL" ] || [ "x" == "x$ASSEMBLER" ] || [ "x" == "x$CONTIGLENGTH" ] || [ "x" == "x$REPORTING" ] ; then
    echo "-w  $WORKDIR -c $POLISHED -e $SHOVILL -y $ASSEMBLER -z $CONTIGLENGTH -r $REPORTING"
    echo "-w, -c, -e, -y, -z, -r [options] are required"
    exit 1
fi


## reporting
GenRep="$REPORTING"/general-report.txt;


# (temp) variables

DEPTH=100;
MINlen=$CONTIGLENGTH;
MINcov=0;



while read SAMPLE; do 

	echo $SAMPLE;
	
OUTPUTdir=$SHOVILL/$SAMPLE/;
R1=$POLISHED/$SAMPLE/$SAMPLE'_R1.QTR.adapter.correct.fq.gz';
R2=$POLISHED/$SAMPLE/$SAMPLE'_R2.QTR.adapter.correct.fq.gz';

shovill --outdir $OUTPUTdir --depth $DEPTH --minlen $MINlen --mincov $MINcov --keepfiles --assembler $ASSEMBLER --namefmt $SAMPLE'_contig%05d' --force --R1 $R1 --R2 $R2; 

FASTAin=$OUTPUTdir/contigs.fa;
FASTAout=$OUTPUTdir/$SAMPLE'_contigs.fa';

GFAin=$OUTPUTdir/contigs.gfa;
GFAout=$OUTPUTdir/$SAMPLE'_contigs.gfa';

## create a single line fasta file

awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' $FASTAin > $FASTAout;
	
	let cnt--;	
	echo -e "$cnt samples to go!";
	echo "NEXT";

cp $FASTAout $GENOMES;

rm "$OUTPUTdir"/*.gz;
rm -r "$OUTPUTdir"/spades;
				
done < samples.txt


fastaCnt=$(ls $SHOVILL/*/contigs.fa | wc -l);

echo -e "\nASSEMBLY\nfrom $fastaCnt samples a draft genome is constructed using $ASSEMBLER\n" >> "$GenRep"; 		
	

echo "genome assembly is done using $ASSEMBLER for all samples";
echo -e "output files for downstream processing can be found in the directory $SHOVILL";


exit 1

#####
#SYNOPSIS
#  De novo assembly pipeline for Illumina paired reads
#USAGE
#  shovill [options] --outdir DIR --R1 R1.fq.gz --R2 R2.fq.gz
#GENERAL
#  --help          This help
#  --version       Print version and exit
#  --check         Check dependencies are installed
#INPUT
#  --R1 XXX        Read 1 FASTQ (default: '')
#  --R2 XXX        Read 2 FASTQ (default: '')
#  --depth N       Sub-sample --R1/--R2 to this depth. Disable with --depth 0 (default: 100)
#  --gsize XXX     Estimated genome size eg. 3.2M <blank=AUTODETECT> (default: '')
#OUTPUT
#  --outdir XXX    Output folder (default: '')
# --force         Force overwite of existing output folder (default: OFF)
#  --minlen N      Minimum contig length <0=AUTO> (default: 0)
#  --mincov n.nn   Minimum contig coverage <0=AUTO> (default: 2)
#  --namefmt XXX   Format of contig FASTA IDs in 'printf' style (default: 'contig%05d')
#  --keepfiles     Keep intermediate files (default: OFF)
#RESOURCES
#  --tmpdir XXX    Fast temporary directory (default: '')
#  --cpus N        Number of CPUs to use (0=ALL) (default: 16)
#  --ram n.nn      Try to keep RAM usage below this many GB (default: 32)
#ASSEMBLER
#  --assembler XXX Assembler: velvet megahit skesa spades (default: 'spades')
#  --opts XXX      Extra assembler options in quotes eg. spades: "--untrusted-contigs locus.fna" ... (default: '')
#  --kmers XXX     K-mers to use <blank=AUTO> (default: '')
#MODULES
#  --trim          Enable adaptor trimming (default: OFF)
#  --noreadcorr    Disable read error correction (default: OFF)
#  --nostitch      Disable read stitching (default: OFF)
#  --nocorr        Disable post-assembly correction (default: OFF)
#HOMEPAGE
#  https://github.com/tseemann/shovill - Torsten Seemann

