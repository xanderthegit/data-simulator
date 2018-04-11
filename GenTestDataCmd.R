#source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimCompendium.R')
setwd('./')
source('SimCompendium.R')
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)
repo <- args[1]
branch <- args[2]
n <- as.integer(args[3])
required_only <- as.logical(args[4])
output_to_json <- as.logical(args[5])
dir <- args[6]
rm(args)
print(output_to_json)

finalSim <- simFromDictionary(repo, branch, required_only, n, output_to_json, dir)

#Rscript GenTestDataCmd.R https://github.com/occ-data/bpadictionary develop 4 FALSE TRUE SampleJsonOutput