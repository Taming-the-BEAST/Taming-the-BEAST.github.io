# This function takes the results of any given run and returns the posterior predictive results for clock and substitution models.

require(phangorn)

compile.results <- function(branch.results){
	
	bls <- branch.results
	pvals <- vector()
	for(i in 1:length(bls[[1]])){
	      pvals[i] <- length(bls[[2]][,i][which(bls[[2]][,i] < bls[[1]][i])]) / nrow(bls[[2]])
	}
	fullpval <- 1 - (length(pvals[which(pvals < 0.025 | pvals > 0.975)]) / length(pvals))
	resmag <- abs((bls[[1]] - apply(bls[[2]], 2, mean)) / bls[[1]])
	medresmag <- median(resmag)
	
	meandifran1 <- mean(sapply(1:ncol(bls[[2]]), function(x) diff(range(bls[[2]][,x])) / mean(bls[[2]][,x])))
	meandifran2 <- mean(sapply(1:ncol(bls[[2]]), function(x) diff(quantile(bls[[2]][,x], prob = c(0.05, 0.95))) / mean(bls[[2]][,x])))
	mlik_pvalue <- length(bls[[4]][which(bls[[4]] > bls[[3]])]) / length(bls[[4]])
	
	allres <- list(empirical_branch_lengths = bls[[1]], pp_branch_lengths = bls[[2]], branch_wise_pppvalues = pvals, A_index = fullpval, branch_length_deviation = resmag, median_deviation = medresmag, empirical_multlik = bls[[3]], pps_multliks = bls[[4]], mlik_pvalue = mlik_pvalue, pps_blen_range = meandifran1, pps_blen_range_CI = meandifran2)
	return(allres)

}