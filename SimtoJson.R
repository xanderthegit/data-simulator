source('SimData.R')
library(jsonlite)

SimtoJson <- function(simdata, compendium, nodelinks, project_name, path) {
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
    
    # Sort nodes
    sorted_nodes <- c("project")
    for (i in nodes) {
        target <- as.character(nodelinks[['TARGET']][nodelinks[['NODE']]==i])
        sorted_nodes <- getOrder(target, i, nodes, sorted_nodes, nodelinks)
    }   
    sorted_nodes <- sorted_nodes[-1]
    
    
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
    
    # Write importing order
    fileOrder <- paste(sorted_nodes, ".json", sep="")
    write(fileOrder, paste0(path, 'DataImportOrder.txt'))
    
    # Write file descriptions
    for (i in seq_along(sorted_nodes)) {
      nodelinks[nodelinks$NODE==sorted_nodes[i], 'ORDER'] <- i
    }
    fileDescr <- toJSON(nodelinks[!duplicated(nodelinks[,'NODE']),], pretty=T, auto_unbox=T)
    write(fileDescr, paste0(path, 'NodeDescriptions.json'))
}

getOrder <- function(links, node, nodes, sorted_nodes, nodelinks) {

    for (link in links){
      if (!(link %in% sorted_nodes)){
        target <- as.character(nodelinks[['TARGET']][nodelinks[['NODE']]==link])
        sorted_nodes <- getOrder(target, link, nodes, sorted_nodes, nodelinks)
      }
      if (!(node %in% sorted_nodes)){
         sorted_nodes <- c(sorted_nodes, node)
      }
    }
    return(sorted_nodes)
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
