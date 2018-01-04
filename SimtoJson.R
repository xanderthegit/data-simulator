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
        
        if (multiplicity == "many_to_one") {
            lt <- paste0("submitter_id : ", target, "_00N")
            sub[[link_name]] <- I(list(lt))
        } else {
            sub[[link_name]] <- paste0('submitter_id : ' , target, "_00N")
        }
                     
        
        #l <- apply(sub, 1, as.vector)
        
        #l <- split(sub, seq(nrow(sub)))
        #l <- unname(l)
        #for (i in seq_along(l))     # add element from ch to list
        #    l[[i]] <- c(l[[i]], link_name=list("submitter_id", paste0(target, "_00N")))
    
        #json <- toJSON(l, pretty=T, auto_unbox = T)
        
        json <- toJSON(sub, pretty=T, auto_unbox=T)
       
        filepath <- paste0(path, i, ".json")
        write(json, filepath)
    }
}

n <- 5
compendium <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical.csv',
                       header=T, stringsAsFactors = F)
nodelinks <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical_Nodes.csv',
                      header = T, stringsAsFactors = F)
simdata <- simData(compendium, n, 
                         include.na = FALSE, 
                         reject= FALSE)

SimtoJson(simdata, compendium, nodelinks, 'JsonOutput/')
