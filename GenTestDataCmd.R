#source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimCompendium.R')
setwd('./')
source('SimCompendium.R')
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)
repo <- args[1]
branch <- args[2]
project <- args[3]
n <- as.integer(args[4])
dir <- args[5]
rm(args)

finalSim <- simFromDictionary(repo, branch, project, FALSE, n, TRUE, dir)

#Rscript GenTestDataCmd.R https://github.com/occ-data/bpadictionary develop test 4 SampleJsonOutput
