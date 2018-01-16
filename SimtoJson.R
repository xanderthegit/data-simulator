source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
library(jsonlite)

SimtoJson <- function(simdata, compendium, nodelinks, path) {
    # takes simulated data and creates json
    # Args:
    #   simdata:   Simulated values
    #   compendium:  initial values for nodes
    #   nodelinks:  table describing relationship betweeen nodes
    #   path:   output for files
    #
    # Returns:
    #   creates and saves of json files representing data simulated for each node
    
    nodes <- unique(compendium[['NODE']])
    
    for (i in nodes) {
        varlist <- compendium[['VARIABLE']][compendium[['NODE']]==i]
        sub <- simdata[, varlist, drop=FALSE]
        sub <- cbind(sub, 
                     type=rep(i, nrow(simdata)))
        
        submitter_id <- c()
        for (v in 1:nrow(simdata)){ 
            num <- paste0(i, "_00", v)
            submitter_id <- c(submitter_id, num)
        }
        sub <- cbind(sub,
                     submitter_id=submitter_id)
        
        link_name <- nodelinks[['LINK_NAME']][nodelinks[['NODE']]==i]
        target <- nodelinks[['TARGET']][nodelinks[['NODE']]==i]
        multiplicity <- nodelinks[['MULTIPLICITY']][nodelinks[['NODE']]==i]
        
        #if (multiplicity == "many_to_one") {
        #    sub[[link_name]] <- toJSON(target_id, pretty=T, auto_unbox = T)
        #} else {
        #    sub[[link_name]] <- toJSON(target_id, pretty=T, auto_unbox = T)
        #}
        
        l <- c()
        for (v in 1:nrow(simdata)) {
            num <- paste0(target, "_00", v)
            l <- append(l, num)
        }
        
        finlist <- c()
        for (m in 1:nrow(sub)) {
            x <- as.list(sub[m,])
            x[[link_name]] <- list(submitter_id=l[m])
            finlist <- append(finlist, list(x))
        }
        
        json <- toJSON(finlist, pretty=T, auto_unbox=T)
       
        filepath <- paste0(path, i, ".json")
        write(json, filepath)
    }
}

## Example to run
#source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
#n <- 3
#compendium <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical.csv',
#                       header=T, stringsAsFactors = F)
#nodelinks <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical_Nodes.csv',
#                      header = T, stringsAsFactors = F)
#simdata <- simData(compendium, n, 
#                         include.na = FALSE, 
#                         reject= FALSE)

#SimtoJson(simdata, compendium, nodelinks, 'JsonOutput/')
