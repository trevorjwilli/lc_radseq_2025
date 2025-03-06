#!/bin/bash
set -e
set -u
set -o pipefail

if [ "$#" -lt 1 ] 
then
    echo "ERROR: The required number of arguments not provided"
    echo "Usage: run_admixture.sh [DIRECTORY]"
fi

Klow=2
Khigh=10
directory=$1

if [ -d $directory/admixture ]
then
  rm -r $directory/admixture 
fi

if [ -d $directory/admixture/cv ]
then
  rm -r $directory/admixture/cv
fi 

mkdir $directory/admixture
mkdir $directory/admixture/cv

awk -F'\t' -v OFS='\t' ' { sub(/RAD_/, "", $1)} 1' $directory/plink.bim > $directory/tmp.bim
cp $directory/tmp.bim  $directory/plink.bim

cut -f 1 -d ' ' $directory/plink.fam > $directory/admixture/admixture_snps.ind2pop

for r in {1..20}
do
  rint=${RANDOM}
  mkdir $directory/admixture/cv/cv_seed_$rint
  
  for ((K=$Klow;K<=$Khigh;K++))
  do 
      admixture --cv -s $rint $directory/plink.bed $K | tee $directory/admixture/cv/cv_seed_$rint/log.snps.${K}.out
      awk -v K=$K '$1=="CV"{print K,$4}' $directory/admixture/cv/cv_seed_$rint/log.snps.$K.out >> $directory/admixture/cv/snps.CV.txt
      
      admixture -s ${RANDOM} $directory/plink.bed $K
  	  mv plink.${K}.Q $directory/admixture/plink.K${K}r${r}.Q
  done 
done


# create Qmap file for pong
createQmap(){
local r=$1
local K=$2
awk -v K=$K -v r=$r -v file=plink.K${K}r${r} 'BEGIN{ printf("K%dr%d\t%d\t%s.Q\n",K,r,K,file) }' >> $directory/admixture/plink.multiplerun.Qfilemap
}
export -f createQmap
for K in {2..10}; do for r in {1..20}; do createQmap $r $K;
done; done

echo "Admixture Runs Complete"
