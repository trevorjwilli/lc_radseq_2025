#!/bin/bash
set -e
set -u
set -o pipefail

dir_list=($(find $1 -mindepth 1 -maxdepth 1 -type d))
for directory in ${dir_list[@]}
do

python create_popfile.py $directory/populations.sumstats.tsv
Rscript --vanilla run_amova.R -i $directory/populations.snps.vcf -p $directory/pop_file.txt

done

