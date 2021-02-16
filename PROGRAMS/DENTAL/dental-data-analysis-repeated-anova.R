library(tidyverse);

setwd("C:/Users/psioda/Documents/GitHub/BIOS-767-Programming/DATA/DENTAL");

dental = read.table("dental-data.txt",header=F,sep=",")
colnames(dental)<-c("id","gender","age8","age10","age12","age14");

## transform data;
dental_vert <- as_tibble(dental) %>% 
  tidyr::pivot_longer(
    cols = starts_with("age"), 
    names_to = "age", 
    values_to = "result", 
    names_prefix = "age")

attach(dental_vert)
dental.aov <- aov(result ~ factor(gender)*factor(age) + Error(factor(id)))
summary(dental.aov)
detach(dental_vert)

