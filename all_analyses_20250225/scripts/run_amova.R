#!/usr/bin/env Rscript

library(optparse)
library(tidyverse)
library(adegenet)
library(poppr)
library(ape)
library(vcfR)

option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="input VCF file", metavar="character"),
  make_option(c("-p", "--pop_file"), type="character", default=NULL, 
              help="Text file containing population/hierarchy for AMOVA", metavar="character"),
  make_option(c("-m", "--missing_thresh"), type="double", default = 0.3,
              help="Cutoff value for poppr.amova"),
  make_option(c("-w", "--within"), type="logical", default = FALSE,
              help="Within argument for poppr.amova")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser)

if (is.null(opt$input)){
  print_help(opt_parser)
  stop("Input VCF file not supplied", call.=FALSE)
}

if (is.null(opt$pop_file)) {
  print_help(opt_parser)
  stop("Population (hierarchy) file not supplied", call.=FALSE)
}

outname <- gsub('(.*)[.]vcf', '\\1', opt$input)
print(outname)

vcf <- read.vcfR(opt$input)
data_genind <- vcfR2genind(vcf)

ind <- rownames(data_genind@tab)

hierarchy <- read.delim(opt$pop_file, header = FALSE, )
hierarchy <- hierarchy[match(ind, hierarchy[,1]),]

if(ncol(hierarchy) == 3) {
  colnames(hierarchy) <- c('ind', 'pop', 'meta')
  pop(data_genind) <- hierarchy[,2]
  strata(data_genind) <- hierarchy[,-1]
  
  data_genclone <- as.genclone(data_genind)
  
  amova_30_pegas <- poppr.amova(data_genclone, ~meta/pop, cutoff=opt$missing_thresh, within=opt$within, method='pegas', nperm=1000)
  sink(file = paste0(outname, '.amova.log'))
  print(paste0("Time Run: ", Sys.time()))
  print(amova_30_pegas)
  cat('\nBetween_Strata Within_Strata Between_Individuals\n')
  print(amova_30_pegas$varcomp$sigma2/sum(amova_30_pegas$varcomp$sigma2))
  sink(file = NULL)
  
} else if(ncol(hierarchy) == 2) {
  colnames(hierarchy) <- c('ind', 'pop')
  pop(data_genind) <- hierarchy[,2]
  strata(data_genind) <- data.frame(pop = hierarchy[,2])
  
  data_genclone <- as.genclone(data_genind)
  
  amova_30_pegas <- poppr.amova(data_genclone, ~pop, cutoff=opt$missing_thresh, within=opt$within, method='pegas', nperm=1000)
  sink(file = paste0(outname, '.amova.log'))
  print(paste0("Time Run: ", Sys.time()))
  print(amova_30_pegas)
  cat('\nBetween_Strata Between_Individuals\n')
  print(amova_30_pegas$varcomp$sigma2/sum(amova_30_pegas$varcomp$sigma2))
  sink(file = NULL)
}




