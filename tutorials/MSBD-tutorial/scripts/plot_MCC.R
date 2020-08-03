#' Plot an MCC tree with median lambda / mu values on a coloured scale
#' @param treefile file containing the MCC tree
#' @param plotfile output file. If NULL, plots are sent to the R console.
#' @param scalel min and max values of lambda to use for the colour scale. If NULL, calculated from the tree values.
#' @param scalem min and max values of mu to use for the colour scale. If NULL, calculated from the tree values.
#' @param colour_gradient colours used on the scale, in order from low to high values.
MCC_colour_plot = function(treefile, plotfile = NULL, scalel = NULL, scalem = NULL, 
                           colour_gradient = c("red","yellow","green")) {
  library(ape)
  library(treeio)
  
  treedata = read.beast(treefile)
  lambdas = treedata@data$lambda_median[order(as.integer(treedata@data$node))]
  mus = treedata@data$mu_median[order(as.integer(treedata@data$node))]
  
  if(is.null(scalel)) {
    maxl = signif(1.05*max(lambdas),2)
    minl = signif(0.95*min(lambdas),2)
  }
  else {
    maxl = scalel[2]
    minl = scalel[1]
  }
  intervalsl = seq(minl, maxl, 0.1*(maxl - minl))
  
  if(is.null(scalem)) {
    maxm = signif(1.05*max(mus),2)
    minm = signif(0.95*min(mus),2)
  }
  else {
    maxm = scalem[2]
    minm = scalem[1]
  }
  intervalsm = seq(minm, maxm, 0.1*(maxm - minm))
  
  if(!is.null(plotfile)) pdf(plotfile, width = 17/grDevices::cm(1), height = 10/grDevices::cm(1))
  layout(mat = matrix(1:2, byrow = T, nrow = 1), widths = c(lcm(15),lcm(2)), heights = lcm(10))
  
  colsl = colour.gradient(lambdas[treedata@phylo$edge[,2]], intervals = intervalsl, colours = colour_gradient)
  plot.phylo(treedata@phylo,type = "fan",edge.color = colsl,show.tip.label = F, edge.width = 2, no.margin = T)
  
  legendplot(intervalsl, colours = colour_gradient)
  
  colsm = colour.gradient(mus[treedata@phylo$edge[,2]], intervals = intervalsm, colours = colour_gradient)
  plot.phylo(treedata@phylo,type = "fan",edge.color = colsm,show.tip.label = F, edge.width = 2, no.margin = T)
  
  legendplot(intervalsm, colours = colour_gradient)
  
  if(!is.null(plotfile)) dev.off()
}

legendplot = function(intervals = seq(0,11,0.5), axis.int = NULL, colours = c("red","yellow","green")) {
  lut = colorRampPalette(colours) (length(intervals))
  if(is.null(axis.int)) axis.int = intervals
  
  scale = (length(lut)-1)/(max(intervals)-min(intervals))
  plot(c(0,10), c(min(intervals),max(intervals)), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main="")
  axis(2, axis.int, las=1)
  for (i in 1:(length(lut)-1)) {
    y = (i-1)/scale + min(intervals)
    rect(0,y,10,y+1/scale, col=lut[i], border=NA)
  }
}

colour.gradient <- function(x, intervals = seq(0,11,0.1), colours=c("red","yellow","green")) {
  colfun = colorRampPalette(colours)
  return(  colfun(length(intervals)) [ findInterval(x, intervals) ] )
}