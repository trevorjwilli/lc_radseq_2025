library(tidyverse)
library(ggsci)


setwd('~/dev/lc_radseq_2025/all_analyses_20250225/')

# CV stacks ---------------------------------------------------------------

std <- function(x) sd(x)/sqrt(length(x))

cv <- read.table('data/stacks/admixture/cv/snps.CV.txt')

colnames(cv) <- c('K', 'cv_error')
cv$run <- rep(1:20, each = 9)

cv_sum <- cv %>%
  group_by(K) %>%
  summarise(ave = mean(cv_error), stdev = std(cv_error))

cv_sum |>
  filter(ave == min(ave))

ggplot(cv_sum, aes(x = K, y = ave)) +
  geom_line() +
  geom_errorbar(aes(ymin=ave-stdev, ymax=ave+stdev), width=0.3) +
  geom_point(shape=21, size = 2) +
  scale_x_continuous(breaks = 1:12) +
  ylab('CV Error') +
  theme_bw()

ggsave('figures/stacks_admixture_cv_error.pdf', width = 10, height = 7)
ggsave('figures/stacks_admixture_cv_error.png', width = 10, height = 7)


# CV ipyrad ---------------------------------------------------------------

std <- function(x) sd(x)/sqrt(length(x))

cv <- read.table('data/ipyrad/admixture/cv/snps.CV.txt')

colnames(cv) <- c('K', 'cv_error')
cv$run <- rep(1:20, each = 9)

cv_sum <- cv %>%
  group_by(K) %>%
  summarise(ave = mean(cv_error), stdev = std(cv_error))

cv_sum |>
  filter(ave == min(ave))

ggplot(cv_sum, aes(x = K, y = ave)) +
  geom_line() +
  geom_errorbar(aes(ymin=ave-stdev, ymax=ave+stdev), width=0.3) +
  geom_point(shape=21, size = 2) +
  scale_x_continuous(breaks = 1:12) +
  ylab('CV Error') +
  theme_bw()

ggsave('figures/ipyrad_admixture_cv_error.pdf', width = 10, height = 7)
ggsave('figures/ipyrad_admixture_cv_error.png', width = 10, height = 7)
