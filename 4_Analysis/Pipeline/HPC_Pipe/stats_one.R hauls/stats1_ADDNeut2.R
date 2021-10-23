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

############### user input here!#########################
JOBID <- 612969
NODE <- as.numeric(Sys.getenv('PBS_ARRAY_INDEX'))
MODELTYPE <- "ADD"
OPTIMA <- "Neutral"
S <- 2
REP <- 2
########################################################

### Set WD ####
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("/scratch/user/s4471959/", MODELTYPE, "_", OPTIMA, "/Mini", REP , "/state/partition1/pbs/tmpdir/pbs.", WD, ".tinmgr2")
setwd(workdirectory)

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

seeds <- read.csv("/home/s4471959/OutbackRuns/ADD/miniseeds.csv")
combos <-read.csv("/home/s4471959/OutbackRuns/ADD/minicombo.csv")


# ADD FILES ONLY (experimental) ####
foreach(i=1:4) %:%
  foreach(j= seeds$Seed) %do% {
    #read in all files based on specifications above for all generations
    myFiles <- lapply(Sys.glob(paste0("SLiM-output_ADD_", j, "_", i, "*.csv")), read.csv, header = FALSE)

    #Bigpopa, my hyuge shrimp, says hi (alot of the modifyers comes from ODE files, need separate loops again! )
    BIGPOPA <- bind_rows(myFiles, .id = "File")
    colnames(BIGPOPA) <- c("File", "ID", "GeneA1", "GeneA2", "GeneB1", "GeneB2", "AConc", "BGamma", "BConc", "Generation", "Seed") #column names
    BIGPOPA <-   mutate_all(BIGPOPA, .funs = as.numeric) #turns characters into numerics

    #Tetris, my beloved snail, says hi
    TETRIS <- BIGPOPA %>%
      group_by(BIGPOPA$Generation) %>%
      summarise(GeneA1 = mean(GeneA1),
                GeneA2 = mean(GeneA2),
                GeneB1 = mean(GeneB1),
                GeneB2 = mean(GeneB2),
                AConc = mean(AConc),
                BGamma = mean(BGamma),
                BConc = mean(BConc))

    colnames(TETRIS)[1] <- "Generation"
    TETRIS$SEED <- j
    TETRIS$Index <- i


    #for the datasets

    #fitness
    BIGPOPA$fitness = exp(-((BIGPOPA$BConc-BOpt)/S)^2);

    TETRIS$fitness <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(fitness= mean(fitness)) %>%
      pull(fitness)

    #distance
    BIGPOPA$distance <- BIGPOPA$BConc-BOpt

    TETRIS$distance <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(distance = mean(distance)) %>%
      pull(distance)


    #Tetris
    teddy <- as.character(paste0("Tetris_onerun_", j, "_", i,  "_node_", NODE,  ".csv"))

    Tetris <- as.data.frame(TETRIS)

    write.table(Tetris, teddy,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #BigPopa
    BigPop <- as.character(paste0("BigPopa_onerun_", j, "_", i, "_node_", NODE,  ".csv"))

    write.table(BIGPOPA, BigPop,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #mutation data stuff would go here
}


#MUTATIONS

foreach(i=1:1)) %:%
  foreach(j= seeds$Seed) %do% {
    ##DATA COLLATION
    #first the polymorphs
    myMutants <- lapply(Sys.glob(paste0("SLiMulation_Output_Mutations_", j, "_", i , "_*.txt")), read_table2,  col_names = FALSE, skip = 5) #ODE
    mutations <- bind_rows(myMutants, .id = "Gen")
    mutations <- na.omit(mutations)
    colnames(mutations) <- c("Gen", "WithinFileID", "MutationID", "Type", "Position", "SelectionCoeff", "DomCoeff", "Population", "GenOrigin", "Prevalence1000")
    mutations <- mutations[c(1, 3:6, 9:10)] #take out unnecessary columns
    mutations$Gen <- as.numeric(mutations$Gen)
    mutations$Gen <- mutations$Gen * 500
    mutations$MutType <- "P"


    #next the fixed mutations
    fixed <- read_table2(paste0("SLiMulation_Output_FixedMutations_", j, "_", i ,".txt"),
                         col_names = FALSE, skip = 2)
    fixed <- na.omit(fixed)
    colnames(fixed) <- c("WithinFileID", "MutationID", "Type", "Position", "SelectionCoeff", "DomCoeff", "Population", "GenOrigin", "Gen")
    fixed <- fixed[c(2:5, 8:9)] #take out unnecessary columns
    fixed$MutType <- "F"
    #need to round up the fixed mutation gens:
    fixed$Gen <- round_any((fixed$Gen), 500, f= ceiling)


    #make a monster data set
    ALLMUTATIONS <- bind_rows(mutations, fixed)
    ALLMUTATIONS[is.na(ALLMUTATIONS)] = 1000 #replace NAs for prevalence with 1000


    #MEANS
    #time for means?
    MEANIE <- mutations %>%
      group_by(mutations$Gen, mutations$Type) %>%
      summarise(SelectionCoeff = mean(SelectionCoeff),
                Position = mean(Position),
                Prevalence = mean(Prevalence1000)
      )
    colnames(MEANIE) <- c("Gen", "Type", "SelectionCoeff", "Position", "Prevalence")


    #time for MORE means?
    BIGMEANIE <- ALLMUTATIONS %>%
      group_by(ALLMUTATIONS$Gen, ALLMUTATIONS$MutType, ALLMUTATIONS$Type) %>%
      summarise(SelectionCoeff = mean(SelectionCoeff),
                Position = mean(Position),
                Prevalence = mean(Prevalence1000)
      )
    colnames(BIGMEANIE) <- c("Gen","MutType", "Type", "SelectionCoeff", "Position", "Prevalence")


    #GRAPHS
    #historgram of mean polymorphs by type
    base <- ggplot(MEANIE, aes(x = Gen, y = SelectionCoeff, fill = MEANIE$Type))
    base + geom_col(position = "stack") +
      theme_classic()

      ggsave(paste0("GraphA_",j, "_", i, ".png"), device = "png")

    #historgram of polymorphs vs fixed
    base2 <- ggplot(BIGMEANIE, aes(x = Gen, y = SelectionCoeff, fill = BIGMEANIE$MutType))
    base2 + geom_col(position = "stack") +
      theme_classic()

        ggsave(paste0("GraphB_",j, "_", i, ".png"), device = "png")

    #distribution of effect sizes (half violin plots)
    violinplotm<- ggplot(data = BIGMEANIE, aes(x = factor(Gen), y = SelectionCoeff))
    violinplotm+
      geom_violin() +
      theme_classic() +
    labs(x = "Generation", y = "Mean Fitness")

      ggsave(paste0("GraphC_",j, "_", i, ".png"), device = "png")

    #DATA EXPORT
    #writing the files code
    #1 (collated sets for rep x combo of ALL mutations)
    muts <- as.character(paste0("ALLMutations_onerun_", j, "_", i,  "_node_", NODE,  ".csv"))
    ALLMUTATIONS <- as.data.frame(ALLMUTATIONS)
    write.table(ALLMUTATIONS, muts,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #2 (means)
    mut <- as.character(paste0("BIGMEANIE_onerun_", j, "_", i,  "_node_", NODE,  ".csv"))
    BIGMEANIE <- as.data.frame(BIGMEANIE)
    write.table(BIGMEANIE, mut,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)


  }
