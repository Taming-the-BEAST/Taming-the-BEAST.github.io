# This function processes simulated datasets created with the function make.pps.als. It takes the posterior phylograms and simulated alignments. The function creates the posterior predictive simulated distribution of phylograms. this function also requires the empirical dataset and the assumed topology.

make.pps.tr <- function(sims, empdat, topo, model = "JC"){
	 topo$edge.length <- rep(1, length(topo$edge.length))
	 if(model == "JC"){
	 	 emphy <- optim.pml(pml(topo, empdat))
	 } else if(model == "GTR+G"){
	   	 emphy <- optim.pml(pml(topo, empdat, k = 4), optBf=FALSE, optQ=FALSE, optGamma = T)
	 } else if(model == "GTR"){
	   	 emphy <- optim.pml(pml(topo, empdat), optBf=FALSE, optQ=FALSE)
	 }
	 empmlik <- multlik(empdat)
	 empbl <- emphy$tree$edge.length
	 simbl <- emphy$tree$edge.length
	 simultlik <- vector()
	 for(i in 1:length(sims)){
	       if(model == "JC"){
	       		ppsphy <- optim.pml(pml(topo, sims[[i]][[3]]))
	       } else if(model == "GTR+G"){
	       	        ppsphy <- optim.pml(pml(topo, sims[[i]][[3]], k = 4), optBf=FALSE, optQ=FALSE, optGamma = T)
	       } else if(model == "GTR"){
			ppsphy <- optim.pml(pml(topo, sims[[i]][[3]]), optBf=FALSE, optQ=FALSE)
       	       }
	       simbl <- rbind(simbl, ppsphy$tree$edge.length)
	       simultlik[i] <- multlik(sims[[i]][[3]])
	       print(paste("Simulation", i, "processed"))
	 }
	 simbl <- simbl[2:nrow(simbl),]
	 print(model)
	 return(list(empbl, simbl, empmlik, simultlik))

}