#***********************************************
#* Survival analysis of lung cancer study
#* read the calculated roughness measurement based on BayesLASA output
#* Table.1, 2 and S2-S7, S16
#***********************************************

library(ggplot2)
library(tidyr)
library(dplyr)
library(moments)
library(survival)
library(survminer)
library(knitr)
library(tab)

#***************
#* file path
#***************
code_file <- "code/landmark_detection/"
input <- "manuscript_reproducibility/results/real_data_pathology_images/"
data.loc <- "data/real_data_pathology_images"
rdatloc <- file.path(input, "BayesLASA")

fig.output <- "manuscript_reproducibility/figures_and_tables"
# Read data ---------------------------------------------------------------

##* load roughness
Roughness <- read.csv(file.path(input, "summary_statistics", "Roughness_summary.csv"), row.names = 1)
rough <- Roughness %>%
  dplyr::filter(shape == 1) %>%
  gather(roughness, value, 4:14) %>%
  group_by(sample, BetaSigma, roughness) %>%
  summarise(
    mean = mean(value, na.rm = T), sd = sd(value, na.rm = T),
    kurtosis = kurtosis(value, na.rm = T), skewness = skewness(value, na.rm = T),
    q95 = quantile(value, 0.95, na.rm = T), q90 = quantile(value, 0.90, na.rm = T),
    q85 = quantile(value, 0.85, na.rm = T), q80 = quantile(value, 0.80, na.rm = T),
    q75 = quantile(value, 0.75, na.rm = T), q70 = quantile(value, 0.70, na.rm = T),
    q50 = quantile(value, 0.50, na.rm = T)
  )


##* patient info
##* get sample from clinical data, use sample name to extract K and di
load(file.path(input, "clinical_info.Rdata"))
pat.dat <- data %>%
  dplyr::select(patient_id, slide_id, dead, stage, female, tobacco, survival_time_new) %>%
  dplyr::filter(slide_id %in% rough$sample) %>%
  distinct() %>%
  mutate(slide_id = as.numeric(slide_id))


#* area, parameter and Ks of tumor region
perim <- read.csv(file = file.path(input, "perimeter.csv"))
Ks <- read.csv(file.path(input, "LargestK_bs500.csv"), row.names = 1)
areas <- read.csv(file = file.path(input, "areas.csv"), row.names = 1)
r_tb <- areas %>%
  group_by(sample) %>%
  filter(area == max(area), sample %in% rough$sample) %>%
  dplyr::select(sample, shape, area) %>%
  left_join(rough, by = "sample") %>%
  left_join(Ks, by = "sample")

ssamples <- r_tb %>%
  filter(sample %in% rough$sample) %>%
  inner_join(pat.dat, by = c("sample" = "slide_id")) %>%
  distinct(patient_id, sample) %>%
  pull(sample)

tt <- Ks %>%
  left_join(perim, by = c("sample", "shape")) %>%
  filter(sample %in% ssamples) %>%
  mutate(KperLen = K / perim * 100) %>%
  gather(Measure, value, c(2, 5, 6))



# Table 1 -----------------------------------------------------------------
###############################
##* survival analysis with Ra
###############################
##* get data
Ra_tb <- r_tb %>%
  filter(sample %in% ssamples, roughness == "Ra") %>%
  inner_join(pat.dat, by = c("sample" = "slide_id"))
##* cox model
fit_ra <- coxph(Surv(time = survival_time_new, event = dead) ~ mean + sd + kurtosis + skewness + K +
  cluster(patient_id) + area + stage + tobacco + female, data = Ra_tb)
##* print model
fit_ra %>% tabcoxph(factor.compression = 1, columns = c("beta", "se", "hr", "hr.ci", "p"))
# ##*  latex format
# fit_ra  %>% tabcoxph(factor.compression = 1, columns = c( "beta","se", "hr","hr.ci", "p"), latex = T) %>%
#   kable(format = "latex")
fit_ra %>%
  tabcoxph(factor.compression = 1, columns = c("beta", "se", "hr", "hr.ci", "p")) %>%
  write.csv(file.path(fig.output, paste0("table_1.csv")))
