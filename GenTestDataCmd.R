source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimCompendium.R')
#setwd('./')
#source('SimCompendium.R')
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)
repo <- args[1]
branch <- args[2]
project <- args[3]
n <- as.integer(args[4])
required_only <- as.logical(args[5])
output_to_json <- as.logical(args[6])
dir <- args[7]
rm(args)
print(output_to_json)

finalSim <- simFromDictionary(repo, branch, project, required_only, n, output_to_json, dir)

#Rscript GenTestDataCmd.R https://github.com/occ-data/bpadictionary develop test 4 FALSE TRUE SampleJsonOutput