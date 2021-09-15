########################################################
##      HONOURS ANALYIS CODE (whole model VERS)       ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#######################################
#user input here!
MODELTYPE <- "ODE"
OPTIMA <- "BOptMed"
#######################################

#objective of this part: take in all the param combos and average across those, right? can alwas check tmrw
#sample across the entire parameter space to see how these values evolve? if they reach optima

#### Amamteur Parallelisation ####
library(dplyr)
library(ggplot2)
library(foreach)


##### the two loops to set up the params for the rest of the code #####
#First nested loop: setting BOpt depending on your input and model type
if (MODELTYPE == "ADD") {
  if (OPTIMA == "BOptHigh") {
    BOpt = 200
  } else if (OPTIMA == "BOptMed") {
    BOpt = 150
  } else if (OPTIMA == "BOptLow") {
    BOpt = 100
  } else if (OPTIMA == "Neutral") {
    BOpt = 0
  } else {
    print("Invalid Input for the Optima. Would you like to try again?")
  }
} else if (MODELTYPE == "ODE") {
  if (OPTIMA == "BOptHigh") {
    BOpt = 100
  } else if (OPTIMA == "BOptMed") {
    BOpt = 50
  } else if (OPTIMA == "BOptLow") {
    BOpt = 10
  } else if (OPTIMA == "Neutral") {
    BOpt = 0
  } else {
    print("Invalid Input for the Optima. Would you like to try again?")
  }
} else {
  print("I do not recognize that model type, did you spell something wrong?")
}


#second nested loop: get your seed / combo locations right depending on model type
if (MODELTYPE == "ADD") {
  seeds <- read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ADD/seeds.csv")
  combos <-read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ADD/combo.csv")
  index <- 1:25
} else if (MODELTYPE == "ODE") {
  seeds <- read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ODE/seeds.csv")
  combos <-read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ODE/combo.csv")
  index <- 1:5
} else {
  print("Could not locate files - check your model type input!")
}


####  set WD to tank #####
workdirectory <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/", MODELTYPE, "/aquarium")
setwd(workdirectory)

## THE FILES LOOP ##

#loop needs to go through the OPTIMA, so i need to include that in the previous output whoops

#foreach(i=1:length(index)) %:% #modelindex, should be 1-5 in the ODE and 1:25 in ADD, can be looped!
#  foreach(l = 1:4) %do% { #1:4 never changes
    
    #this gives me all seeds (*) for a given combination of node and index
    myElodea <- lapply(Sys.glob(paste0("PogNoodle_*.csv")), read.table) #reps for unique combos, seed level data
    myShelldon <- lapply(Sys.glob(paste0("PogNoodled_*.csv")), read.table) #one entry per generation, mean across seeds

    #Elodea : the dataset with ALL seeds for all combos, might be too big for the large datasets
    ELODEA <- bind_rows(myElodea, .id = "UniqueCombo") #all params comb, one entry per generation
    colnames(ELODEA) <- ELODEA[1,] #column names
    colnames(ELODEA)[1] <- "UniqueCombo" #fix one label
    ELODEA <- subset(ELODEA, AAlpha!= "AAlpha") #remove the labels
    ELODEA <-   mutate_all(ELODEA, .funs = as.numeric) #turns characters into numerics
        
    #Sheldon : the dataset with the means for all combos
    SHELLDON <- bind_rows(myShelldon, .id = "UniqueCombo") #all params comb, one entry per generation
    colnames(SHELLDON) <- SHELLDON[1,] #column names
    colnames(SHELLDON)[1] <- "UniqueCombo" #fix one label
    SHELLDON <- subset(SHELLDON, AAlpha!= "AAlpha") #remove the labels
    SHELLDON <-   mutate_all(SHELLDON, .funs = as.numeric) #turns characters into numerics
    
    #take the means across replicates (seeds) of the means across individuals (but via generation? yeah, cause each time point is unique data, and if i only want the end i still need to do it by generation)
    RICHARD <- SHELLDON %>%
      group_by(SHELLDON$Generation) %>%
      summarise(AAlpha = mean(AAlpha),
                ABeta = mean(ABeta),
                BAlpha = mean(BAlpha),
                BBeta = mean(BBeta),
                AConc = mean(AConc),
                BConc = mean(BConc),
                fitness = mean(fitness),
                distance = mean(distance)
      )
    
    colnames(RICHARD)[1] <- "Generation"

    #violin plots will make more sense than line plots i reckon
    
#assume all files for each of the replicates is in one location (a folder called aquarium?)
#set wd aquaroium

#read in these files

#take the means of the means across entire model, smallest unit here is seed

#generate the same graphs as before, but with overlay (need pog noodle files for that)

#summary statistics too?

#save the new collated data sets
