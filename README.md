# Least Chub (*Iotichthys phlegethontis*) RADseq scripts and data

This repository contains the scripts and data (VCF files) pertaining to the analyses from:

Billman et al. 2025. Genetic analysis of recently discovered Least Chub populations in the upper Snake River and Bonneville drainages. *Ecology and Evolution* (in review).

## Methods

Individual least chub were collected between 2001 and 2022 from extant (source), refuge, and newly discovered populations and sequenced via single digest restriction-site associated DNA sequencing (RADseq) using the SbfI enzyme. Following sequencing, individuals were genotyped using Stacks (Catchen et al., 2011, 2013) and ipyrad (Eaton and Overcast 2020) de-novo based assembly pipelines. Additional methodology can be found within the methods section of the paper.

## Repository File Structure

```
README.md
all_analyses_20250225/
    data/
        individual_pops/ # Data from Stacks pipelines including only source and refuge populations
            Bishop/ 
                Data files (output from ipyrad program)
                AMOVA results testing difference between source and refuge populations
            Clear_Lake/ # This repository and those below contain similar files to the directory above
            Gandy/
            Leland_Harris/
            Mills_Valley/
            Mona/
        ipyrad/ # Data and results using the ipyrad pipeline
            Data files (VCF output from ipyrad, population structure files, etc.)
            admixture/ # Files pertaining to Admixture analysis
            amova/ # Files pertaining to amova
            pca/ # Files pertaining to PCA 
        stacks/ # Data and results using the Stacks pipeline
            Data files (output from Stacks populations program, , etc.)
            admixture/ # Files pertaining to Admixture analysis
            amova/ # Files pertaining to amova
            pca/ # Files pertaining to PCA
figures/
    Figures used in the manuscript
    admixture_raw/ # Output from Pong program for individual values of K
        ipyrad/
        stacks/
scripts/
    Bash, python, and R scripts used to conduct analyses
```

## Contact

Trevor Williams:
 * email: trevorjwilli@gmail.com

 