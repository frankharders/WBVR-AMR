#!/bin/bash

# Run this script from the same folder as this script is located

SAMPLEFILE=./samples.txt;
wdir=./REPORTING;
rm ./tmp 2> /dev/null
mkdir -p ./tmp
count1=1
countA=$(cat $SAMPLEFILE | wc -l)
echo 'Working...'

final_output=$wdir/Output_data-to-results.tsv;
rm $final_output 2> /dev/null

output_details=$wdir/Output_extra_data-to-results.tsv;
rm $output_details 2> /dev/null
echo -e 'Sample \t Reads \t Average Read Length \t Insert size \t Genome Size \t Read depth \t N50 \t GC% \t Contigs' > $output_details;
old_Bacteria='none'

count3=1
#creating header for phenotypes
res_class=""
amr_class=""
point_list=""
res_gene_head=""
amr_gene_head=""

echo "Creating header"
while [ $count3 -le $countA ]; do
	tmp_isolate=$(cat $SAMPLEFILE | awk 'NR=='$count3);
	resfinder=./11_resfinder-analysis/$tmp_isolate/contigs/ResFinder_results_tab.txt;
	pointfinder=./11_resfinder-analysis/$tmp_isolate/contigs/PointFinder_results.txt;
	amrfinder=./08_amrfinder*/$tmp_isolate'_amrfinder.got';
	
	grep -e "$tmp_isolate" $resfinder | awk 'BEGIN {FS="\t";OFS="\n"}; {print $8}' > ./tmp/tempfile.txt
	count4=2
	countD=$(cat ./tmp/tempfile.txt | wc -l)
	
	while [ $count4 -le $countD ]; do
		pheno=$(cat ./tmp/tempfile.txt | awk 'NR=='$count4 | awk '{print $1;}');
		if [[ "$res_class" != *"$pheno"* ]]; then
			res_class+="$pheno	"
		fi
		
		count4=$((count4+1))
	done
	
	
	grep -e "$tmp_isolate" $amrfinder | awk 'BEGIN {FS="\t";OFS="\n"}; {print $11}' > ./tmp/amr_tempfile.txt
	count7=2
	countG=$(cat ./tmp/amr_tempfile.txt | wc -l)


#haalt alleen classes eruit die bij AMR Element horen
	while [ $count7 -le $countG ]; do
		element=$(grep -e "$tmp_isolate" $amrfinder | awk 'NR=='$count7 | awk 'BEGIN {FS="\t"}; {print $9}');
		
		if [ $element == 'AMR' ]; then
			phenot=$(cat ./tmp/amr_tempfile.txt | awk 'NR=='$count7 | awk '{print $1;}');
			if [[ "$amr_class" != *"$phenot"* ]]; then
				amr_class+="$phenot	"
			fi
		fi
	
		count7=$((count7+1))
	done

	count10=2
	countJ=$(cat $pointfinder | wc -l)
	
	while [ $count10 -le $countJ ]; do
		point=$(cat $pointfinder | awk 'NR=='$count10 | awk 'BEGIN {FS=" "}; {print $1}');
		if [[ "$point_list" != *"$point"* ]]; then
				point_list+="	$point"
		fi

		count10=$((count10+1))
	done

	temp_res=$(grep -e "$tmp_isolate" $resfinder | awk '{print $1;}');
	
	count14=1
	countN=$(echo $temp_res | wc -w)
	
	while [ $count14 -le $countN ]; do
		gen=$(echo $temp_res | cut -d " " -f $count14)
		if [[ "$res_gene_head" != *"$gen	"* ]] || [[ "$res_gene_head" != *"	$gen"* ]]; then
			res_gene_head+="$gen	"
		fi
		count14=$((count14+1))
	done

	temp_amr=$(grep -e "$tmp_isolate" $amrfinder | awk '{print $6;}');
	count16=1
	countP=$(echo $temp_amr | wc -w)
	
	while [ $count16 -le $countP ]; do
		amr_gen=$(echo $temp_amr | cut -d " " -f $count16)
		if [[ "$amr_gene_head" != *"$amr_gen	"* ]] || [[ "$amr_gene_head" != *"	$amr_gen"* ]]; then
			amr_gene_head+="$amr_gen	"
		fi
		count16=$((count16+1))
	done	

	count3=$((count3+1))
