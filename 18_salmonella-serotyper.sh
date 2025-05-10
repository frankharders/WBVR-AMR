#!/bin/bash
#
### salmonella serotyping using seqzero.2

##  finalized 2022-12-30, frank harders
##  can run seperately

## ToDo sum list seroTypes?


##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-seqsero2;

count0=1;
countS=$(cat samples.txt | wc -l);

#rm -rf "$PWD"/28_salmonellaSerotyping;

FILE=samples.txt;

mkdir -p 18_salmonellaSerotyping;

seroPATH='/home/wbvr006/GIT/SeqSero2/bin';
seroDB='/home/wbvr006/GIT/salmonellatypefinder/mlst_db/';
seroOUT=18_salmonellaSerotyping;

rm "$seroOUT"/all.samples.salmonella-typing.final.results.tab;
rm "$seroOUT"/all.samples.salmonella-typing.temp.results.tab;



count0=1;
countS=$(cat "$FILE" | wc -l);

while [ "$count0" -le "$countS" ];do

	SAMPLE=$(cat "$FILE" | awk 'NR=='"$count0" );
	
	rm -rf "$seroOUT/$SAMPLE";

	mkdir -p "$seroOUT/$SAMPLE";	

		echo "sample=$SAMPLE";

## analysis must be conducted on reads, no assembled genome can be used at this point of time
			R1=./02_polished/"$SAMPLE"/"$SAMPLE"_R1.QTR.adapter.correct.fq.gz;
			R2=./02_polished/"$SAMPLE"/"$SAMPLE"_R2.QTR.adapter.correct.fq.gz;

## not possible for assembled genomes
  seroIn=genomes/"$SAMPLE".fa;

	~/GIT/SeqSero2/bin/SeqSero2_package.py -p 24 -m a -t 2 -i "$R1" "$R2" -n "$SAMPLE" -d "$seroOUT"/"$SAMPLE";


	count0=$((count0+1));
done

count1=1;
countT=$(cat samples.txt | wc -l);

while [ "$count1" -le "$countT" ];do

	sample=$(cat samples.txt | awk 'NR=='"$count1");

echo "$sample";


## prepare files for overall results table 					
		cat "$seroOUT"/"$sample"/SeqSero_result.tsv | head -n1 > "$seroOUT"/all.samples.salmonella-typing.head.tab;
		cat "$seroOUT"/"$sample"/SeqSero_result.tsv | sed 1d >> "$seroOUT"/all.samples.salmonella-typing.temp.results.tab;

## rename original headers into sample related headers for downstream processing
			cat "$seroOUT"/"$sample"/Extracted_antigen_alleles.fasta | sed "s/\>NODE\_/\>"$sample"\_NODE\_/g" > "$seroOUT"/"$sample"/"$sample".extracted.antigen_alleles.fasta;
			cat "$seroOUT"/"$sample"/"$sample"_R1.QTR.adapter.correct.fq.gz_H_and_O_and_specific_genes.fasta_mem.fasta | sed "s/\>NODE\_/\>"$sample"\_NODE\_/g" > "$seroOUT"/"$sample"_H_and_O_and_specific_genes.fasta;

count1=$((count1+1));
done

cat "$seroOUT"/all.samples.salmonella-typing.head.tab "$seroOUT"/all.samples.salmonella-typing.temp.results.tab > "$seroOUT"/all.samples.salmonella-typing.final.results.tab;



exit 1


##### SeqSero2_package
#
#usage: SeqSero2_package.py -t <data_type> -m <mode> -i <input_data> [-d <output_directory>] [-p <number of threads>] [-b <BWA_algorithm>]
#
#Developper: Shaokang Zhang (zskzsk@uga.edu), Hendrik C Den-Bakker (Hendrik.DenBakker@uga.edu) and Xiangyu Deng (xdeng@uga.edu)
#
#Contact email:seqsero@gmail.com
#
#Version: v1.2.1
#
#optional arguments:
#  -h, --help            show this help message and exit
#  -i I [I ...]          <string>: path/to/input_data
#  -t {1,2,3,4,5}        <int>: '1' for interleaved paired-end reads, '2' for
#                        separated paired-end reads, '3' for single reads, '4'
#                        for genome assembly, '5' for nanopore reads
#                        (fasta/fastq)
#  -b {sam,mem}          <string>: algorithms for bwa mapping for allele mode;
#                        'mem' for mem, 'sam' for samse/sampe; default=mem;
#                        optional; for now we only optimized for default 'mem'
#                        mode
#  -p P                  <int>: number of threads for allele mode, if p >4,
#                        only 4 threads will be used for assembly since the
#                        amount of extracted reads is small, default=1
#  -m {k,a}              <string>: which workflow to apply, 'a'(raw reads
#                        allele micro-assembly), 'k'(raw reads and genome
#                        assembly k-mer), default=a
#  -n N                  <string>: optional, to specify a sample name in the
#                        report output
#  -d D                  <string>: optional, to specify an output directory
#                        name, if not set, the output directory would be
#                        'SeqSero_result_'+time stamp+one random number
#  -c                    <flag>: if '-c' was flagged, SeqSero2 will only output
#                        serotype prediction without the directory containing
#                        log files
#  -s                    <flag>: if '-s' was flagged, SeqSero2 will not output
#                        header in SeqSero_result.tsv
#  --phred_offset {33,64,auto}
#                        <33|64|auto>: offset for FASTQ file quality scores,
#                        default=auto
#  --check               <flag>: use '--check' flag to check the required
#                        dependencies
#  -v, --version         show program's version number and exit
#
#
#####


