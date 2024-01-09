#!/bin/bash


##  activate the environment for this downstream analysis
eval "$(conda shell.bash hook)";
conda activate amr-multiqc;



## reporting
GenRep=REPORTING/general-report.txt;


ToDay=$(date +%Y-%m-%d-%T);

projectName=$(echo $PWD | rev | cut -f1 -d'/' | rev);

dataFile=REPORTING/"$projectName"_multiQC_"$ToDay";


multiqc . -o multiqc -i $dataFile


exit 1
