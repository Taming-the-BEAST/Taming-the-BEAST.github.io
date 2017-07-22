# This function takes the path for data from the posterior and the empirical data set. It uses these data to perform clock and substitution model adequacy in one step. The information required includes: The trees log file path, parameters log file path, empirical sequence data file path, sequence length, assumed tree topology, number of PP simulations to take.


adeq <- function(trees.file, log.file, empdat.file, Nsim = 100){
     empdat <- as.phyDat(as.DNAbin(read.nexus.data(empdat.file)))
     seqlen <- ncol(as.matrix(as.DNAbin(empdat)))
     tree.topo <- read.nexus(trees.file)[[1]]
     sims <- make.pps.als(trees.file, log.file, Nsim, seqlen)
     sims <- make.pps.tr(sims[[1]], empdat, tree.topo, sims[[2]])
     results <- compile.results(sims)
     return(results)
}