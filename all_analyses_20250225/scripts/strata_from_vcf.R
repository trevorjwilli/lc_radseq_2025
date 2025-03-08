#!/usr/bin/env Rscript

library(optparse)
library(tidyverse)
library(adegenet)
library(ape)
library(vcfR)

option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="input VCF file", metavar="character")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser)

if (is.null(opt$input)){
  print_help(opt_parser)
  stop("Input VCF file not supplied", call.=FALSE)
}

out_name = paste0(dirname(opt$input), '/', 'strata.txt')

vcf <- read.vcfR(opt$input)
data_genind <- vcfR2genind(vcf)

ind <- rownames(data_genind@tab)
pop <- gsub('[0-9]+_(.+)_LTC.+', '\\1', ind)


hierarchy <- data.frame(ind, pop) |>
  mutate(meta = case_when(
    pop %in% c('Bishop', 'Red_Knolls') ~ 'Bishop',
    pop %in% c('Clear_Lake', 'Willow_Pond') ~ 'Clear_Lake',
    pop %in% c('Gandy', 'Keg_Springs') ~ 'Gandy',
    pop %in% c('Mona', 'Big_Springs', 'Jail_Pond', 'Tooele_Army') ~ 'Mona',
    pop %in% c('Leland_Harris', 'Lower_Rocky') ~ 'Leland Harris',
    pop %in% c('Cluster', 'Copilot', 'Mills_Valley', 'Rosebud_Top_P') ~ 'Mills_Valley',
    pop %in% c('Cartier_Slough', 'Deer_Parks', 'Harris_Ponds', 'Henrys_Fork') ~ 'Snake',
    pop %in% c('Mud_Basin') ~ 'Gunnison'
  ))
write_delim(hierarchy, out_name, delim = '\t', col_names = F)

