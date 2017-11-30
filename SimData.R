library(stringr)

## Helper for handling numeric / integer distributions in compendium
distPrep <- function(row, n=0, full.output=FALSE) {
    # reviews strings associated with distr for a variable and prepares for use
    #
    # Args: 
    #   row:  row in compendium representing a variable
    #   n:   number of times to sim var
    # 
    # Returns:
    #   val:  list of simulated inputs based on distribution type
    str <- row[['DISTRIB.INPUTS']]
    if (row[['DISTRIB']] == "normal") {
        str <- row[['DISTRIB.INPUTS']]
        mean <- as.numeric(str_extract(str_extract(str, "(mean = )[0-9]*"), "([0-9]+)"))
        sd <- as.numeric(str_extract(str_extract(str, "(sd = )[0-9]*"), "([0-9]+)"))
        full <- list(mean=mean, sd=sd)
        val <- rnorm(n, mean, sd)
    } else if (row[['DISTRIB']] == "poisson") {
        lambda <- as.numeric(str_extract(str_extract(str, "(lambda = )[0-9]*"), "([0-9]+)"))
        full <- list(lambda=lambda)
        val <- rpois(n, lambda)
    } else if (row[['DISTRIB']] == "uniform") {
        min <- as.numeric(str_extract(str_extract(str, "(min = )[0-9]*"), "([0-9]+)"))
        max <- as.numeric(str_extract(str_extract(str, "(max = )[0-9]*"), "([0-9]+)"))
        full <- list(min=min, max=max)
        if (row[['TYPE']] == "number") {
            val <- runif(n, min, max)
        } else {
            val <- sample(min:max, n, replace=T)
        }
    } else if (row[['DISTRIB']] == "exponential") {
        rate <- as.numeric(str_extract(str_extract(str, "(rate = )[0-9]*"), "([0-9]+)"))
        full <- list(rate=rate)
        val <- rexp(n, rate)
    }
    
    if (full.output) {
        return(full)
    } else { return(val) }
}

convertToList <- function(l) {
    # quick helper to handle lists for categorical vars
    as.list(strsplit(l, '\\|')[[1]])
}

## Helper to choose correct simulation method for a var
simVar <- function(row, n) {
    # reviews row, selects and implements a method for simulating variable
    #
    # Args: 
    #   row:  row in compendium representing a variable
    #   n:   number of times to sim var
    # 
    # Returns:
    #   val:  list of simulated inputs based on distribution type
    if (row[['TYPE']] == "enum") {
        val <- unlist(sample(convertToList(row[['CHOICES']]), 
                             n, T, as.numeric(convertToList(row[['PROBS']]))))
    } else if (row[['TYPE']] == "boolean"){
        val <- unlist(sample(c(TRUE, FALSE), 
                             n, T, as.numeric(convertToList(row[['PROBS']]))))
    } else if (row[['TYPE']] == "number"){
        val <- distPrep(row, n)
    } else if (row[['TYPE']] == "integer"){
        val <- round(distPrep(row, n), 0)
    } else {
        val <- rep("Something Went Wrong", n)
    }
    names <- c("id", row[["VARIABLE"]])
    id <- c(1:n)
    df <- data.frame(id, val)
    names(df) <- names
    df
}

simData <- function(compendium, n) {
    # helper that runs simulation for each row in variable compendium
    #
    # Args: 
    #   row:  dictionary representing variables to simulate and methods to use
    #   n:   number of observations to simulate
    # 
    # Returns:
    #   df:   a simulated dataset
    for (i in 1:nrow(compendium)) {
        if (i==1) {
            df <- simVar(compendium[i,], n)
        } else {
            var <- simVar(compendium[i,], n)
            df <- merge(df, var, by="id")
        }
    }
    df
}
