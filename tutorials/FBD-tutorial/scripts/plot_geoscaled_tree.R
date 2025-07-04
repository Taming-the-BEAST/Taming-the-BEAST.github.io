library("phytools")
library("treeio")
library("strap")
library("coda")

# change below to CCD0
# to plot for CCD0 tree
summary_method <- "MCC"
t <- read.beast(paste0("../precooked_runs/bearsTree_ext.",summary_method,"_summary.tree"))
t@phylo$root.time <- t@data$height[length(t@data$height)]

log_data1 <- read.table("../precooked_runs/bearsDivtime_FBD.1.log",header=T)
log_data2 <- read.table("../precooked_runs/bearsDivtime_FBD.2.log",header=T)
nMCMC <- length(log_data1$originFBD)-1
burnin <- 0.2
id1 <- as.integer(nMCMC*burnin)+1
id2 <- nMCMC+1
comb_origin_data <- c(log_data1$originFBD[id1:id2],log_data2$originFBD[id1:id2])
origin_mcmc <-as.mcmc(comb_origin_data)
origin_time <- mean(origin_mcmc)
stem_length <- origin_time - t@phylo$root.time
origin_HPD <- HPDinterval(origin_mcmc)

num_taxa <- length(t@phylo$tip.label)

display_all_node_bars <- T

for(tp in 1:length(t@phylo$tip.label)){
  v <- strsplit(t@phylo$tip.label,"_")[[tp]]
  new_l <- v[1]
  if(length(v) > 2){
    new_l <- paste(v[1],v[2],sep="_")
  }
  if(tail(v,1) != "0"){
  	new_l <- paste(new_l, "X",sep=" ")
  }
  t@phylo$tip.label[tp] <- new_l
}

root_max <- t@data$height_0.95_HPD[length(t@data$height)][[1]][2]
x_max <- origin_HPD[2] * 0.1 + origin_HPD[2]

pdf(paste0("geoscaled_bears_",summary_method,".pdf"), width=10, height=7)
geoscalePhylo(tree=ladderize(t@phylo,right=FALSE), boxes="Age", cex.tip=1.2,cex.age=1,
				cex.ts=1,label.offset=0,x.lim=c(-15,x_max),lwd=1.5)

lastPP<-get("last_plot.phylo",envir=.PlotPhyloEnv)

origin_xx <- c(lastPP$xx[num_taxa+1],-stem_length)
lines(origin_xx,c(lastPP$yy[num_taxa+1],lastPP$yy[num_taxa+1]),lwd=1.5,col="black")
bar_xx_o <- c(t@phylo$root.time-origin_HPD[1], t@phylo$root.time-origin_HPD[2])
lines(bar_xx_o,c(lastPP$yy[num_taxa+1],lastPP$yy[num_taxa+1]),col=rgb(1,0,0,alpha=0.3),lwd=8)
points(-stem_length,lastPP$yy[num_taxa+1],pch=15,col="red",cex=1.5)

## build a simple list of *all* internal nodes
num_taxa <- length(t@phylo$tip.label)
nids     <- (num_taxa + 1):(num_taxa + t@phylo$Nnode)

for (nv in nids) {
  ## 1. find which row of t@data corresponds to this node
  row_id <- which(t@data$node == nv)
  if (length(row_id) != 1) next     # skip if something’s funny
  
  ## 2. grab the two height‐HPD bounds (a length‐2 numeric vector)
  hpdi <- t@data$height_0.95_HPD[[ row_id ]]  
  #    hpdi[1] = lower bound height (close to present)
  #    hpdi[2] = upper bound height (further in the past)
  
  ## 3. convert to “time before present” coordinates
  ##    exactly as you did for the root:
  times_bp <- t@phylo$root.time - hpdi
  x_coords <- sort(times_bp)         # ensures left→right ordering
  
  ## 4. draw a thick, semi‐transparent blue bar
  y_coord <- lastPP$yy[nv]
  lines(
    x_coords,
    rep(y_coord, 2),
    col = rgb(0, 0, 1, alpha = 0.3),
    lwd = 8
  )
}

# 1) define the internal node numbers
num_tips  <- length(t@phylo$tip.label)
node_nums <- (num_tips + 1):(num_tips + t@phylo$Nnode)

# 2) match those to the rows in t@data
row_ids    <- match(node_nums, t@data$node)
post_vals  <- t@data$posterior[row_ids]

# 3) decide fill colours by posterior
#    ≥0.95 → black; [0.75,0.95) → gray; <0.75 → white
cols <- ifelse(post_vals >= 0.95, "black",
               ifelse(post_vals >= 0.75, "darkgray", "white"))

# 4) slap them on with nodelabels()
nodelabels(
  # round(post_vals, 2),       # text = posterior
  # node = node_nums,          # explicit node numbers
  pch  = 21,                 # filled‐circle
  cex  = 1.5,
  bg   = cols                # fill colours
)
dev.off()
