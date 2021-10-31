########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: 20/09/21      ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amateur Parallelisation ####
library(dplyr)
library(foreach)
library(readr)
library(ggplot2)

############### user input here!#########################
JOBID <- 612969
NODE <- as.numeric(Sys.getenv('PBS_ARRAY_INDEX'))
MODELTYPE <- "ADD"
OPTIMA <- "BOptHigh"
S <- 2
REP <- 1
########################################################

### Set WD ####
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("/scratch/user/s4471959/", MODELTYPE, "_", OPTIMA, "/Mini", REP , "/state/partition1/pbs/tmpdir/pbs.", WD, ".tinmgr2")
setwd(workdirectory)

seeds <- read.csv("/home/s4471959/OutbackRuns/ADD/miniseeds.csv")
combos <-read.csv("/home/s4471959/OutbackRuns/ADD/minicombo.csv")

##mutation code
foreach(i=1:1)) %:%
  foreach(j= seeds$Seed) %do% {

  ##DATA COLLATION
      #first the polymorphs
        myMutants <- lapply(Sys.glob(paste0("SLiMulation_Output_Mutations_", j, "_", i , "_*.txt")), read_table2,  col_names = FALSE, skip = 5) #ODE

        for (h in 1:length(myMutants)) {
        myMutants[[h]][["X1"]] <- as.integer(myMutants[[h]][["X1"]])
        myMutants[[h]][["X2"]] <- as.integer(myMutants[[h]][["X2"]])
        myMutants[[h]][["X3"]] <- as.character(myMutants[[h]][["X3"]])
        myMutants[[h]][["X4"]] <- as.integer(myMutants[[h]][["X4"]])
        myMutants[[h]][["X5"]] <- as.integer(myMutants[[h]][["X5"]])
        myMutants[[h]][["X6"]] <- as.integer(myMutants[[h]][["X6"]])
        myMutants[[h]][["X7"]] <- as.character(myMutants[[h]][["X7"]])
        myMutants[[h]][["X8"]] <- as.integer(myMutants[[h]][["X8"]])
        myMutants[[h]][["X9"]] <- as.integer(myMutants[[h]][["X9"]])
        }
        mutations <- bind_rows(myMutants, .id = "Gen")
        mutations <- na.omit(mutations)
        colnames(mutations) <- c("Gen", "WithinFileID", "MutationID", "Type", "Position", "SelectionCoeff", "DomCoeff", "Population", "GenOrigin", "Prevalence1000")
        #mutations <- mutations[c(1, 3:6, 9:10)] #take out unnecessary columns
        mutations$Gen <- as.numeric(mutations$Gen)
        mutations$Gen <- mutations$Gen * 500
        mutations$MutType <- "P"

        #MEANS
        #time for means?
       MEANIE <- mutations %>%
          group_by(mutations$Gen, mutations$Type) %>%
          summarise(SelectionCoeff = mean(SelectionCoeff),
                    Position = mean(Position),
                    Prevalence = mean(Prevalence1000)
          )
        colnames(MEANIE) <- c("Gen", "Type", "SelectionCoeff", "Position", "Prevalence")

        #GRAPHS
        #historgram of mean polymorphs by type
        base <- ggplot(MEANIE, aes(x = Gen, y = SelectionCoeff, fill = MEANIE$Type))
        base + geom_col(position = "stack") +
          theme_classic()

          #DATA EXPORT
          #writing the files code
          #1 (collated sets for rep x combo of ALL mutations)
          muts <- as.character(paste0("ALLMutations_onerun_", j, "_", i,  "_node_", NODE,  ".csv"))
          ALLMUTATIONS <- as.data.frame(ALLMUTATIONS)
          write.table(ALLMUTATIONS, muts,
                      append = FALSE,
                     row.names = FALSE,
                      col.names = TRUE)

        #this might fail here onwards if theres not fixed mutation file

        #next the fixed mutations
        fixed <- read_table2(paste0("SLiMulation_Output_FixedMutations_", j, "_", i ,".txt"),
                         #    col_names = FALSE, skip = 2)
        fixed <- na.omit(fixed)

        colnames(fixed) <- c("WithinFileID", "MutationID", "Type", "Position", "SelectionCoeff", "DomCoeff", "Population", "GenOrigin", "Gen")
        fixed <- fixed[c(2:5, 8:9)] #take out unnecessary columns
        fixed$MutType <- "F"
        #need to round up the fixed mutation gens:
        fixed$Gen <- round_any((fixed$Gen), 500, f= ceiling)


        #make a monster data set
        ALLMUTATIONS <- bind_rows(mutations, fixed)
        ALLMUTATIONS[is.na(ALLMUTATIONS)] = 1000 #replace NAs for prevalence with 1000

        #time for MORE means?
        BIGMEANIE <- ALLMUTATIONS %>%
          group_by(ALLMUTATIONS$Gen, ALLMUTATIONS$MutType, ALLMUTATIONS$Type) %>%
          summarise(SelectionCoeff = mean(SelectionCoeff),
                   Position = mean(Position),
                    Prevalence = mean(Prevalence1000)
          )
        colnames(BIGMEANIE) <- c("Gen","MutType", "Type", "SelectionCoeff", "Position", "Prevalence")

        #historgram of polymorphs vs fixed
        base2 <- ggplot(BIGMEANIE, aes(x = Gen, y = SelectionCoeff, fill = BIGMEANIE$MutType))
        base2 + geom_col(position = "stack") +
          theme_classic()

        #distribution of effect sizes (half violin plots)
        violinplotm<- ggplot(data = BIGMEANIE, aes(x = factor(Gen), y = SelectionCoeff))
        violinplotm+
          geom_violin() +
          theme_classic() +
          labs(x = "Generation", y = "Mean Fitness")

        #2 (means)
        mut <- as.character(paste0("BIGMEANIE_onerun_", j, "_", i,  "_node_", NODE,  ".csv"))
        BIGMEANIE <- as.data.frame(BIGMEANIE)
        write.table(BIGMEANIE, mut,
                    append = FALSE,
                    row.names = FALSE,
                    col.names = TRUE)


      }
