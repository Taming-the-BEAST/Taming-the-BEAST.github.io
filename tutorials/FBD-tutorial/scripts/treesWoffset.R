transform.woffset.root = function(treesfile, logfile, outfile) {
  trees = ape::read.nexus(treesfile)
  log = read.table(logfile ,header = T)
  log = log$offset
  print(median(log))
  for(i in 1:length(trees)) trees[[i]]$offset = log[i]
  
  presenttrees = lapply(trees, function(t) {
    ntips = length(t$tip.label)
    totn = ntips + t$Nnode
    
    times = ape::node.depth.edgelength(t)
    root_time = max(times) + t$offset
    
    root = ntips+2
    t$edge[which(t$edge > ntips)] = t$edge[which(t$edge > ntips)]+1
    t$edge[which(t$edge >= root)] = t$edge[which(t$edge >= root)]+1
    
    t$edge = rbind(c(root, root+1), c(root, ntips+1),t$edge)
    t$edge.length = c(0.1 , root_time, t$edge.length)
    t$tip.label = c(t$tip.label, "dummy")
    t$Nnode = t$Nnode + 1
    
    return(t)
  })
  
  ape::write.nexus(presenttrees, file= outfile)
}

convert.MCC.tree = function(treefile, outfile) {
  tmp = treeio::read.beast(treefile)
  
  tip = which(tmp@phylo$tip.label == "dummy")
  tipn = which(tmp@data$node == as.character(tip))
  node = tmp@phylo$edge[which(tmp@phylo$edge[,2] == tip),1]
  noden = which(tmp@data$node == as.character(node))
  
  offset = min(tmp@data$height_median[which(as.numeric(tmp@data$node) <= length(tmp@phylo$tip.label) &
                                              as.numeric(tmp@data$node) != tip)])
  print(offset)
  
  tmp@phylo = ape::drop.tip(tmp@phylo, tip)
  tmp@data = tmp@data[-c(tipn,noden),]
  tmp@data$node = as.numeric(tmp@data$node)
  tmp@data$node[(tmp@data$node) > tip] = tmp@data$node[(tmp@data$node) > tip] - 1
  tmp@data$node[(tmp@data$node) > node] = tmp@data$node[(tmp@data$node) > node] - 1
  tmp@data$node = as.character(tmp@data$node)
  
  tmp@data$height_0.95_HPD = lapply(tmp@data$height_0.95_HPD, function(x) x-offset)
  treeio::write.beast(tmp,outfile)
  system(paste0("gsed -i 's%* UNTITLED%TREE1%' ", outfile))
}
