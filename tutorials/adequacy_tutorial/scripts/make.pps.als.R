# This function takes posterior log and trees files. It first simulates rates thorugh each of the posterior trees and then alignments using the model parameters from the corresponding line in the log file. This function also requires the length of the alignment.

make.pps.als <- function(trees.file, log.file, N = 100, l = 1000){
	
	trees <- read.nexus(trees.file)
	logdat <- read.table(log.file, header = T, comment = "#")
	samp <- sample(1:length(trees), N)
	trees <- trees[samp]
	logdat <- logdat[samp,]
	sim <- list()
	if("ucldMean" %in% colnames(logdat) | "meanClockRate" %in% colnames(logdat)){
	      ratogs <- getRatogs(trees.file)[samp]
	}
	for(i in 1:nrow(logdat)){
	      tr <- trees[[i]]
	      if("clockRate" %in% colnames(logdat)){
	      	     tr$edge.length <- tr$edge.length * logdat[i, "clockRate"]
		     sim[[i]] <- list(phylogram = tr)
	      } else if("ucldMean" %in% colnames(logdat) | "meanClockRate" %in% colnames(logdat)){
	      	     trr <- ratogs[[i]]
		     trr$edge.length <- trr$edge.length * tr$edge.length
	      	     sim[[i]] <- list(phylogram = trr)
	      }
	      print(sim)
	      
	      if(all(c("rateAC", "rateAG", "rateAT", "rateCG", "rateGT") %in% colnames(logdat))){
	      	     # GENERAL TIME REVERSIBLE (GTR)
		     #print("The substitution model is GTR")
		     basef <- c(logdat$freqParameter.1[i], logdat$freqParameter.2[i], logdat$freqParameter.3[i], logdat$freqParameter.4[i])
		     qmat <- c(logdat$rateAC[i], logdat$rateAG[i], logdat$rateAT[i], logdat$rateCG[i], 1, logdat$rateGT[i])
		     print(basef)
		     print(qmat)

		     if("gammaShape" %in% colnames(logdat)){
		     	   substmod <- "GTR+G"
		     	   rates = phangorn:::discrete.gamma(logdat$gammaShape[i], k = 4)
        		   sim_dat_all<- lapply(rates, function(r) simSeq(sim[[i]][[1]], l = round(l/4, 0), Q = qmat, bf = basef, rate = r))
        		   sim[[i]][[3]] <- c(sim_dat_all[[1]], sim_dat_all[[2]], sim_dat_all[[3]], sim_dat_all[[4]])
		     } else {
		       	   substmod <- "GTR"
	      	       	   sim[[i]][[3]] <- simSeq(sim[[i]][[1]], Q = qmat, bf = basef, l = l)
		     }		     
		     
	      } else if("kappa" %in% colnames(logdat)){
		     # HASEGAWA-KISHINO-YANO (HKY)
		     #print("The substitution model is HKY")
		     basef <- c(logdat$freqParameter.1[i], logdat$freqParameter.2[i], logdat$freqParameter.3[i], logdat$freqParameter.4[i])
		     qmat <- c(1, 2*logdat$kappa[i], 1, 1, 2*logdat$kappa[i], 1)

		     if("gammaShape" %in% colnames(logdat)){
		     	   substmod <- "HKY+G"
		     	   rates = phangorn:::discrete.gamma(logdat$gammaShape[i], k = 4)
       			   sim_dat_all<- lapply(rates, function(r) simSeq(sim[[i]][[1]], l = round(l/4, 0), Q = qmat, bf = basef, rate = r))
                           sim[[i]][[3]] <- c(sim_dat_all[[1]], sim_dat_all[[2]], sim_dat_all[[3]], sim_dat_all[[4]])
		     } else {
		       	   substmod <- "HKY"
                           sim[[i]][[3]] <- simSeq(sim[[i]][[1]], Q = qmat, bf = basef, l = l)
	       	     }
		     
	      } else { 
	      	     # JUKES-CANTOR (JC)
		     #print("The substitution model is assumed to be JC")
		     substmod <- "JC"
	      	     sim[[i]][[3]] <- simSeq(sim[[i]][[1]], l = l)
	      }

	}
	sims <- list(sim, substmod)
	return(sims)
}