#!/bin/bash
set -e
set -u
set -o pipefail

if [ $# -lt 1 ]; then
    echo "ERROR: Need to suppply directory with data as an argument"
fi

awk '$2 ~ /.*(Mona|Snake).*/ {  print $0 }' $1/pop_file.txt > $1/mona_snake_pop_file.txt
awk '$2 ~ /.*(Mona|Snake).*/ {  print $1 }' $1/pop_file.txt > $1/mona_snake_samples.txt

cd $1

vcftools --gzvcf populations.snps.vcf.gz --keep mona_snake_samples.txt \
--max-missing 0.8 --out mona_snake --recode




