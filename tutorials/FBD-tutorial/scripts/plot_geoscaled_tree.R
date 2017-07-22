library("phytools")
library("phyloch")
library("strap")
library("coda")

t <- read.beast("bearsDivtime_FBD.summary.tre")
t$root.time <- t$height[1]

log_data1 <- read.table("bearsDivtime_FBD.1.log",header=T)
log_data2 <- read.table("bearsDivtime_FBD.2.log",header=T)
nMCMC <- length(log_data1$originFBD)-1
burnin <- 0.2
id1 <- as.integer(nMCMC*burnin)+1
id2 <- nMCMC+1
comb_origin_data <- c(log_data1$originFBD[id1:id2],log_data2$originFBD[id1:id2])
origin_mcmc <-as.mcmc(comb_origin_data)
origin_time <- mean(origin_mcmc)
stem_length <- origin_time - t$root.time
origin_HPD <- HPDinterval(origin_mcmc)

num_taxa <- length(t$tip.label)

display_all_node_bars <- FALSE

names_list <-vector()
for (name in t$tip){
  v <- strsplit(name,"_")[[1]]
  if(display_all_node_bars){
  	names_list = c(names_list,name)
  }
  else if(v[length(v)]=="0"){
  	names_list = c(names_list,name)
  }
}

nids <- vector()
pos <- 1
len_nl <- length(names_list)
for(n in names_list){
  for(nn in names_list[pos:len_nl]){
    if(n != nn){
      m <- getMRCA(t,c(n,nn))
      if(m %in% nids == FALSE){
        nids <- c(nids,m)
      }
    }
  }
  pos<-pos+1
}

for(tp in 1:length(t$tip.label)){
  v <- strsplit(t$tip.label,"_")[[tp]]
  new_l <- v[1]
  if(length(v) > 2){
    new_l <- paste(v[1],v[2],sep="_")
  }
  if(tail(v,1) != "0"){
  	new_l <- paste(new_l, "X",sep=" ")
  }
  t$tip.label[tp] <- new_l
}

root_max <- t$"height_95%_HPD_MAX"[1]
x_max <- origin_HPD[2] * 0.1 + origin_HPD[2]

pdf("geoscaled_bears.pdf", width=10, height=7)
geoscalePhylo(tree=ladderize(t,right=FALSE), boxes="Age", cex.tip=1.2,cex.age=1,
				cex.ts=1,label.offset=0,x.lim=c(-15,x_max),lwd=1.5)

lastPP<-get("last_plot.phylo",envir=.PlotPhyloEnv)

origin_xx <- c(lastPP$xx[num_taxa+1],-stem_length)
lines(origin_xx,c(lastPP$yy[num_taxa+1],lastPP$yy[num_taxa+1]),lwd=1.5,col="black")
bar_xx_o <- c(t$root.time-origin_HPD[1], t$root.time-origin_HPD[2])
lines(bar_xx_o,c(lastPP$yy[num_taxa+1],lastPP$yy[num_taxa+1]),col=rgb(1,0,0,alpha=0.3),lwd=8)
points(-stem_length,lastPP$yy[num_taxa+1],pch=15,col="red",cex=1.5)

for(nv in nids){
  bar_xx_a <- c(lastPP$xx[nv]+t$height[nv-num_taxa]-t$"height_95%_HPD_MIN"[nv-num_taxa], lastPP$xx[nv]-(t$"height_95%_HPD_MAX"[nv-num_taxa]-t$height[nv-num_taxa]))
  lines(bar_xx_a,c(lastPP$yy[nv],lastPP$yy[nv]),col=rgb(0,0,1,alpha=0.3),lwd=8)
}

t$node.label<-t$posterior
p <- character(length(t$node.label))
p[t$node.label >= 0.95] <- "black"
p[t$node.label < 0.95 & t$node.label >= 0.75] <- "gray"
p[t$node.label < 0.75] <- "white"
nodelabels(pch=21, cex=1.5, bg=p)
dev.off()
