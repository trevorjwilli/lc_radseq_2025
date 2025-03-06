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

cut -f 1-5 $directory/populations.plink.ped | awk '{ print $0 "\t" $1 }' > $directory/populations.plink.pedind
sed -i -e 's/un/1/g' $directory/populations.plink.map

if [ -f $directory/pca.parfile ]
then
    rm $directory/pca.parfile
fi

(echo "genotypename: populations.plink.ped" >> $directory/pca.parfile)
(echo "snpname: populations.plink.map " >> $directory/pca.parfile)
(echo "indivname: populations.plink.pedind" >> $directory/pca.parfile)
(echo "evecoutname: pca/pca.evec" >> $directory/pca.parfile)
(echo "evaloutname: pca/pca.eval" >> $directory/pca.parfile)
(echo "numoutevec: 20" >> $directory/pca.parfile)

cd $directory

smartpca -p pca.parfile > pca.log



