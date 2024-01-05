#!/bin/bash

while getopts "w:a:b:c:d:e:f:g:h:i:j:l:m:n:r:s:k:t:u:q:" opt; do
  case $opt in
    w)
      #echo "-w was triggered! $OPTARG"
      WORKDIR="`echo $(readlink -m $OPTARG)`"
      #echo $WORKDIR
      ;;
     a)
      #echo "-a was triggered! $OPTARG"
      RAW_FASTQ="`echo $(readlink -m $OPTARG)`"
      #echo $RAW_FASTQ
      ;;
     b)
      #echo "-b was triggered! $OPTARG"
      RAWSTATS="`echo $(readlink -m $OPTARG)`"
      #echo $RAWSTATS
      ;;
	 c)
      #echo "-c was triggered! $OPTARG"
      POLISHED="`echo $(readlink -m $OPTARG)`"
      #echo $POLISHED
      ;;
	 d)
      #echo "-d was triggered! $OPTARG"
      TRIMMEDSTATS="`echo $(readlink -m $OPTARG)`"
      #echo $TRIMMEDSTATS
      ;;
	 e)
      #echo "-e was triggered! $OPTARG"
      SHOVILL="`echo $(readlink -m $OPTARG)`"
      #echo $SHOVILL
      ;;
	 f)
      #echo "-f was triggered! $OPTARG"
      QUAST="`echo $(readlink -m $OPTARG)`"
      #echo $QUAST
      ;;
	 g)
      #echo "-g was triggered! $OPTARG"
      QUASTparse="`echo $(readlink -m $OPTARG)`"
      #echo $QUASTparse
      ;;
     h)
      #echo "-h was triggered! $OPTARG"
      MLST="`echo $(readlink -m $OPTARG)`"
      #echo $MLST
      ;;
     i)
      #echo "-i was triggered! $OPTARG"
      MLSTparse="`echo $(readlink -m $OPTARG)`"
      #echo $MLSTparse
      ;;	  
     j)
      #echo "-i was triggered! $OPTARG"
      ABRICATE="`echo $(readlink -m $OPTARG)`"
      #echo $ABRICATE
      ;;
	 l)
      #echo "-l was triggered! $OPTARG"
      TMP="`echo $(readlink -m $OPTARG)`"
      #echo $TMP
      ;;
	 m)
      #echo "-n was triggered! $OPTARG"
      GENOMES="`echo $(readlink -m $OPTARG)`"
      #echo $GENOMES
      ;;
	 n)
      #echo "-n was triggered! $OPTARG"
      LOG="`echo $(readlink -m $OPTARG)`"
      #echo $LOG
      ;;
     r)
      #echo "-r was triggered! $OPTARG"
      REPORTING="`echo $(readlink -m $OPTARG)`"
      #echo $REPORTING
      ;;	  
     s)
      #echo "-r was triggered! $OPTARG"
      STARAMR="`echo $(readlink -m $OPTARG)`"
      #echo $STARAMR
      ;;
     t)
      #echo "-r was triggered! $OPTARG"
      RGI="`echo $(readlink -m $OPTARG)`"
      #echo $RGI
      ;;
     q)
      #echo "-r was triggered! $OPTARG"
      ARCHIVE="`echo $(readlink -m $OPTARG)`"
      #echo $ARCHIVE
      ;;
     u)
      echo "-r was triggered! $OPTARG"
      RESFINDER="`echo $(readlink -m $OPTARG)`"
      echo $RESFINDER
      ;;
    \?)
      echo " Let's start some analysis" >&2
      ;;

  esac
done



## selected files/folders for backup per project

project=$(basename "$PWD");


mkdir -p "$PWD"/"$project"-backup;

BACKUP="$PWD"/"$project"-backup;


#  list of files & folders for backup

## files to be copied to backup folder
cp "$PWD"/*.xls* "$BACKUP"; # keytable and or SSF
cp "$PWD"/*.txt "$BACKUP"; # sample file
cp "$PWD"/*.lst "$BACKUP"; # sample lists
cp "$PWD"/*.sh "$BACKUP"; # all scripts used

## folders to be copied to backup folder
cp -r "$PWD"/references "$BACKUP"; # all used references
cp -r "$PWD"/"$QUAST" "$BACKUP"; # analysis of assembled genomes
cp -r "$PWD"/"$RESFINDER" "$BACKUP"; # resfinder analysis
cp -r "$PWD"/"$GENOMES" "$BACKUP"; # draft genomes


# output tar file with all selected data for backup

OUTPUT="$PWD"/"$project".tar.gz;
rm "$OUTPUT";
tar -zcvf "$OUTPUT" "$BACKUP";

exit 1

