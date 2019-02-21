######################################################
######################################################
# Analyses inferred topology and node heights of
# species trees
######################################################
######################################################
library(ggplot2)
library(phytools)
library(ape)
library("OutbreakTools")
library(ggtree)

# clear workspace
rm(list = ls())



# Set the directory to the directory of the file
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# define the burn-in percentage
burn_in = 0.1
# define the prior probability of an indicator being active (here it's lambda/(nr indicators) )
prior = 0.695/50


# Read In Data ---------------------------------
mig_rate <- data.frame()
counter <- 1

i = 1

# Make the filenames for all possible migration rates
print("to fix the error: 'Error in start:end : NA/NaN argument' appears, add an 'End;' to the end of the tree file")
trees <- "./../precooked_runs/species_long.trees"

# get all the tree topologies in the posterior, if the file isn't ended by END;, this wll cause an error
est_species_tree_with_nodes <- read.annotated.nexus(trees)

est_species_tree_with_nodes = est_species_tree_with_nodes[seq(-1,-round(length(est_species_tree_with_nodes)*burn_in))]


# get all the ossible phylogenies, does however not get the ranked topologies
unique_topologies <- unique.multiPhylo(est_species_tree_with_nodes,use.edge.length = FALSE, use.tip.label = TRUE)


annotations <- vector(, length(est_species_tree_with_nodes))

# get the node order for each of the species trees
for (i in seq(1,length(est_species_tree_with_nodes))){
  for (j in seq(1,length(unique_topologies))){
    eq <- all.equal(est_species_tree_with_nodes[[i]], unique_topologies[[j]],use.edge.length = FALSE, use.tip.label = TRUE)
    if (eq){
      top_nr <- j
      break;
    }
  }
  # get the node heights and all subtrees
  subs = subtrees(est_species_tree_with_nodes[[i]])
  
  nr_tips = length(est_species_tree_with_nodes[[i]]$tip.label)
  
  # init the annotations data frame
  new.annotations <- data.frame(sample=i)
  
  # get the root heights of all subtrees
  node_heights <- rep(0,2*nr_tips-1)
  node_names <- vector(,2*nr_tips-1)
  for (j in seq(1,nr_tips)){
    node_names[j] <- est_species_tree_with_nodes[[i]]$tip.label[j]
  }

  for (j in seq(1,length(subs))){
    all_heights <- nodeHeights(subs[[j]])
    node_heights[nr_tips+j] <- max(all_heights[,2])
    node_names[nr_tips+j] <- paste(sort(subs[[j]]$tip.label), collapse=":")
    
    new_name = paste("height&", node_names[nr_tips+j], sep="")
    new.annotations[,new_name] = max(all_heights[,2])
    
  }
  
# get the correct mapping of labels to node numbers, make it way too complicated
  tree_edges <- est_species_tree_with_nodes[[i]]$edge
  
  node_species <- rep(-1,2*nr_tips-1)
  node_ne <- rep(-1,2*nr_tips-1)
  
  
  
  # get the nes
  for (j in seq(1, length(tree_edges[,2]))){
    node_label <- tree_edges[j,2]
    node_species[node_label] <- est_species_tree_with_nodes[[i]]$annotations[[j]]$species
    new_name = paste("Ne&", node_names[node_label], sep="")
    new.annotations[,new_name] = est_species_tree_with_nodes[[i]]$annotations[[j]]$Ne
  }
  node_label <- nr_tips+1
  new_name = paste("Ne&", node_names[node_label], sep="")
  new.annotations[,new_name] = est_species_tree_with_nodes[[i]]$root.annotation$Ne

  # get the migration rates
  for (j in seq(1, length(tree_edges[,2]))){
    node_label <- tree_edges[j,2]
    for (k in seq(1, length(est_species_tree_with_nodes[[i]]$annotations[[j]]$to))){
      target = which(node_species == est_species_tree_with_nodes[[i]]$annotations[[j]]$to[[k]])
      new_name = paste("mig&", node_names[node_label], "&", node_names[target], sep="")
      new.annotations[,new_name] = est_species_tree_with_nodes[[i]]$annotations[[j]]$rates[[k]]
    }
  }

  # get the correct order
  indices <- sort(node_heights,index.return = TRUE)
  

  new.dat <- data.frame(topology=top_nr)
  new.heights <- data.frame(topology=top_nr)
  
  annotations[i] <- list(new.annotations)
  
  
  for (j in seq(1,length(indices$ix))){
    new_name = paste("n", j, sep="")
    new.dat[,new_name] = node_names[[indices$ix[[j]]]]
    new.heights[,new_name] = node_heights[[indices$ix[[j]]]]
  }
    
  if (i==1){
    tree_top = new.dat
  }else{
    tree_top = rbind(tree_top,new.dat)
  }
}


