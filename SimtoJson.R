source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
library(jsonlite)

SimtoJson <- function(simdata, compendium, path) {
    # takes simulated data and creates json
    # Args:
    #   simdata:   Simulated values
    #   compendium:  initial values for nodes
    #   path:   output for files
    #
    # Returns:
    #   creates and saves of json files representing data simulated for each node
    
    nodes <- unique(compendium[['NODE']])
    
    for (i in nodes) {
        varlist <- compendium[['VARIABLE']][compendium[['NODE']]==i]
        sub <- simdata[, varlist]
        filepath <- paste0(path, i, ".json")
        json <- toJSON(sub, pretty=T)
        write(json, filepath)
    }
}
