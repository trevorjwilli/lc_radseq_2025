import pandas as pd
import re
import argparse
import os
import sys

def get_gt(x):
    """ Function to parse vcf sample cell values and extract the genotype """
    if './.' in x:
        out = None
    else:
        out = re.sub('([0-9.]/[0-9.]).*', '\\1', x)
        out = out.split('/')
        out = [int(x) for x in out]
    return(out)

def calc_maf(x):
    """ Function to calculate the minor allele frequency of each loci in a VCF """
    maf = []
    for index, row in x.iterrows():
        loci = []
        for item in row[9:]:
            tmp = get_gt(item)
            if tmp:
                loci.extend(tmp)
        maf.append(sum(loci)/len(loci))
    return(maf)

def read_vcf(x):
    """ Function to read in a vcf to a pandas data frame
        by default, only retains bi-allelic loci
    """
    data_list = []
    meta_list = []
    with open(x, 'r') as infile:
        for line in infile:
            line = line.strip()
            if "#" in line:
                if "#CHROM" in line:
                    header = line.split()
                else: 
                    meta_list.append(line)
            else:
                line = line.split()
                data_list.append(line)

    df = pd.DataFrame(data_list, columns = header)
    df = df[~df["ALT"].str.contains(',')]
    return(df, meta_list)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', help='Input VCF - created using ipyrad')
    parser.add_argument('-m', '--min_maf', default = 0.05, type=float, help='minor allele frequency filter, only loci with a minor allele frequency greater than or equal to the inputted value will be retained')
    parser.add_argument('-n', '--n_ind', default = 0.80, type=float, help='Genotyping frequency - loci genotyped in at least the inputted value will be retained')
    parser.add_argument('-r', '--random_state', default = 42, type=int, help='Random state for sampling a single snp from each locus')
    
    args = parser.parse_args()

    print(f"\nCommand line call: {' '.join(sys.argv)}")

    print(f'\nUsing {args.min_maf} as the maf filter')
    print(f'Using {args.n_ind} as the genotyping frequency filter')
    print(f'\nReading in data from {args.infile}')

    df, meta = read_vcf(args.infile)
    n_loci = df.shape[0]
    n_samp = df.shape[1]-9
    print(f'Found {n_loci} bi-allelic loci from {n_samp} samples\n')

    outname = os.path.splitext(args.infile)[0]
    outname = f"{outname}_filtered.vcf"
    print(f'Writing filtered data to "{outname}"')

    ns = df['INFO'].apply(lambda x: int(re.sub('NS=([0-9]+).+', '\\1', x)))
    df_fil = df[[x/n_samp >= args.n_ind for x in ns]].reset_index(drop=True)

    filtered_loci = n_loci-df_fil.shape[0]
    n_retained = df_fil.shape[0]

    print(f"Filtered {filtered_loci} loci using genotyping frequency filter")

    maf = calc_maf(df_fil)
    df_fil2 = df_fil[[x >= args.min_maf for x in maf]].reset_index(drop=True)

    filtered_loci = n_retained-df_fil2.shape[0]
    print(f"Filtered {filtered_loci} loci using maf filter")

    out = df_fil2.groupby('#CHROM').sample(n=1, random_state=42)

    print(f"\nRetained {out.shape[0]} loci after filtering")

    with open(outname, 'w') as outfile:
        for line in meta:
            outfile.write(f"{line}\n")
    
    out.to_csv(outname, mode='a', sep='\t', index=False)