# get the unique ranked topologies
unique_ranked <- unique(tree_top)

median_node_heights <- vector(, length(unique_ranked$topology))

log <- vector(, length(unique_ranked$topology))

# keeps track of the posterior support for tree
bpp_support = rep(0, length(unique_ranked$topology))

# for each of these trees, make an individual log file
for (i in seq(1, length(unique_ranked$topology))){
  # get the row and change the row name to compare rows
  ur <- unique_ranked[i,]
  row.names(ur) <- 1
  
  
  first = TRUE
  
  for (j in seq(1, length(tree_top$n1))){
    tocomp <- tree_top[j,]
    row.names(tocomp) <- 1
    
    if (identical(ur,tocomp)){
    
      if (first){
        log.data <- annotations[[j]]
        all_labels = labels(log.data)
        first <- FALSE
      }else{
        new.dat <- data.frame(sample=j)
        for (k in seq(1,length(all_labels[[2]]))){
          new.dat[1, all_labels[[2]][[k]]] <- annotations[[j]][,all_labels[[2]][[k]]]
        }
        
        log.data <- rbind(log.data,annotations[[j]])
      }
    }
  }

  # get the median node heights of the ranked trees (and the upper and lower limits)
  new.median_node_heights <- vector(, length(node_heights))
  
  all_labels = labels(log.data)
  nc = 1
  for (j in seq(1,length(all_labels[[2]]))){
    if (startsWith(all_labels[[2]][[j]],"height&")){
      new.median_node_heights[[nc]] <- median(log.data[,all_labels[[2]][[j]]])
      nc <- nc+1
    }
  }
  
  median_node_heights[[i]] <- list(new.median_node_heights)
  
  log[i] <- list(log.data)
  bpp_support[i] <- length(log.data$sample)
  
  
  fname1 <- gsub("\\.trees", paste("_", i, "tmp.log", sep=""), trees)
  fname2 <- gsub("\\.trees", paste("_", i, ".log", sep=""), trees)
  
  write.table(log.data, file=fname1, quote=F, row.names=F, sep="\t")

  system(paste("/Applications/BEAST\\ 2.5.0/bin/logcombiner -renumber -burnin 0 -log", fname1, "-o", fname2, sep=" "))
  system(paste("rm -r ", fname1))
}

sum_sup = sum(bpp_support)
bpp__proc_support = rep(0, length(unique_ranked$topology))
for (i in seq(1,length(bpp_support))){
  bpp__proc_support[i]= bpp_support[i]/sum_sup
}


