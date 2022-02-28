# Install the bdskytools package from GitHub by uncommenting the next line and running it in R/Rstudio
#
# devtools::install_github("laduplessis/bdskytools")
#
# Load the package (if successfully installed)
library(bdskytools)


# Extract the data and HPDs from the logfile
############################################

# Navigate to the directory where the log file is stored
# (in RStudio navigate to Session > Set Working Directory > Choose Directory)
# or change "data_with_duplicates.data_with_duplicates.log" to the full path of the BDSKY logfile on your computer
fname <- "data_with_duplicates.data_with_duplicates.log"
lf    <- readLogfile(fname, burnin=0.1)

# Extract gridded HPDs  
######################
# The trimegrid specifies the years into the past to grid the skyline to.
# We grid the skyline to every 6.2 days (0.017 years) for the past 1.7 years (100 grid cells)
timegrid       <- seq(0,1.7,length.out=101)
Re_sky    <- getSkylineSubset(lf, "reproductiveNumber")
Re_gridded     <- gridSkyline(Re_sky, lf$origin, timegrid)
Re_gridded_hpd <- getMatrixHPD(Re_gridded)


# Plotting the skyline
#####################
# The calendar times of the grid (the most recent sample is from unknown year, so we leave it at 0)
times <- 0-timegrid
plotSkyline(times, Re_gridded_hpd, type='smooth', xlab="Time (Years)", ylab=expression("R"[e]))
# Add a line at Re = 1 for comparison
abline(h = 1, col="red")
