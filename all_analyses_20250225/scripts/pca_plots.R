library(tidyverse)

setwd('~/dev/lc_radseq_2025/all_analyses_20250225/')


# stacks ------------------------------------------------------------------

evec <- read.table('data/stacks/pca/pca.evec')
colnames(evec) <- c('sample', paste0('PC', 1:20), 'pop')

eigen <- read.table('data/stacks/pca/pca.eval')
eigen <- eigen |>
  mutate(percent = V1/sum(V1))

admix <- read.table('data/stacks/admixture/admixture_snps.K7r2.Q')
fam <- read.table('data/stacks/admixture/admixture_snps.fam')

colnames(admix) <- paste0('K', 1:7)
admix$sample <- fam$V2
admix$pop <- fam$V1

admix_long <- admix |>
  pivot_longer(1:7)

cbPalette <- c("#009E73", "#E69F00", "#56B4E9", "#999999", "#D55E00", "#0072B2","#F0E442")
names(cbPalette) <- c('K1', 'K2', 'K3', 'K4', 'K5', 'K6', 'K7')

admix_fil <- admix_long |>
  group_by(sample) |>
  filter(value == max(value))

evec <- evec |>
  mutate(sample = gsub('\\w+[:](.*)', '\\1', sample)) |>
  left_join(admix_fil, by = 'sample') |>
  mutate(pop = str_replace(pop.x, "_", " "))


ggplot(evec, aes(PC1, PC2, shape = pop, fill = name, color = pop)) +
  geom_point(size = 3) +
  scale_fill_manual(values = cbPalette, guide = 'none') +
  scale_color_manual(values = c('black', 'black',  "#56B4E9",'black',"#E69F00", "#999999",  'black', 'black'), guide='none') +
  scale_shape_manual(values = c(22,23,8,25,10,7,21,24), 
                     labels = c('Bishop', 'Clear Lake', 'Gandy', 'Leland Harris',
                                'Mills Valley', 'Mona', 'Gunnison', 'Snake'),
                     guide = guide_legend(override.aes=list(
                       shape = c(22,23,8,25,10,7,21,24),
                       color = c('black', 'black',"#56B4E9",'black',"#E69F00", "#999999",  'black', 'black'),
                       fill = c("#56B4E9", "#0072B2", "#56B4E9","#F0E442", "#E69F00", "#999999",  "#D55E00", "#009E73")))) +
  coord_fixed(0.0501529549/0.0739751967) +
  xlab('PC1 (7.4%)') +
  ylab('PC2 (5.0%)') +
  theme_bw() +
  theme(legend.title = element_blank(),
        axis.text = element_text(size = 7),
        axis.title = element_text(size = 7),
        legend.text = element_text(size = 7))

ggsave('figures/stacks_pca.png', device = 'png',
       width = 140, height = 100, units = 'mm', dpi = 300)

ggsave('figures/stacks_pca.pdf', device = 'pdf',
       width = 140, height = 100, units = 'mm', dpi = 300)


# ipyrad ------------------------------------------------------------------


evec <- read.table('data/ipyrad/pca/pca.evec')
colnames(evec) <- c('sample', paste0('PC', 1:20), 'pop')

eigen <- read.table('data/ipyrad/pca/pca.eval')
eigen <- eigen |>
  mutate(percent = V1/sum(V1))

admix <- read.table('data/ipyrad/admixture/plink.K7r5.Q')
fam <- read.table('data/ipyrad/plink.fam')

fam <- fam |>
  mutate(pop = gsub('[0-9]+_(.+)_LTC.+', '\\1', V2),
    pop = case_when(
    pop %in% c('Bishop', 'Red_Knolls') ~ 'Bishop',
    pop %in% c('Clear_Lake', 'Willow_Pond') ~ 'Clear Lake',
    pop %in% c('Gandy', 'Keg_Springs') ~ 'Gandy',
    pop %in% c('Mona', 'Big_Springs', 'Jail_Pond', 'Tooele_Army') ~ 'Mona',
    pop %in% c('Leland_Harris', 'Lower_Rocky') ~ 'Leland Harris',
    pop %in% c('Cluster', 'Copilot', 'Mills_Valley', 'Rosebud_Top_P') ~ 'Mills Valley',
    pop %in% c('Cartier_Slough', 'Deer_Parks', 'Harris_Ponds', 'Henrys_Fork') ~ 'Snake',
    pop %in% c('Mud_Basin') ~ 'Mud Basin'
  ))

colnames(admix) <- paste0('K', 1:7)
admix$sample <- fam$V2
admix$pop <- fam$pop

admix_long <- admix |>
  pivot_longer(1:7)

admix_fil <- admix_long |>
  group_by(sample) |>
  filter(value == max(value))

evec <- evec |>
  mutate(sample = gsub('\\w+[:](.*)', '\\1', sample)) |>
  left_join(admix_fil, by = 'sample')

evec_mean <- evec |>
  group_by(pop.y) |>
  summarise(PC1 = mean(PC1), PC2 = mean(PC2))

ggplot() +
  geom_point(data = evec, aes(PC1, PC2, color = name)) +
  geom_text(data = evec_mean, aes(x=PC1, y=PC2, label=pop.y))

cbPalette <- c("#D55E00",  "#0072B2", "#009E73", "#F0E442", "#999999",  "#E69F00", "#56B4E9")
names(cbPalette) <- c('K1', 'K2', 'K3', 'K4', 'K5', 'K6', 'K7')

ggplot(evec, aes(PC1, PC2, shape = pop.y, fill = name, color = pop.y)) +
  geom_point(size = 3) +
  scale_fill_manual(values = cbPalette, guide = 'none') +
  scale_color_manual(values = c('black', 'black',  "#D55E00",'black',"#E69F00", "#999999",  'black', 'black'), guide='none') +
  scale_shape_manual(values = c(22,23,8,25,10,7,21,24), 
                     labels = c('Bishop', 'Clear Lake', 'Gandy', 'Leland Harris',
                                'Mills Valley', 'Mona', 'Gunnison', 'Snake'),
                     guide = guide_legend(override.aes=list(
                       shape = c(22,23,8,25,10,7,21,24),
                       color = c('black', 'black',"#D55E00",'black',"#E69F00", "#999999",  'black', 'black'),
                       fill = c("#56B4E9", "#0072B2", "#56B4E9","#F0E442", "#E69F00", "#999999",    "#E69F00", "#009E73")))) +
  coord_fixed(eigen$percent[2]/eigen$percent[1]) +
  xlab('PC1 (18.5%)') +
  ylab('PC2 (15.4%)') +
  theme_bw() +
  theme(legend.title = element_blank(),
        axis.text = element_text(size = 7),
        axis.title = element_text(size = 7),
        legend.text = element_text(size = 7))

ggsave('figures/ipyrad_pca.png', device = 'png',
       width = 140, height = 112, units = 'mm', dpi = 300)

ggsave('figures/ipyrad_pca.pdf', device = 'pdf',
       width = 140, height = 112, units = 'mm', dpi = 300)
