### Front Matter ####

# clean up environment
rm(list = ls())

# necessary packages
library(tidyverse)
library(data.table)
library(rio)  # rio::import( ) reads Excel directly from a URL
library(lubridate)
library(stringr)


### Bakken Data Intake ####
ptm <- Sys.time()

# month range for data of interest
BeginYearMonth <- "2020_01"
EndYearMonth <- "2020_12"

# generate URLs for monthly data sets
DataURLs <- 
  data.frame(yearMonth = seq(from = ym(BeginYearMonth), to = ym(EndYearMonth), by = "month")) %>%
  # `yearMonth` is in y-m-d form, so needs reformatting: fix hyphens and remove "day"
  mutate(yearMonth = gsub("-", "_", as.character(yearMonth)),  
         yearMonth = str_sub(yearMonth, end = -4L), 
         URL = paste0("https://www.dmr.nd.gov/oilgas/mpr/", yearMonth, ".xlsx"))

BakkenRaw <- NULL 

# takes about 2 mins for 2019-2021
for (i in 1:nrow(DataURLs)) {

  Tmp <- 
    rio::import(file = DataURLs$URL[i]) %>%
    mutate(date = ym(DataURLs$yearMonth[i]),
           # data intake adjustments
           Section = as.character(Section),
           Township = as.character(Township),
           Range = as.character(Range))
  
  BakkenRaw <- bind_rows(BakkenRaw, Tmp)
  
}


### Marcellus Data Intake ####
MarcellusRaw <- fread("PA-2020-OilGasProduction.csv")

### Save complete raw data ####
# save(BakkenRaw, file = "BakkenRaw.Rda")

Sys.time() - ptm


