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

plink --file $directory/populations.plink --make-bed --out $directory/admixture/admixture_snps --allow-extra-chr 0
cut -f 1 -d ' ' $directory/admixture/admixture_snps.fam > $directory/admixture/admixture_snps.ind2pop

for r in {1..20}
do
  rint=${RANDOM}
  mkdir $directory/admixture/cv/cv_seed_$rint
  
  for ((K=$Klow;K<=$Khigh;K++))
  do 
      admixture --cv -s $rint $directory/admixture/admixture_snps.bed $K | tee $directory/admixture/cv/cv_seed_$rint/log.snps.${K}.out
      awk -v K=$K '$1=="CV"{print K,$4}' $directory/admixture/cv/cv_seed_$rint/log.snps.$K.out >> $directory/admixture/cv/snps.CV.txt
      
      admixture -s ${RANDOM} $directory/admixture/admixture_snps.bed $K
  	mv admixture_snps.${K}.Q $directory/admixture/admixture_snps.K${K}r${r}.Q
  done 
done


# create Qmap file for pong
createQmap(){
local r=$1
local K=$2
awk -v K=$K -v r=$r -v file=admixture_snps.K${K}r${r} 'BEGIN{ printf("K%dr%d\t%d\t%s.Q\n",K,r,K,file) }' >> $directory/admixture/admixture_snps.multiplerun.Qfilemap
}
export -f createQmap
for K in {1..10}; do for r in {1..20}; do createQmap $r $K;
done; done

rm admixture_snps*

echo "Admixture Runs Complete"
