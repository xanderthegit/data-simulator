source('SimData.R')
library(jsonlite)

SimtoJson <- function(simdata, compendium, nodelinks, sorted_nodes, project_name, path) {
    # takes simulated data and creates json
    # Args:
    #   simdata:   Simulated values
    #   compendium:  initial values for nodes
    #   nodelinks:  table describing relationship betweeen nodes
    #   path:   output for files
    #
    # Returns:
    #   creates and saves of json files representing data simulated for each node
    
    for (i in sorted_nodes) {
        varlist <- compendium[['VARIABLE']][compendium[['NODE']]==i]
        sub <- simdata[, varlist, drop=FALSE]
        
        # Remove project_id
        if(length(grep("project_id", colnames(sub))) > 0){
            sub <- sub[-grep("project_id", colnames(sub))]
        }
        
        new_names <- names(sub)
        new_names <- gsub("\\..*", "", new_names)
        names(sub) <- new_names

        # Add type
        if(!("type" %in% colnames(sub))){
          sub <- cbind(sub, type=rep(i, nrow(simdata)))
        }
        else{
          sub$type <- rep(i, nrow(simdata))
        }

        # Add submitter_id
        submitter_id <- c()
        for (v in 1:nrow(simdata)){ 
            num <- paste0(i, "_00", v)
            submitter_id <- c(submitter_id, num)
        }
        
        if("submitter_id" %in% colnames(sub)){
            sub$submitter_id <- submitter_id
        }
        else{
            sub <- cbind(sub, submitter_id=submitter_id)
        }

        link_name <- as.character(nodelinks[['LINK_NAME']][nodelinks[['NODE']]==i])
        target <- nodelinks[['TARGET']][nodelinks[['NODE']]==i]
        multiplicity <- nodelinks[['MULTIPLICITY']][nodelinks[['NODE']]==i]

        #if (multiplicity == "many_to_one") {
        #    sub[[link_name]] <- toJSON(target_id, pretty=T, auto_unbox = T)
        #} else {
        #    sub[[link_name]] <- toJSON(target_id, pretty=T, auto_unbox = T)
        #}
        
        # Add links
        l <- c()
        for (v in 1:nrow(simdata)) {
            num <- paste0(target, "_00", v)
            l <- append(l, num)
        }
        
        finlist <- c()
        for (m in 1:nrow(sub)) {
            x <- as.list(sub[m,])
            for(ln in 1:length(link_name)){
                if(link_name[ln] == "projects"){
                   x[[link_name[ln]]] <- list(code=project_name)
                }
                else{
                   pos = (m-1)*length(link_name) + ln
                   x[[link_name[ln]]] <- list(submitter_id=l[pos])
                }
            }
            finlist <- append(finlist, list(x))
        }
        
        json <- toJSON(finlist, pretty=T, auto_unbox=T)
              
        filepath <- paste0(path, i, ".json")
        write(json, filepath)
    }

    # Write file descriptions
    node_descriptions <- list()
    for (i in seq_along(sorted_nodes)) {
      node_name <- sorted_nodes[i]
      this_node <- list()
      this_node$NODE <- unbox(node_name)
      this_node$ORDER <- unbox(i)
      this_node$TARGET <- as.character(nodelinks[['TARGET']][nodelinks[['NODE']]==node_name])
      this_node$CATEGORY <- unbox(as.character(unique(nodelinks[nodelinks[['NODE']]==node_name, 'CATEGORY'])))
      node_descriptions[[i]] <- this_node
    }
    fileDescr <- toJSON(node_descriptions, pretty=T)
    write(fileDescr, paste0(path, 'NodeDescriptions.json'))
}

## Example to run
#source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
#n <- 3
compendium <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical.csv',
                       header=T, stringsAsFactors = F)
#nodelinks <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical_Nodes.csv',
#                      header = T, stringsAsFactors = F)
#simdata <- simData(compendium, n, 
#                         include.na = FALSE, 
#                         reject= FALSE)

#SimtoJson(simdata, compendium, nodelinks, 'SampleJsonOutput/')
