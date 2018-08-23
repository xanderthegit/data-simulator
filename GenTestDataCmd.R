#source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimCompendium.R')
library(jsonlite)
library(stringr)
library(stringi)
print("Finish import dependencies")
setwd('./')
source('SimCompendiumJson.R')
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)
repo <- args[1]
project <- args[2]
n_max <- as.integer(args[3])
dir <- args[4]
rm(args)

finalSim <- simFromDictionary(repo, project, FALSE, n_max, TRUE, dir)
#Rscript GenTestDataCmd.R https://s3.amazonaws.com/dictionary-artifacts/genomel-dictionary/master/schema.json test 4 ~/sampleJsonOutput/
#Rscript GenTestDataCmd.R https://s3.amazonaws.com/dictionary-artifacts/bpadictionary/develop/schema.json test 4 ~/sampleJsonOutput
#Rscript GenTestDataCmd.R https://s3.amazonaws.com/dictionary-artifacts/kf-dictionary/1.0.0/schema.json test 4 ~/sampleJsonOutput/
#Rscript GenTestDataCmd.R https://s3.amazonaws.com/dictionary-artifacts/ndhdictionary/master/schema.json test 100 ~/sampleJsonOutput/
#Rscript GenTestDataCmd.R https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json test 100 ~/sampleJsonOutput/
