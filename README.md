# data-simulator
Used to generate datasets based on variable statistics

# Motivation

It is sometimes necessary to create simulated data when it is impractical to obtain real data. This is an important technique to generate data that can be used for building models or running services over datasets that may have protected information or may not be available for legal reasons.  The functions in this simulation suite allow a user to:

* Create a compendium of variables to simulate based on the desired statistical properties
* Simulate and validate data
* Organize simulated data by nodes in a data model and export to json for easy upload.

For more information, review the sample notebooks: 

* https://wwells.github.io/CUNY_DATA_604/FinalProject/SimulatingData.html
* https://occ-data.github.io/data-simulator/SampleNotebook/SimulatingData.html

## Basics of Simulation

### What is the Compendium?

In order to simulate a dataset, a compendium must be filled out.   The compendium can be prepared as a spreadsheet outside of R and then loaded to complete the simulation. 
Compendium fields are as follows:

* __DESCRIPTION__ describes the variable
* __NODE__ we use a graphing representation of data to build out a data commons.   A node represents where the simulated data will sit in a the data model.  A sample model can be found at: https://www.bloodpac.org/data-group/
* __VARIABLE__ the name of the variable
* __REQUIRED__ boolean representing whether this will be a required value in the data model
* __TYPE__  options: enum, boolean, number, integer.   This field dictates the logic in the following fields.  
* __CHOICES__  If enum, this represents the enum options
* __PROBS__  If enum or boolean this represents the probabilites for each option.   If boolean, the first probability represents `TRUE`
* __DISTRIB__ If number or integer, this field represents the distribution that best represents the data. 
    * If Number - options = normal, uniform, exponential
    * If Integer - options = normal, uniform, poisson
* __DISTRIB.INPUTS__  If number or integer, this field represents the distribution inputs (eg, mean, sd, lambda, etc)
* __NAS__ proportion of the variable that should be NA.
* __POSITIVEONLY__ If an integer, make sure any values < 0 end up as 0, not negative numbers.

The fields can be grouped into three classes:

* Metadata: DESCRIPTION, VARIABLE
* Data Model: NODE, REQUIRED
* Statistical Properties: TYPE, CHOICES, PROBS, DISTRIB, DISTRIB.INPUTS, NAS

Sample compendiums are available at: https://github.com/occ-data/data-simulator/tree/master/SampleCompendium

### Example Simulation

The following will simulate 10 rows from our sample compendium. 

```
source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
compendium <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical.csv', header=T, stringsAsFactors = F)

n <- 10 #create 10 rows
SimulatedData <- simData(compendium, n, 
                         include.na = FALSE, 
                         reject= FALSE)
```

## Validation

### How Does Validation Work?

When running a simulation there is an option to resimulate a variable if it does not match the desired distribution closely enough.  This is generally done by comparing the simulated distribution to the theoretical distribution using:  

* Chi Square tests (`TYPE` == enum)
* Binomial tests (`TYPE` == boolean)
* Kolmogorov-Smirnov tests (`TYPE` == number)

For lack of an alternative metric that is consistent across tests, the p-value is used as the benchmark output when running a validation test. 

Similar to the functions in SimData.R, it would be relatively simple to expand support for additional distributions or custom functions should a dataset require them. 

There are a few available methods for utilizing the functions in ValidationFunction.R. At a very high level:

* After a completed simulation: Plot the simulated vs. the theoretical, show the p-value, and display a “reject” flag if the p-value is below an input threshold.
* During a simulation: Run the validation steps without plotting, and if the p-value is less than an input threshold, reject the simulated variable and resim until the test is passed.

NOTE:   It is not recommended to use the `reject` flag with a small n value.   

### Example of Validation with Plotting

```
source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
compendium <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical.csv', header=T, stringsAsFactors = F)

SimulatedData <- simData(compendium, n, 
                         include.na = FALSE, 
                         reject = TRUE, 
                         threshold = .6) # set a very high p-value threshold

variables <- compendium$VARIABLE

par(mfrow = c(2, 3))
for (i in variables) {
    validateVar(i, compendium, SimulatedData, include.plot=T)
}
```

## Sim to Json

An additional use case for data simulation is to validate the data dictionaries that power a data commons. The SimtoJson.R function takes a simulated dataset and converts it to .json to easily ingest into a data commons. 

To easily add simulated entries into a data commons, use the function in SimtoJson.R.   Once satisfactory data is simulated, the SimtoJson function will group by nodes in the data model (a column in the compendium) and create json output for easy import.  It relies on a separate table indicating the relationship between the nodes (see `nodelinks` in the example below).

```
source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimtoJson.R')
source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimData.R')
compendium <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical.csv', header=T, stringsAsFactors = F)
nodelinks <- read.csv('https://raw.githubusercontent.com/occ-data/data-simulator/master/SampleCompendium/sampleClinical_Nodes.csv', header = T, stringsAsFactors = F)

n <- 5
simdata <- simData(compendium, n, 
                         include.na = FALSE, 
                         reject= FALSE)

SimtoJson(simdata, compendium, nodelinks, 'JsonOutput/')
```

Sample simulated data resulting from this function call can be found at: https://github.com/occ-data/data-simulator/tree/master/SampleJsonOutput

## Sim from Dictionary

A use case for the simulation is to run a simulation to stress validate a dictionary or stress test the data commons software stack with records.   In this instance, we have a function to ingest a repo of .yaml files and create a dummy simulation to import into a data commons. 

To run an example, point the function at a dictionary repo and a branch. 

```
source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimCompendium.R')
repo <- 'https://github.com/occ-data/bpadictionary'
branch <- 'develop'
n <- 1
project_name <- 'test'
dir <- 'SampleFullDictionaryJsonOutput/'
finalSim <- simFromDictionary(repo, branch, project_name, required_only=F, n, output_to_json=T, dir)
```

Alternatively, the dictionary simulation can be generated from JSON schemas already processed and stored in S3 from YAML.

```
source('https://raw.githubusercontent.com/occ-data/data-simulator/master/SimCompendiumJson.R')
dictionary <- 'https://s3.amazonaws.com/dictionary-artifacts/bpadictionary'
branch <- 'develop'
n <- 1
project_name <- 'test'
dir <- 'SampleFullDictionaryJsonOutput/'
finalSim <- simFromDictionary(dictionary, branch, project_name, required_only=F, n, output_to_json=T, dir)
```

Sample simulated data resulting from this function call can be found at: https://github.com/occ-data/data-simulator/tree/master/SampleFullDictionaryJsonOutput


