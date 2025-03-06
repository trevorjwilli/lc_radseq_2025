#!/bin/bash
set -e
set -u
set -o pipefail

if [ $# -lt 1 ]; then
    echo "ERROR: Need to suppply directory with data as an argument"
fi

# Make pop file

python create_popfile.py $1/populations.sumstats.tsv 

awk '$1 ~ /.*(Mills|Mud).*/ {  print $0 }' $1/pop_file.txt > $1/gunnison_mills_pop_file.txt
awk '$1 ~ /.*(Mills|Mud).*/ {  print $1 }' $1/pop_file.txt > $1/gunnison_mills_samples.txt

cd $1

vcftools --vcf populations.snps.vcf --keep gunnison_mills_samples.txt \
--max-missing 0.8 --out gunnison_mills --recode