done

#removing first tab and sorting alphabetically
res_class="${res_class::-1}"
res_class=$(echo $res_class | xargs -n1 | sort | xargs | tr ' ' '\t')

amr_class="${amr_class::-1}"
amr_class=$(echo $amr_class | xargs -n1 | sort | xargs | tr ' ' '\t')

point_list="${point_list:1}"
point_list=$(echo $point_list | xargs -n1 | sort | xargs | tr ' ' '\t')

res_gene_head="${res_gene_head:1}"
res_gene_head=$(printf "$res_gene_head" | tr [:blank:] '\n' | sort | tr '\n' '\t')
res_gene_head="${res_gene_head%?}"

amr_gene_head="${amr_gene_head::-1}"
amr_gene_head=$(echo "$amr_gene_head" | tr [:blank:] '\n' | sort | tr '\n' '\t')
amr_gene_head="${amr_gene_head%?}"

countE=$(echo "$res_class" | expand -t 1 | wc -w)
count5=1
#putting the phenotypes under one another
rm ./tmp/tempclass.txt 2> /dev/null
while [ $count5 -le $countE ]; do
	
	echo $res_class | cut -d " " -f $count5 >> ./tmp/tempclass.txt
	
	count5=$((count5+1))
done


countH=$(echo "$amr_class" | expand -t 1 | wc -w)
count8=1
rm ./tmp/amr_tempclass.txt 2> /dev/null
#putting the phenotypes under one another
while [ $count8 -le $countH ]; do
	
	echo $amr_class | cut -d " " -f $count8 >> ./tmp/amr_tempclass.txt
	
	count8=$((count8+1))
done

countK=$(echo "$point_list" | expand -t 1 | wc -w)
count11=1
rm ./tmp/pointlist_temp.txt 2> /dev/null
while [ $count11 -le $countK ]; do

	echo $point_list | cut -d " " -f $count11 >> ./tmp/pointlist_temp.txt

	count11=$((count11+1))
done


echo "Analysing samples"

