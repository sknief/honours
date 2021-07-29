#############################################################
##    Parallel Script for HPC [Honours 2021]
##    Based on Nick Obriens Script from his PolygenBook
##    Modified to suit my needs
#############################################################
# Create a list of parameters
#NOTE: these dont have the right values yet
p <- list()
p$BOpt <- c(0.1, 0.2, 0.3)
p$AbetaINI <- c('"Low"', '"Medium"', '"High"') #'" is necessary for SLiM to read them as strings
p$AalphaINI <- c(0.1, 0.2, 0.3)
p$HillnINI <- c(0.1, 0.2, 0.3)
p$BbetaINI <- c(0.1, 0.2, 0.3)
p$BalphaINI <- c(0.1, 0.2, 0.3)
p$S <- c(0.1, 0.2, 0.3)
p$PopSize <- c(0.1, 0.2, 0.3)
p$MutationRate <- c(0.1, 0.2, 0.3)

# Save the list as a data frame with all possible combinations
df.p <- expand.grid(p)

# You can also save df.p as a csv file and import it later, as with seeds: write.csv(df.p, row.names = F)

# Now we can use those data frame rows as inputs for our script

# Parallelisation libraries

#NOTE: these still need to be installed on HPC
library(foreach)
library(doParallel)
library(future)

#NOTE: Change the file path
seeds <- read.csv("~/Desktop/seeds.csv", header = T)


cl <- makeCluster(future::availableCores())
registerDoParallel(cl)

#Run SLiM
#NOTE: change the number of params and path
foreach(i=1:nrow(df.p)) %:%
  foreach(j=seeds$Seed) %dopar% {
        slim_out <- system(sprintf("/path/to/slim -s %s -d param1=%f -d param2=%s  ~/Desktop/example_script.slim",
                                  as.character(j), df.p[i,]$param1, df.p[i,]$param2, intern=T))
  }


stopCluster(cl)
