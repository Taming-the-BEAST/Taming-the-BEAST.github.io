plotSpeciesTree = function (tree_filename, tree_name, posterior.threshold, BF.threshold, prior, forward.arrows){
  require(ggplot2)
  require(phytools)
  require(ape)
  require(coda)
  
  species_trees <- read.nexus(file=tree_filename,force.multi=T) # get all the tree topologies in the posterior
  ind = which(labels(species_trees)==tree_name)
  print(ind)
  plot_tree <- ladderize(species_trees[[ind]], right=F)
  

  # read in the node heights, Ne's and migration rates
  filename = paste(tree_filename, ".", tree_name, ".log", sep="") # build the filename for the log file corresponding to the current unique ranked tree
  t = read.table(filename, header=T, sep="\t",quote = "\"") # read in the log files with Ne's etc.
  names(t) = scan(filename, nlines = 1, what = character()) # get the proper headers (read.table converts : into .)
  # adapt the names to be alphabetically ordered
  old_nodenames = c()
  new_nodenames = c()
  for (j in seq(1,length(names(t)))){
    if (startsWith(names(t)[[j]], "height_")){
      old_nodenames = append(old_nodenames, gsub("height_", "", names(t)[[j]]))
      new_nodenames = append(new_nodenames, paste(sort(strsplit(old_nodenames[length(old_nodenames)], split=":")[[1]]), collapse=":"))
    }
  }
  
  nr_tips = length(plot_tree$tip.label) # get the number of tips
  node_names <- vector(,2*nr_tips-1) # keeps track of the node names as in the log file
  
  # get the node names for the tips as they are in the log file
  for (j in seq(1,nr_tips)){
    node_names[j] <- plot_tree$tip.label[j]
  }
  
  # get the node names for internal nodes as they are in the log file
  subs = subtrees(plot_tree)
  for (j in seq(1,length(subs))){
    node_names[nr_tips+j] <- paste(sort(subs[[j]]$tip.label), collapse=":")
  }
  
  # Build the tree as a series of segments to plot in ggtree
  rm(tree.rectangular.data)
  
  edges=plot_tree$edge # get all edges of the tree
  for (j in seq(1,length(edges[,1]))){
    node1name = old_nodenames[which(new_nodenames==node_names[edges[j,1]])]
    node2name = old_nodenames[which(new_nodenames==node_names[edges[j,2]])]
    
    x.height.start = node.height(plot_tree)[edges[j,1]] # get the x-coordinate of the edge
    x.height.end = node.height(plot_tree)[edges[j,2]] # get the x-coordinate of the edge
    y.height.start = mean(t[,paste("height", node1name, sep="_")])
    y.height.end = mean(t[,paste("height", node2name, sep="_")])
    
    hpdHeight = HPDinterval(as.mcmc(t[,paste("height", node1name, sep="_")])) # get the node height 95% interval
    
    new.rectangular = data.frame(xend=x.height.end, x=x.height.end, y=y.height.end, yend=y.height.start) # build the vertical edges
    new.rectangular = rbind(new.rectangular,data.frame(xend=x.height.end, x=x.height.start, y=y.height.start, yend=y.height.start)) #build the horizontal edges
    new.errorbar = data.frame(xend=x.height.start, x=x.height.start, y=hpdHeight[1,"lower"], yend=hpdHeight[1,"upper"]) # build the node height errorbars
    
    if (j==1){
      tree.rectangular.data = new.rectangular
      error.data = new.errorbar
    }else{
      tree.rectangular.data = rbind(tree.rectangular.data, new.rectangular)
      error.data = rbind(error.data,new.errorbar)
    }
  }
  
  rm(mig_rates)
  first=T
  for (j in seq(1,length(names(t)))){
    if (startsWith(names(t)[[j]],"bmig_")){
      # check between which edges the arrow is
      mig_nodes = strsplit(gsub("bmig_", "", names(t)[[j]]), split="_to_")[[1]]
      node_nr1 = which(old_nodenames==mig_nodes[[1]]) # get the node number of the from node
      node_nr2 = which(old_nodenames==mig_nodes[[2]]) # get the node number of the to node
      x.height.from = node.height(plot_tree)[which(node_names==new_nodenames[node_nr1])] # get the x-coord for the from arrow
      x.height.to = node.height(plot_tree)[which(node_names==new_nodenames[node_nr2])] # get the y-coord for the to arrow
      edge1 = which(edges[,2]==which(node_names==new_nodenames[node_nr1])) # get the edge of the first node
      edge2 = which(edges[,2]==which(node_names==new_nodenames[node_nr2])) # get the edge of the second node
      y.height.start1 = mean(t[,paste("height", old_nodenames[which(new_nodenames==node_names[edges[edge1,1]])], sep="_")]) # get starting height of edge 1
      y.height.end1 = mean(t[,paste("height", old_nodenames[which(new_nodenames==node_names[edges[edge1,2]])], sep="_")]) # get ending height of edge 1
      y.height.start2 = mean(t[,paste("height", old_nodenames[which(new_nodenames==node_names[edges[edge2,1]])], sep="_")]) # get starting height of edge 2
      y.height.end2 = mean(t[,paste("height", old_nodenames[which(new_nodenames==node_names[edges[edge2,2]])], sep="_")]) # get ending height of edge 2
      
      y.height = max(y.height.end1,y.height.end2) + (min(y.height.start1,y.height.start2)-max(y.height.end1,y.height.end2))/2 * runif(1, 0.99999, 1.00001)
      
      posterior = length(which(t[,names(t)[[j]]]>0))/length(t[,names(t)[[j]]])
      bayes = posterior*(1-prior)/((1-posterior)*prior)
      new.migration = data.frame(x=x.height.from, xend=x.height.to,y=y.height,yend=y.height,post=posterior,BF=bayes) 
      if (first){
        mig_rates = new.migration
        first=F
      }else{
        mig_rates = rbind(mig_rates,new.migration)
      }
    }
  }

  subset.mig_rates = mig_rates[which(mig_rates$post>posterior.threshold),] 
  subset.mig_rates = subset.mig_rates[which(subset.mig_rates$BF>BF.threshold),] 
  
  p <- ggplot() + 
    geom_segment(data=tree.rectangular.data, aes(x=x,y=y,xend=xend,yend=yend)) + # plot the edges of the tree
    geom_segment(data=error.data, aes(x=x,y=y,xend=xend,yend=yend), size=2, color="gray48") # plots the errobars for node heights
  
  if (length(subset.mig_rates)>0){
    if (forward.arrows){
      p <- p + geom_curve(data=subset.mig_rates, curvature = -0.2, # adds the arrows to the plot
                         aes(x=xend, xend=x, y = y, yend=yend, size=post),
                         arrow = arrow(angle=20,type="closed",ends="last"))
    }else{
      p <- p + geom_curve(data=subset.mig_rates, curvature = 10, # adds the arrows to the plot
                         aes(x=x, xend=xend, y = y, yend=yend, size=post),
                         arrow = arrow(angle=20,type="closed",ends="last"))
    }
  }
  
  # get the tip labels
  tip_labels = vector(,nr_tips)
  break_points = vector(,nr_tips)
  for (i in seq(1,nr_tips)){
    tip_labels[[i]] = node_names[[i]]
    break_points[[i]] = node.height(plot_tree)[i]
  }
  
  print(tip_labels)
  print(break_points)
  p <- p + scale_x_continuous(breaks=break_points, labels=tip_labels) + xlab("")
  
  return (p)
}
