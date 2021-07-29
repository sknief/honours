##############################################################################################################
#  Run SLiM in parallel
##############################################################################################################

#  Parallel script modified from SLiM-Extras example R script, info at
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.

# Environment variables

USER <- Sys.getenv('USER')
ARRAY_INDEX <- as.numeric(Sys.getenv('PBS_ARRAY_INDEX'))

# Parallelisation libraries

library(foreach)
library(doParallel)
library(future)


seeds <- read.csv(paste0("/home/",USER,"/SLiM/Scripts/Tests/Example/R/seeds.csv"), header = T)
combos <- read.csv(paste0("/home/",USER,"/SLiM/Scripts/Tests/Example/R/combos.csv"), header = T)

# Set which runs to do according to node

switch (ARR_INDEX,
        { combos <- combos[1:5,] },
        { combos <- combos[6:9,] },
        { combos <- combos[10:13,] },
        { combos <- combos[14:18,] }
)


cl <- makeCluster(future::availableCores())
registerDoParallel(cl)

#Run SLiM
foreach(i=1:nrow(combos)) %:%
  foreach(j=seeds$Seed) %dopar% {
    # Use string manipulation functions to configure the command line args, feeding from a data frame of seeds
    # then run SLiM with system(),
    slim_out <- system(sprintf("/home/$USER/SLiM/slim -s %s -d param1=%f -d param2=%f -d modelindex=%i /home/$USER/SLiM/Scripts/Tests/Example/slim/slim_example.slim",
                               as.character(j), combos[i,]$param1, combos[i,]$param2, i, intern=T))
  }
stopCluster(cl)
