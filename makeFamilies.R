makeFamilies <- function(nFamilies, averageSize) {
  require(simstudy)
  gen.family <- defData(varname = "size", dist = "noZeroPoisson", 
                        formula = averageSize, id = "idFam")
  dtFam <- genData(nFamilies, gen.family)
  gen.Indiv <- defDataAdd(varname = "c0", dist = "normal", formula = 0, variance = 2)
  dtIndiv <- genCluster(dtFam, "idFam", numIndsVar = "size", level1ID = "idInd")
  dtIndiv <- addColumns(gen.Indiv, dtIndiv)
  return(dtIndiv)
}