########################################################
##      HONOURS ANALYIS CODE (ONE REP VERS)           ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amamteur Parallelisation ####
library(dplyr)
library(ggplot2)
library(foreach)
library(gridExtra)

############### user input here!#########################
MODELTYPE <- "ADD"
OPTIMA <- "BOptHigh"
REP <- 5
#########################################################

####  set WD to tank #####
workdirectory <- paste0("/scratch/user/s4471959/", MODELTYPE, "_", OPTIMA, "/Mini", REP , "/Tank")
setwd(workdirectory)

##### the two loops to set up the params for the rest of the code #####

#First nested loop: setting BOpt depending on your input and model type
if (MODELTYPE == "ADD") {
  if (OPTIMA == "BOptHigh") {
    BOpt = 150
  } else if (OPTIMA == "BOptMed") {
    BOpt = 100
  } else if (OPTIMA == "BOptLow") {
    BOpt = 50
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
  seeds <- read.csv("/home/s4471959/OutbackRuns/ADD/miniseeds.csv")
  index <- 1:5
} else if (MODELTYPE == "ODE") {
  seeds <- read.csv("/home/s4471959/OutbackRuns/ODE/miniseeds.csv")
  index <- 1:1
} else {
  print("Could not locate files - check your model type input!")
}


#### foreach loops ####
## THE FILES LOOP ##

# ODE / ADD differences: the file read in would be the same, its just the variable names that differ

foreach(i=1:length(index)) %:% #modelindex, should be 1-5 in the ODE and 1:25 in ADD, can be looped!
  foreach(l = 1:4) %do% { #1:4 never changes

    #this gives me all seeds (*) for a given combination of node and index
    myBigPopas <- lapply(Sys.glob(paste0("BigPopa_onerun_*_", i, "_node_", l, ".csv")), read.table) #individual data
    myTetri <- lapply(Sys.glob(paste0("Tetris_onerun_*_", i, "_node_", l, ".csv")), read.table) #one entry per generation
    #mutation read in goes here

  if (MODELTYPE == "ODE") {
    #shrimpmoult (might be made optional tbh)
    SHRIMPMOULT <- bind_rows(myBigPopas, .id = "File") #all individuals all reps for combinations
    colnames(SHRIMPMOULT) <- SHRIMPMOULT[1,] #column names
    colnames(SHRIMPMOULT)[1] <- "File" #fix one label
    SHRIMPMOULT <- subset(SHRIMPMOULT, GeneA1!= "GeneA1") #remove the labels
    SHRIMPMOULT <-   mutate_all(SHRIMPMOULT, .funs = as.numeric) #turns characters into numerics

    #pognoodle
    POGNOODLE <- bind_rows(myTetri, .id = "Rep") #all reps for a node x index combination (params comb), one entry per generation
    colnames(POGNOODLE) <- POGNOODLE[1,] #column names
    colnames(POGNOODLE)[1] <- "Rep" #fix one label
    POGNOODLE <- subset(POGNOODLE, GeneA1!= "GeneA1") #remove the labels
    POGNOODLE <-   mutate_all(POGNOODLE, .funs = as.numeric) #turns characters into numerics

    #take the means across replicates (seeds) of the means across individuals (but via generation? yeah, cause each time point is unique data, and if i only want the end i still need to do it by generation)
    POGNOODLED <- POGNOODLE %>%
      group_by(POGNOODLE$Generation) %>%
      summarise(GeneA1 = mean(GeneA1),
                GeneA2 = mean(GeneA2),
                GeneB1 = mean(GeneB1),
                GeneB2 = mean(GeneB2),
                AConc = mean(AConc),
                BConc = mean(BConc),
                fitness = mean(fitness),
                distance = mean(distance)
      )

    colnames(POGNOODLED)[1] <- "Generation"

  } else if (MODELTYPE == "ADD") {
    #shrimpmoult (might be made optional tbh)
    SHRIMPMOULT <- bind_rows(myBigPopas, .id = "File") #all individuals all reps for combinations
    colnames(SHRIMPMOULT) <- SHRIMPMOULT[1,] #column names
    colnames(SHRIMPMOULT)[1] <- "File" #fix one label
    SHRIMPMOULT <- subset(SHRIMPMOULT, GeneA1!= "GeneA1") #remove the labels
    SHRIMPMOULT <-   mutate_all(SHRIMPMOULT, .funs = as.numeric) #turns characters into numerics

    #pognoodle
    POGNOODLE <- bind_rows(myTetri, .id = "Rep") #all reps for a node x index combination (params comb), one entry per generation
    colnames(POGNOODLE) <- POGNOODLE[1,] #column names
    colnames(POGNOODLE)[1] <- "Rep" #fix one label
    POGNOODLE <- subset(POGNOODLE, GeneA1!= "GeneA1") #remove the labels
    POGNOODLE <-   mutate_all(POGNOODLE, .funs = as.numeric) #turns characters into numerics

    #take the means across replicates (seeds) of the means across individuals (but via generation? yeah, cause each time point is unique data, and if i only want the end i still need to do it by generation)
    POGNOODLED <- POGNOODLE %>%
      group_by(POGNOODLE$Generation) %>%
      summarise(GeneA1 = mean(GeneA1),
                GeneA2 = mean(GeneA2),
                GeneB1 = mean(GeneB1),
                GeneB2 = mean(GeneB2),
                AConc = mean(AConc),
                BGamma = mean(BGamma),
                BConc = mean(BConc),
                fitness = mean(fitness),
                distance = mean(distance)
      )

    colnames(POGNOODLED)[1] <- "Generation"

} else {print("Something done fucked up!")}

    #Save code for all three datasets, regardless of use
    pognood <- as.character(paste0("PogNoodle_(reps_for_unique_combo)_",OPTIMA, "_", i, "_node_", l,  ".csv"))

    PogNoodle <- as.data.frame(POGNOODLE)

    write.table(PogNoodle, pognood,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    pognoodled <- as.character(paste0("PogNoodled_(mean_across_seeds)_", OPTIMA, "_",i, "_node_", l,  ".csv"))

    PogNoodled <- as.data.frame(POGNOODLED)

    write.table(PogNoodled, pognoodled,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    moultyshrimp <- as.character(paste0("ShrimpMoult_(all_individuals)_", OPTIMA, "_",i, "_node_", l,  ".csv"))

    ShrimpMoult <- as.data.frame(SHRIMPMOULT)

    write.table(ShrimpMoult, moultyshrimp,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

  } #foreach loop closed
