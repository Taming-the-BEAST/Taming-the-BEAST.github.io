# This function computes the multinomial likelihood test statistic as proposed by Bollback (2002).

require(phangorn)

multlik <- function(al){

	if(class(al) != "DNAbin"){ al <- as.list(as.DNAbin(al)) } else { al <- as.list(al) }
	mat <- as.character(as.list(as.matrix(al))[[1]])
	for(i in 2:length(as.list(al))){
	      mat <- rbind(mat, as.character(as.list(as.matrix(al))[[i]]))
	}
	al <- mat
	nsites <- ncol(al)
	al_patterns <- table(sapply(1:nsites, function(x) paste(al[, x], collapse = '')))
	lik <- sum(sapply(al_patterns, function(x) (log(x) * x))) - (nsites*log(nsites))

	return(lik)
}
