########################################################
##      HONOURS ANALYIS CODE (whole model VERS)       ##
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
#########################################################

####  set WD to aquarium #####
workdirectory <- paste0("C:/Users/sknie/github/honours/4_Analysis/", MODELTYPE, "/aquarium")
setwd(workdirectory)

## THE FILES LOOP ##
#loop so that m = 1:4 and for m = 1 it inserts BOptHigh etc etc

foreach(m=1:4) %do% {

  ##### the two loops to set up the params for the rest of the code #####

    #set the OPTIMA, then load the files
    if (m == 1) {
      OPTIMA <- "BOptHigh"
    } else if (m == 2) {
      OPTIMA <- "BOptMed"
    } else if (m == 3) {
      OPTIMA <- "BOptLow"
    } else if (m == 4) {
      OPTIMA <- "Neutral"
    } else {
      print("What the dog doin")
    }

  #Second nested loop: setting BOpt depending on your input and model type
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

    #### Read in the files ####
    #this gives me all seeds (*) for a given combination of node and index
    myElodea <- lapply(Sys.glob(paste0("PogNoodle_*_", OPTIMA, "*.csv")), read.table) #reps for unique combos, seed level data
    myShelldon <- lapply(Sys.glob(paste0("PogNoodled_*_", OPTIMA, "*.csv")), read.table) #one entry per generation, mean across seeds

    if (MODELTYPE == "ODE") {
      #Elodea : the dataset with ALL seeds for all combos, might be too big for the large datasets
      ELODEA <- bind_rows(myElodea, .id = "UniqueCombo") #all params comb, one entry per generation
      colnames(ELODEA) <- ELODEA[1,] #column names
      colnames(ELODEA)[1] <- "UniqueCombo" #fix one label
      ELODEA <- subset(ELODEA, GeneA1!= "GeneA1") #remove the labels
      ELODEA <-   mutate_all(ELODEA, .funs = as.numeric) #turns characters into numerics

      #Sheldon : the dataset with the means for all combos
      SHELLDON <- bind_rows(myShelldon, .id = "UniqueCombo") #all params comb, one entry per generation
      colnames(SHELLDON) <- SHELLDON[1,] #column names
      colnames(SHELLDON)[1] <- "UniqueCombo" #fix one label
      SHELLDON <- subset(SHELLDON, GeneA1!= "GeneA1") #remove the labels
      SHELLDON <-   mutate_all(SHELLDON, .funs = as.numeric) #turns characters into numerics

      #take the means across replicates (seeds) of the means across individuals (but via generation? yeah, cause each time point is unique data, and if i only want the end i still need to do it by generation)
      RICHARD <- SHELLDON %>%
        group_by(SHELLDON$Generation) %>%
        summarise(GeneA1 = mean(GeneA1),
                  GeneA2 = mean(GeneA2),
                  GeneB1 = mean(GeneB1),
                  GeneB2 = mean(GeneB2),
                  AConc = mean(AConc),
                  BConc = mean(BConc),
                  fitness = mean(fitness),
                  distance = mean(distance)
        )

      colnames(RICHARD)[1] <- "Generation"

    } else if (MODELTYPE == "ADD") {
      #Elodea : the dataset with ALL seeds for all combos, might be too big for the large datasets
      ELODEA <- bind_rows(myElodea, .id = "UniqueCombo") #all params comb, one entry per generation
      colnames(ELODEA) <- ELODEA[1,] #column names
      colnames(ELODEA)[1] <- "UniqueCombo" #fix one label
      ELODEA <- subset(ELODEA, GeneA1!= "GeneA1") #remove the labels
      ELODEA <-   mutate_all(ELODEA, .funs = as.numeric) #turns characters into numerics

      #Sheldon : the dataset with the means for all combos
      SHELLDON <- bind_rows(myShelldon, .id = "UniqueCombo") #all params comb, one entry per generation
      colnames(SHELLDON) <- SHELLDON[1,] #column names
      colnames(SHELLDON)[1] <- "UniqueCombo" #fix one label
      SHELLDON <- subset(SHELLDON, GeneA1!= "GeneA1") #remove the labels
      SHELLDON <-   mutate_all(SHELLDON, .funs = as.numeric) #turns characters into numerics

      #take the means across replicates (seeds) of the means across individuals (but via generation? yeah, cause each time point is unique data, and if i only want the end i still need to do it by generation)
      RICHARD <- SHELLDON %>%
        group_by(SHELLDON$Generation) %>%
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

      colnames(RICHARD)[1] <- "Generation"

    } else {print("Something done fucked up!")} #back to non differentiated stuff

    #Richard
    richie <- as.character(paste0("Richard_", MODELTYPE, "_", OPTIMA, ".csv"))

    Richard <- as.data.frame(RICHARD)

    write.table(Richard, richie,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #Shelldon
    shellie <- as.character(paste0("Shelldon_", MODELTYPE, "_", OPTIMA, ".csv"))

    write.table(SHELLDON, shellie,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #Elodea, nope

}