# recompute the branch lengths of each unique ranked phylogeny to be the median branch length
for (i in seq(1, length(unique_ranked$topology))){
  # find the first tree with the same ranked topology
  ur <- unique_ranked[i,]
  row.names(ur) <- 1
  for (j in seq(1, length(tree_top$n1))){
    tocomp <- tree_top[j,]
    row.names(tocomp) <- 1
    if (identical(ur,tocomp)){
      plot_tree <- ladderize(est_species_tree_with_nodes[[j]],right=F)
      break
    }
  }
  
  # remove annotations
  plot_tree$annotations <- NULL
  plot_tree$root.annotation <- NULL
  
  # get the median node heights
  node_heights <- sort(median_node_heights[[i]][[1]])
  ape_node_edges = plot_tree$edge
  
  # get the ordering of nodes in the ape tree by comparing the heights
  ape_node_heights = abs(nodeHeights(plot_tree)-max(nodeHeights(plot_tree)[,2]))[seq(1,length(ape_node_edges[,1]),2),1]
  # get the corresponding numbers
  ape_node_numbers = ape_node_edges[seq(1,length(ape_node_edges[,1]),2),1]
  
  indices <- order(ape_node_heights)
  # get the original indices
  ori_indices <- seq(1,length(indices))
  
  
  new.node_heights <- node_heights
  # order the node_heights to match ape noe heights
  for (j in seq(1, length(indices))){
    new.node_heights[indices[j]+length(plot_tree$tip.label)] <- node_heights[j+length(plot_tree$tip.label)]
  }
  
  node_heights <- new.node_heights
  new.node_heights <- node_heights
  # now also match the node order
  for (j in seq(1,length(ape_node_numbers))){
    new.node_heights[ape_node_numbers[j]] <- node_heights[j+length(plot_tree$tip.label)]
  }
  
  # change the edge lengths to match the median heights
  for (j in seq(1, length(plot_tree$edge.length))){
    plot_tree$edge.length[j] <- new.node_heights[ape_node_edges[j,1]] -  new.node_heights[ape_node_edges[j,2]]
  }
  
  rm(mig_rates)
  
  # get all migraiton rates with a bayes factor over ...
  log.data = log[[i]]
  all_labels = labels(log.data)
  nc=1;
  for (j in seq(1,length(all_labels[[2]]))){
    if (startsWith(all_labels[[2]][[j]],"mig&")){
      posterior = length(which(log.data[,all_labels[[2]][[j]]]>0))/length(log.data[,all_labels[[2]][[j]]])
      bayes = posterior*(1-prior)/((1-posterior)*prior)
      if (bayes>10){
        new.mig_rates <- data.frame(from = strsplit(all_labels[[2]][[j]], "&")[[1]][3], to = strsplit(all_labels[[2]][[j]], "&")[[1]][2], BF=bayes, post=posterior)
        if (nc==1){
          mig_rates = new.mig_rates
          nc <- nc+1
        }else{
          mig_rates = rbind(mig_rates, new.mig_rates)
        }
      }
    }
  }
  print("fdslkjfdjsklfdjkls")
  
  rm(arrows.data)
  
  # build the arrow dataframe
  if (exists("mig_rates")){
    
    for (j in seq(1,length(mig_rates$from))){
      from_leaves = strsplit(as.character(mig_rates[j, "from"]), split=":")
      if (length(from_leaves[[1]])==1){
        from_mrca = which(plot_tree$tip.label==from_leaves[[1]][[1]])
      }else{
        from_mrca = findMRCA(plot_tree, tips=from_leaves[[1]], type=c("node","height"))
      }
      
      to_leaves = strsplit(as.character(mig_rates[j, "to"]), split=":")
      if (length(to_leaves[[1]])==1){
        to_mrca = which(plot_tree$tip.label==to_leaves[[1]][[1]])
      }else{
        to_mrca = findMRCA(plot_tree, tips=to_leaves[[1]], type=c("node","height"))
      }
      
      # get the heights of from and to nodes and the heights of their parents
      from_heights = nodeHeights(plot_tree)[which(plot_tree$edge[,2]==from_mrca),]
      to_heights = nodeHeights(plot_tree)[which(plot_tree$edge[,2]==to_mrca),]
      
      x_coord = (min(from_heights[2], to_heights[2])-max(from_heights[1], to_heights[1]))/2+max(from_heights[1], to_heights[1])
      
      new.arrows = data.frame(y=node.height(plot_tree)[from_mrca], yend=node.height(plot_tree)[to_mrca],
                              x=x_coord, xend=x_coord, post=mig_rates[j, "post"])
      if (j==1){
        arrows.data = new.arrows
      }else{
        arrows.data = rbind(arrows.data, new.arrows)
      }
    }
  }

  p <- ggtree(plot_tree) + scale_x_reverse() + coord_flip() 
  if (exists("arrows.data")){
    p <- p + geom_curve(data=arrows.data,curvature = -0.3,  aes(x=x, xend=xend,y = y, yend=yend, size=post/2), arrow = arrow(angle=10,type="closed",ends="last"), alpha=1)
  }
  p <- p + geom_tiplab()+ 
    ggtitle(sprintf("posterior support = %.3f", bpp__proc_support[[i]]))
  
  
  fname1 <- gsub("\\.trees", paste("_", i, ".pdf", sep=""), trees) 

  
  
  ggsave(plot=p, filename=fname1)
  

}