while [ $count1 -le $countA ]; do
	isolate=$(cat $SAMPLEFILE | awk 'NR=='$count1);
	resfinder=./11_resfinder-analysis/$isolate/contigs/ResFinder_results_tab.txt;
	amrfinder=./08_amrfinder*/$isolate'_amrfinder.got';
	pointfinder=./11_resfinder-analysis/$isolate/contigs/PointFinder_results.txt;
	
	#checking if sample exists otherwise continue with the next one
	if [ -z $isolate ]; then
		count1=$((count1+1))
		continue
	fi
	
	count6=1
	countF=$(cat ./tmp/tempclass.txt | wc -l)
	res_count=""
	
	while [ $count6 -le $countF ]; do
		phen=$(cat ./tmp/tempclass.txt | awk 'NR=='$count6);
		phen_count=$(grep -c "$phen" $resfinder)
		res_count+="	$phen_count"
		
		count6=$((count6+1))
	done
	res_count="${res_count:1}"
	
	count9=1
	countI=$(cat ./tmp/amr_tempclass.txt | wc -l)
	amr_count=""
	
	
	while [ $count9 -le $countI ]; do
		phe=$(cat ./tmp/amr_tempclass.txt | awk 'NR=='$count9);
		phe_count=$(grep -i -c "$phe" $amrfinder)
		amr_count+="	$phe_count"
		
		count9=$((count9+1))
	done
	amr_count="${amr_count:1}"
	
	count12=1
	countL=$(cat ./tmp/pointlist_temp.txt | wc -l);
	punt_total=""
	while [ $count12 -le $countL ]; do
		punt=$(cat ./tmp/pointlist_temp.txt | awk 'NR=='$count12);
		punt_tmp=$(grep -i "$punt" $pointfinder | awk 'BEGIN {FS=" "}; {print $2}' | tr '\n' ',' | sed 's/,/, /g')
		if [ -z "$punt_tmp" ]; then
			punt_tmp="0"
		else
		#result is multiple hits so this removes the last comma and space from them
			punt_tmp="${punt_tmp%??}"
		fi
		punt_total+="	$punt_tmp"
		count12=$((count12+1))
	done
	punt_total="${punt_total:1}"

	res_gene=""
	temp_res=$(grep -e "$isolate" $resfinder | awk '{print $1;}');
	echo $temp_res > ./tmp/individual_gene.txt;
	
	#putting genes count from resfinder after each other
	if [ -z $gen ]; then
	NONE
	elif [[ "${gene_comp}" == "$gen" ]]; then
		res_gene_count+="	1";
		res_test="Yes";
	fi
	for GENE in $temp_res; do
		res_gene+=", ${GENE}"
	done
	res_gene="${res_gene:2}"
	
	count13=1
	countM=$(echo $res_gene_head | wc -w)
	res_gene_count=""
	filter_temp_res=$(echo "temp_res" | xargs -n1 | sort -u | xargs)
	while [ $count13 -le $countM ]; do
		gen="$(echo $res_gene_head | cut -d " " -f $count13)"
		res_test=""
		for gene_comp in $filter_temp_res; do
			if [ -z $gen ]; then
				count13=$((count13+1))
			elif [[ "${gene_comp}" == "$gen" ]]; then
				res_gene_count+="	1";
				res_test="Yes";
			fi
		done
		if [[ $res_test != "Yes" ]]; then
			res_gene_count+="	0"
		fi
		
		count13=$((count13+1))
	done
	#removing first tab
	res_gene_count="${res_gene_count:1}"
	
	count15=1
	countO=$(echo $amr_gene_head | wc -w)
	amr_gene_count=""
	
	temp_amr=$(grep -e "$isolate" $amrfinder | awk '{print $6;}');
	filter_temp_amr=$(echo "temp_amr" | xargs -n1 | sort -u | xargs)
	while [ $count15 -le $countO ]; do
		gen=$(echo $amr_gene_head | cut -d " " -f $count15)
		amr_gene_test=""
		for amr_comp in $filter_temp_amr; do
			if [ -z $gen ]; then
				count15=$((count15+1))
			elif [[ "${amr_comp}" == "$gen" ]]; then
				amr_gene_count+="	1";
				amr_gene_test="Yes";
			fi
		done
			if [[ $amr_gene_test != "Yes" ]]; then
				amr_gene_count+="	0";
			fi
		count15=$((count15+1))
	done
	#removing first tab
	amr_gene_count="${amr_gene_count:1}"

	
	mlst_file=$wdir/'all_samples_general_MLST.tab'*;
	mlst_nr=$(($((count1*2))-1))
	mlst_nr2=$((count1*2))
	Bacteria=$(grep -e "$isolate" $mlst_file | awk '{print $2}');
	
	#If the bacteria changes then so does the mlst so the header gets reprinted
	if [ $Bacteria != $old_Bacteria ]; then
		mlstheader=$(cat $mlst_file | awk 'NR=='$mlst_nr | awk 'BEGIN {FS="\t"}; {print $4,$5,$6,$7,$8,$9,$10}' | tr [:blank:] '\t');
		echo -e "Sample \t $res_class \t $res_gene_head \t Gene_Resfinder \t Scheme \t ST \t $mlstheader \t $amr_class \t $amr_gene_head \t amr_res_gene \t $point_list" >> $final_output;
	fi
	
	old_Bacteria=$Bacteria;
	MLSTtype=$(grep -e "$isolate" $mlst_file | awk 'BEGIN {FS="\t";OFS="\t"}; {print $3,$4,$5,$6,$7,$8,$9,$10}');

	Efflux=0
	Beta_lactam_amr=0
	other_class=0
	countB=$(grep -e "$isolate" $amrfinder | awk 'BEGIN {FS="\t"}; {print $9}' | wc -l);
	count2=1
	amr_res_gene=""
	
	while [ $count2 -le $countB ] ; do
		elem=$(grep -e "$isolate" $amrfinder | awk 'NR=='$count2 | awk 'BEGIN {FS="\t"}; {print $9}');
						
			
		if [ $elem == 'AMR' ]; then
			temp_gene=$(grep -e "$isolate" $amrfinder | awk 'NR=='$count2 | awk 'BEGIN {FS="\t"}; {print $6}');
			amr_res_gene+=", $temp_gene"
						
		fi
		count2=$((count2+1))
	done
	#removing first comma and space
	amr_res_gene="${amr_res_gene:2}"

	sample=$(echo $isolate | cut -d '_' -f1 | tr - .)
	echo -e "$sample \t $res_count \t $res_gene_count \t $res_gene \t $Bacteria \t $MLSTtype \t $amr_count \t $amr_gene_count \t  $amr_res_gene \t $punt_total" >> $final_output

