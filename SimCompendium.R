
if(!require(yaml)) install.packages(yaml)
if(!require(httr)) install.packages(httr)

## PROJECT OUTLINE
# 1:  go through repo, get raw urls associated with each node
# 2:  go through each node and extract the details matching with 
##      compendium and link dfs required for submission
# 3:  for compendium, create functions that create random stats 
##      properties for each variable type
# 4:  given compendium and links, sim.
# optional:  flag for required, flag to create multiple 
##    entries on lower level nodes


#https://stackoverflow.com/questions/25485216/how-to-get-list-files-from-a-github-repository-folder-using-r


# Helper  
readDictionary <- function(repo, branch) {
    # given github repo, get list of links for each dictionary yaml
    #
    # Args:
    #   repo: top level URL for repo, eg: 'https://github.com/occ-data/bpadictionary'
    #   branch: branch name to use for desired dictionary
    #
    # Returns:
    #   dictionary_nodes:  R object with two lists: 
    #      nodelist: location for all yaml representing dictionary nodes
    #      alt_yaml:  location for all yaml representing persistent definitions, settings and terms
    
    root <- gsub('https://github.com', '', repo)
    api_call <- paste0('https://api.github.com/repos', root, '/git/trees/', branch, '?recursive=1')
    
    directory <- GET(api_call)
    stop_for_status(directory)
    filelist <- unlist(lapply(content(directory)$tree, "[", "path"), use.names = F)
    filelist <- grep("/schemas/", filelist, value = TRUE, fixed = TRUE)
    filelist <- grep(".yaml", filelist, value = TRUE, fixed = TRUE)
    
    altdefs <- grep("/_", filelist, value = TRUE, fixed = TRUE)
    nodelist <- filelist[!filelist %in% altdefs]
    
    dictionary_nodes <- list(nodelist = nodelist,
                             alt_yaml = altdefs)
    return(dictionary_nodes)

}

## Run Example: 
repo <- 'https://github.com/occ-data/bpadictionary'
branch <- 'develop'
dictionary_node_list <- readDictionary(repo, branch)


## Create Node_Compendium and Compendium from Dictionary

node_relationships <- data.frame() # initialize empty df
compendium <- data.frame(DESCRIPTION = character(),
                         NODE = character(),
                         VARIABLE = character(),
                         REQUIRED = logical(), 
                         TYPE = character(),
                         CHOICES = character(), 
                         TEMPCHOICES = numeric())
node <- yaml.load_file('https://raw.githubusercontent.com/occ-data/bpadictionary/develop/gdcdictionary/schemas/aliquot.yaml')

## _nodes df
links_list <- list(NODE = node$id,
                   TITLE = node$title,
                   CATEGORY = node$category,
                   DESCRIPTION = node$description,
                   LINK_NAME = node$links[[1]]$name,
                   BACKREF = node$links[[1]]$backref,
                   LABEL = node$links[[1]]$label,
                   TARGET = node$links[[1]]$target_type,
                   MULTIPLICITY = node$links[[1]]$multiplicity, 
                   LINK_REQUIRED = node$links[[1]]$required)

node_relationships <- rbind(node_relationships, links_list)

## compendium df
#model after : https://github.com/occ-data/data-simulator/blob/master/SampleCompendium/sampleClinical.csv
NODE <- node$id

# need to extract description, variable, required, type, and choices from below info
fields <- node$properties
linkback <- node$links[[1]]$name
fieldnames <- names(fields)[-1] #don't include $ref
fieldnames <- fieldnames[!fieldnames %in% linkback]
ref <- fields$`$ref`
required <- node$required

for (f in fieldnames) {
    
    if ('description' %in% names(fields[[f]])) {
        DESCRIPTION = fields[[f]]$description
    } else {
        DESCRIPTION = paste0("See : ", fields[[f]]$term$`$ref`)
    }
    
    if ('enum' %in% names(fields[[f]])) {
        TYPE <- 'enum'
        elements <- fields[[f]]$enum
        CHOICES <- paste(elements, collapse='|')
        TEMPCHOICES <- length(elements)
    } else {
        TYPE <- fields[[f]]$type[1]
        CHOICES <- ''
        TEMPCHOICES <- 0
    }
    
    if (f %in% required) {
        REQUIRED <- TRUE
    } else {
        REQUIRED <- FALSE
    }
    
    var_list <- data.frame(
        DESCRIPTION = DESCRIPTION,
        NODE = NODE,
        VARIABLE = f,
        REQUIRED = REQUIRED,
        TYPE = TYPE,
        CHOICES = CHOICES,
        TEMPCHOICES = TEMPCHOICES
    )
    compendium <- rbind(compendium, var_list)
}



