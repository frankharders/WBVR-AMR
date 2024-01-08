#!/bin/bash

##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-abricate;


cnt=$(cat samples.txt | wc -l);

while getopts "w:j:r:l:m:q:n:" opt; do
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
      AMRFINDER="`echo $(readlink -m $OPTARG)`"
      echo $AMRFINDER
      ;;	  
	 l)
      echo "-l was triggered! $OPTARG"
      TMP="`echo $(readlink -m $OPTARG)`"
      echo $TMP
      ;;	  
	 m)
      echo "-l was triggered! $OPTARG"
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
	 q)
      echo "-r was triggered! $OPTARG"
      ARCHIVE="`echo $(readlink -m $OPTARG)`"
      echo $ARCHIVE
      ;;
	\?)
      echo "-i for the folder containing assembled genome files, -o for output folder: -$OPTARG" >&2
      ;;

  esac
done

if [ "x" == "x$WORKDIR" ] || [ "x" == "x$ABRICATE" ] || [ "x" == "x$REPORTING" ]; then
    echo "-w $WORKDIR -c $POLISHED -e $SHOVILL -j $ABRICATE -r $REPORTING"
    echo "-w, -c, -e, -j, -r  [options] are required"
    exit 1
fi

## reporting
GenRep="$REPORTING"/general-report.txt;


abricate --list > $REPORTING/abricate.txt;

cat $REPORTING/abricate.txt | sed '1d' | cut -f1 -d$'\t' > $LOG/abricate.lst;


echo -e "these databases will first updated and thereafter used for screening the samples";

cat $LOG/abricate.lst;





while read DB;do


echo -e "abricate databases will ne updated";

abricate-get_db --db $DB --force;




abricate $GENOMES/*.fa --db "$DB" > $TMP/results."$DB".tab;

abricate --summary $ABRICATE/results."$DB".tab > $ABRICATE/summary."$DB".tab;



done < $LOG/abricate.lst


genomeCnt=$(ls $GENOMES/*.fa | wc -l);

echo -e "\nABRICATE\n$genomeCnt genomes are analysed on these versions of the databases:" >> "$GenRep"; 		

abricate --list >> $GenRep;


exit 1



#source activate tseemann;
#
#
# (temp) variables
#DATADIR='/home/harde004/miniconda3/envs/tseemann/db';
#
# get list of available db's 
#abricate --datadir $DATADIR --list > ./TEMP/dblistcomplete.tab;
#
#cat ./TEMP/dblistcomplete.tab | cut -f1 -d$'\t' | sed '1d' > $ABRICATE/db.lst;
#
#
#
#make databases list filename
#echo -e "resfinder\nncbi\nargannot\nvfdb\necoli_vf\nplasmidfinder\nncbi\necoh\ncard" > $ABRICATE/db.lst;
#
#
#
#count0=1;
#countS=$(cat samples.txt | wc -l);
#
#while [ $count0 -le $countS ];do
#
#	SAMPLE=$(cat samples.txt | awk 'NR=='$count0 );
#
#
#	echo $SAMPLE;
#	
#INPUTdir=$SHOVILL/$SAMPLE/;
#
#
#ABRICATEin=$INPUTdir/$SAMPLE'_contigs.fa';
#
#
#MINID=60;
#
#count10=1;
#countDB=$(cat $ABRICATE/db.lst | wc -l);
#
#while [ $count10 -le $countDB ];do
#
#DB=$(cat $ABRICATE/db.lst | awk 'NR=='$count10 );
#
#
#echo $ABRICATEin;
#echo $DB;
#
#ABRICATEout=$ABRICATE/$SAMPLE'.abricate.db_'$DB'.csv';
#
#
# abricate DB's
#vfdb    2597    nucl    2019-Sep-10
#ecoli_vf        2701    nucl    2019-Sep-10
#plasmidfinder   460     nucl    2019-Sep-10
#ncbi    5029    nucl    2019-Sep-10
#card    2594    nucl    2019-Sep-10
#ecoh    597     nucl    2019-Sep-10
#argannot        2223    nucl    2019-Sep-10
#resfinder       3077    nucl    2019-Sep-10
#
#abricate $ABRICATEin --minid $MINID --csv --nopath --db $DB --datadir $DATADIR > $ABRICATEout;
#
#count10=$((count10+1));
#
#done
#
#
#
#count0=$((count0+1));
#				
#done
#
#
#source deactivate;
#
echo "abricate analysis is done for all samples";
echo -e "output files for downstream processing can be found in the directory $ABRICATE";




##### manual abricate #####
#SYNOPSIS
#  Find and collate amplicons in assembled contigs
#AUTHOR
#  Torsten Seemann (@torstenseemann)
#USAGE
#  % abricate --list
#  % abricate [options] <contigs.{fasta,gbk,embl}[.gz]> > out.tab
#  % abricate --summary <out1.tab> <out2.tab> <out3.tab> ... > summary.tab
#GENERAL
#  --help          This help.
#  --debug         Verbose debug output.
#  --quiet         Quiet mode, no stderr output.
#  --version       Print version and exit.
#  --check         Check dependencies are installed.
#  --threads [N]   Use this many BLAST+ threads [1].
#DATABASES
#  --setupdb       Format all the BLAST databases.
#  --list          List included databases.
#  --datadir [X]   Databases folder [/home/harde004/.conda/envs/POPPUNK/db].
#  --db [X]        Database to use [ncbi].
#OUTPUT
#  --noheader      Suppress column header row.
#  --csv           Output CSV instead of TSV.
#  --nopath        Strip filename paths from FILE column.
#FILTERING
#  --minid [n.n]   Minimum DNA %identity [75].
#  --mincov [n.n]  Minimum DNA %coverage [0].
#MODE
#  --summary       Summarize multiple reports into a table.
#DOCUMENTATION
#  https://github.com/tseemann/abricate


exit 1