#Creating separate file for Mike
	
	inser_file=$wdir/'all.samples.general.metrics.tab';
	insertsize=$(grep -e "$isolate" $inser_file | awk 'BEGIN {FS="\t"}; {print $4}');
	echo $isolate
	
	report_file=$wdir/$isolate/$isolate'.report.tsv'
	total_length=$(cat $report_file | awk 'NR=='16 | awk 'BEGIN {FS="\t"}; {print $2}');
	N50=$(cat $report_file | awk 'NR=='18 | awk 'BEGIN {FS="\t"}; {print $2}');
	reads=$(cat $report_file | awk 'NR=='22 | awk 'BEGIN {FS="\t"}; {print $2}');
	GC=$(cat $report_file | awk 'NR=='17 | awk 'BEGIN {FS="\t"}; {print $2}');
	contigs=$(cat $report_file | awk 'NR=='14 | awk 'BEGIN {FS="\t"}; {print $2}');
	avg_cov_depth=$(cat $report_file | awk 'NR=='27 | awk 'BEGIN {FS="\t"}; {print $2}');
	tempwdir=./01_rawstats/$isolate;
	unzip -q $tempwdir/$isolate'_R1_fastqc.zip' -d $tempwdir/$isolate'_R1_fastqc';
	unzip -q $tempwdir/$isolate'_R2_fastqc.zip' -d $tempwdir/$isolate'_R2_fastqc';
	
	reads1=$(cat $tempwdir/$isolate'_R1_fastqc'/$isolate'_R1_fastqc'/'fastqc_data.txt' | awk 'NR=='9 | awk 'BEGIN {FS="\t"}; {print $2}')
	reads2=$(cat $tempwdir/$isolate'_R2_fastqc'/$isolate'_R2_fastqc'/'fastqc_data.txt' | awk 'NR=='9 | awk 'BEGIN {FS="\t"}; {print $2}')
	reads1_2=$(($reads1+$reads2))
	avgreads=$(echo "scale=1 ; $reads1_2 / 2" | bc)
	
	rm -r $tempwdir/$isolate'_R1_fastqc'
	rm -r $tempwdir/$isolate'_R2_fastqc'

	echo -e $sample '\t' $reads '\t' $avgreads '\t' $insertsize '\t' $total_length '\t' $avg_cov_depth '\t' $N50 '\t' $GC '\t' $contigs >> $output_details
	count1=$((count1+1))
done

echo 'Completed'
