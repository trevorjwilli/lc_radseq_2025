#!/bin/bash
set -e
set -u
set -o pipefail

directory=$1

if [ -d $directory/pca ]
then
  rm -r $directory/pca 
fi

mkdir $directory/pca

cut -f 1-5 $directory/pca.plink.ped | awk '{ print $0 "\t" $1 }' > $directory/pca.plink.pedind
#sed -i -e 's/un/1/g' $directory/pca.plink.map
awk '{$1=1 ; print ;}' pca.plink.map > tmp.map
mv tmp.map pca.plink.map

if [ -f $directory/pca.parfile ]
then
    rm $directory/pca.parfile
fi

(echo "genotypename: pca.plink.ped" >> $directory/pca.parfile)
(echo "snpname: pca.plink.map " >> $directory/pca.parfile)
(echo "indivname: pca.plink.pedind" >> $directory/pca.parfile)
(echo "evecoutname: pca/pca.evec" >> $directory/pca.parfile)
(echo "evaloutname: pca/pca.eval" >> $directory/pca.parfile)
(echo "numoutevec: 20" >> $directory/pca.parfile)

cd $directory

smartpca -p pca.parfile > pca.log



