########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: 20/09/21      ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amateur Parallelisation ####
library(dplyr)
library(ggplot2)
library(foreach)
library(readr)
library(gridExtra)

############### user input here!#########################
JOBID <- 609710
NODE <- 1
MODELTYPE <- "ADD"
OPTIMA <- "Neutral"
S <- 2
########################################################

### Set WD ####
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("I:/_HONOURS_DATA/COOKED DATA (at least partially thru analysis)/X_Othert/Working_folder/", MODELTYPE, "/", OPTIMA, "/pbs.", WD , ".tinmgr2")
setwd(workdirectory)

### Nested loops to set up this script ####
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
  seeds <- read.csv("I:/_HONOURS_DATA/RESOURCES/ADD/miniseeds.csv")
  combos <-read.csv("I:/_HONOURS_DATA/RESOURCES/ADD/minicombo.csv")
} else if (MODELTYPE == "ODE") {
  seeds <- read.csv("I:/_HONOURS_DATA/RESOURCES/ODE/miniseeds.csv")
  combos <-read.csv("I:/_HONOURS_DATA/RESOURCES/ODE/minicombo.csv")
} else {
  print("Could not locate files - check your model type input!")
}


# ODE FILES ####

#test code only
#transseeds <- read.csv("C:/Users/sknie/github/honours/4_Analysis/transseeds.csv")
#transseeds <- transseeds[,1:2] #trim extra columns

## FILE ONLY LOOP ##
foreach(i=1: (length(combos))) %:%
  foreach(j= seeds$Seed) %do% {
    myFiles <- lapply(Sys.glob(paste0("Val_", j, "_generation_", i, "*.txt")), read.table) #ODE

    #Bigpopa, my hyuge shrimp, says hi
    BIGPOPA <- bind_rows(myFiles, .id = "Generation")
    colnames(BIGPOPA) <- BIGPOPA[1,] #column names
    colnames(BIGPOPA)[1] <- "Generation" #fix one label
    BIGPOPA <- subset(BIGPOPA, AAlpha!= "AAlpha") #remove the labels
    BIGPOPA <-   mutate_all(BIGPOPA, .funs = as.numeric) #turns characters into numerics

    #tetris, my beloved snail, says hi
    TETRIS <- BIGPOPA %>%
      group_by(BIGPOPA$Generation) %>%
      summarise(AAlpha = mean(AAlpha),
                ABeta = mean(ABeta),
                BAlpha = mean(BAlpha),
                BBeta = mean(BBeta),
                AConc = mean(AConc),
                BConc = mean(BConc)
      )
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


## Full Loop with Graphs ##
foreach(i=1:5) %:%
  foreach(j= transseeds$Transseed) %do% {

    #read in all files based on specifications above for all generations
    myFiles <- lapply(Sys.glob(paste0("Val_", j, "_generation_", i, "_*.txt")), read.table)

    #Bigpopa, my hyuge shrimp, says hi
    BIGPOPA <- bind_rows(myFiles, .id = "Generation")
    colnames(BIGPOPA) <- BIGPOPA[1,] #column names
    colnames(BIGPOPA)[1] <- "Generation" #fix one label
    BIGPOPA <- subset(BIGPOPA, AAlpha!= "AAlpha") #remove the labels
    BIGPOPA <-   mutate_all(BIGPOPA, .funs = as.numeric) #turns characters into numerics

    #tetris, my beloved snail, says hi
    TETRIS <- BIGPOPA %>%
      group_by(BIGPOPA$Generation) %>%
      summarise(AAlpha = mean(AAlpha),
                ABeta = mean(ABeta),
                BAlpha = mean(BAlpha),
                BBeta = mean(BBeta),
                AConc = mean(AConc),
                BConc = mean(BConc)
      )
    colnames(TETRIS)[1] <- "Generation"
    TETRIS$SEED <- j
    TETRIS$Index <- i

    ## GRAPH 1: Mean Alpha(A) versus time (line plots and violin plots)
    graph1base <- ggplot(data = TETRIS, aes(x = Generation, y = AAlpha))

    # graph1base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Alpha(A)" )

    #ggsave(paste0("Mean_AlphaA_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # baseplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AAlpha))
    # baseplot3 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Alpha(A)")

    #ggsave(paste0("Mean_AlphaA_violin_onerun",j, "_", i, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph1base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Alpha(A)")

    #ggsave(paste0("Mean_AlphaA_IQR_onerun",j, "_", i, ".png"), device = "png")


    ## GRAPH 2: Mean Beta(A) versus time (line plots and violin plots)
    #only points
    graph2base <- ggplot(data = TETRIS, aes(x = Generation, y = ABeta))
    # graph2base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Beta(A)")

    #ggsave(paste0("Mean_BetaA_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot2 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = ABeta))
    # violinplot2 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Beta(A)")

    #ggsave(paste0("Mean_BetaA_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph2base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Beta(A)")

    #ggsave(paste0("Mean_BetaA_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 3: Mean Alpha(B) versus time (line plots and violin plots)

    #only points
    graph3base <- ggplot(data = TETRIS, aes(x = Generation, y = BAlpha))
    # graph3base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Alpha(B)" )

    #ggsave(paste0("Mean_AlphaB_jitter_onerun",j, "_", i), ".png", device = "png")

    #violin plots
    # violinplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BAlpha))
    # violinplot3 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Alpha(B)")

    #ggsave(paste0("Mean_AlphaB_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph3base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Alpha(B)")

    #ggsave(paste0("Mean_AlphaB_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 4: Mean Beta(B) versus time (line plots and violin plots)

    #only points
    graph4base <- ggplot(data = TETRIS, aes(x = Generation, y = BBeta))
    # graph4base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Beta(B)")

    #ggsave(paste0("Mean_BetaB_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot4 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BBeta))
    # violinplot4 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Beta(B)")

    #ggsave(paste0("Mean_BetaB_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph4base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Beta(A)")

    #ggsave(paste0("Mean_BetaB_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)

    #only points
    graph5base <- ggplot(data = TETRIS, aes(x = Generation, y = AConc))
    # graph5base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("AConc_jitter_onerun",j, "_", i, ".png"), device = "png")


    #violin plots
    violinplot5 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AConc))
    # violinplot5 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("AConc_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph5base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("AConc_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)

    #only points
    graph6base <- ggplot(data = TETRIS, aes(x = Generation, y = BConc))
    # graph6base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean BCONC")

    #ggsave(paste0("BConc_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot6 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
    # violinplot6 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean BCONC")

    #ggsave(paste0("BConc_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph6base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("BConc_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
    # this one is a two part deal:
    # first, calculate fitness:

    BIGPOPA$fitness = exp(-((BIGPOPA$BConc-BOpt)/S)^2);

    TETRIS$fitness <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(fitness= mean(fitness)) %>%
      pull(fitness)

    # then, do the plots
    #only points
    graph7base <- ggplot(data = TETRIS, aes(x = Generation, y = fitness))
    # graph7base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Fitness_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot7 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = fitness))
    # violinplot7 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Fitness_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph7base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("Fitness_IQR_onerun",j, "_", i, ".png"), device = "png")


    ## GRAPH 8: ODE samples from individual runs @ different time points


    #### Beyond the Super 8 Film ####

    #distance from the optima:

    BIGPOPA$distance <- BIGPOPA$BConc-BOpt

    #density plot
    distancebase <- ggplot(BIGPOPA, aes(x = distance, colour = factor(BIGPOPA$Generation)))
    # distancebase +
    #   geom_density() +
    #   theme_classic() +
    #   labs(x = "Distance to the optima", y = "Individuals") +
    #   theme(legend.position = "bottom")

    #ggsave(paste0("Distance_density_onerun",j, "_", i, ".png"), device = "png")

    #mean density?
    TETRIS$distance <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(distance = mean(distance)) %>%
      pull(distance)


    ###potential interfering for save data

    distancebase2 <- ggplot(TETRIS, aes(x = Generation, y = distance))
    # distancebase2 +
    #   geom_point() +
    #   theme_classic() +
    #   labs(x = "Generations", y = "Distance to the optima") +
    #   theme(legend.position = "none")

    #ggsave(paste0("Distance_jitter_onerun",j, "_", i, ".png"), device = "png")


    #facet code cfor nice graphs
    g1 <-
      graph1base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(A)" )
    g2 <-
      graph2base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(A)")
    g3 <-
      graph3base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(B)" )
    g4 <-
      graph4base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(B)")
    g5 <-
      graph5base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean ACONC")
    g6 <-
      graph6base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BCONC")
    g7 <-
      graph7base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")
    # g8 <-
    #   distancebase2 +
    #   geom_point(color = "orchid2") +
    #   geom_line(color = "skyblue1") +
    #   theme_classic() +
    #   labs(x = "Generations", y = "Distance to the optima") +
    #   ylim(-41, -39) +
    #   theme(legend.position = "none")

    lay <- rbind(c(1,1,1,2,2,2,3,3,3,4,4,4),
                 c(5,5,5,5,6,6,6,6,7,7,7,7),
                 c(5,5,5,5,6,6,6,6,7,7,7,7))

    #to plot
    grid.arrange(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)

    #to save
    g <- arrangeGrob(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)
    ggsave(file = paste0("Facet_graphs_onerun_",j, "_", i, ".png"), g, device = "png")

  } #foreach closing bracket







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


## Full Loop featuring graphs for ADD ##
foreach(i=1:2) %:%
  foreach(j= transseeds$Transseed) %do% {

    #read in all files based on specifications above for all generations
    myFiles <- lapply(Sys.glob(paste0("SLiM-output_ADD_", j, "_generation_", i, "*.csv")), read.table)

    #Bigpopa, my hyuge shrimp, says hi (alot of the modifyers comes from ODE files, need separate loops again! )
    BIGPOPA <- bind_rows(myFiles, .id = "Generation")
    colnames(BIGPOPA) <- c("ID", "GeneA1", "GeneA2", "GeneB1", "GeneB2", "AConc", "BGamma", "BConc", "Generation", "Seed") #column names
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


    #mutation data stuff would go here

    ## GRAPH 1: Mean Gene A1 versus time (line plots and violin plots)
    graph1base <- ggplot(data = TETRIS, aes(x = Generation, y = GeneA1))

    # graph1base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A1" )

    #ggsave(paste0("Mean_AlphaA_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # baseplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = GeneA1))
    # baseplot3 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_violin_onerun",j, "_", i, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph1base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_IQR_onerun",j, "_", i, ".png"), device = "png")


    ## GRAPH 2: Mean Gene A2 versus time (line plots and violin plots)
    #only points
    graph2base <- ggplot(data = TETRIS, aes(x = Generation, y = GeneA2))
    # graph2base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot2 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = GeneA2))
    # violinplot2 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph2base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 3: Mean Gene B1 versus time (line plots and violin plots)

    #only points
    graph3base <- ggplot(data = TETRIS, aes(x = Generation, y = GeneB1))
    # graph3base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene B1" )

    #ggsave(paste0("Mean_AlphaB_jitter_onerun",j, "_", i), ".png", device = "png")

    #violin plots
    # violinplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = GeneB1))
    # violinplot3 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph3base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 4: Mean Gene B2 versus time (line plots and violin plots)

    #only points
    graph4base <- ggplot(data = TETRIS, aes(x = Generation, y = GeneB2))
    # graph4base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot4 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = GeneB2))
    # violinplot4 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph4base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaB_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)

    #only points
    graph5base <- ggplot(data = TETRIS, aes(x = Generation, y = AConc))
    # graph5base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("AConc_jitter_onerun",j, "_", i, ".png"), device = "png")


    #violin plots
    violinplot5 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AConc))
    # violinplot5 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("AConc_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph5base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("AConc_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)

    #only points
    graph6base <- ggplot(data = TETRIS, aes(x = Generation, y = BConc))
    # graph6base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean BCONC")

    #ggsave(paste0("BConc_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot6 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
    # violinplot6 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean BCONC")

    #ggsave(paste0("BConc_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph6base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("BConc_IQR_onerun",j, "_", i, ".png"), device = "png")

    ## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
    # this one is a two part deal:
    # first, calculate fitness:

    BIGPOPA$fitness = exp(-((BIGPOPA$BConc-BOpt)/S)^2);

    TETRIS$fitness <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(fitness= mean(fitness)) %>%
      pull(fitness)

    # then, do the plots
    #only points
    graph7base <- ggplot(data = TETRIS, aes(x = Generation, y = fitness))
    # graph7base +
    #   geom_point(position = "jitter") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Fitness_jitter_onerun",j, "_", i, ".png"), device = "png")

    #violin plots
    # violinplot7 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = fitness))
    # violinplot7 +
    #   geom_violin() +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Fitness_violin_onerun",j, "_", i, ".png"), device = "png")

    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    # graph7base +
    #   geom_quantile(color = "salmon") +
    #   geom_line(colour = "lightblue") +
    #   geom_smooth(colour = "lavender") +
    #   theme_classic() +
    #   labs(x = "Generation", y = "Mean ACONC")

    #ggsave(paste0("Fitness_IQR_onerun",j, "_", i, ".png"), device = "png")


    ## GRAPH 8: ODE samples from individual runs @ different time points


    #### Beyond the Super 8 Film ####

    #distance from the optima:

    BIGPOPA$distance <- BIGPOPA$BConc-BOpt

    #density plot
    distancebase <- ggplot(BIGPOPA, aes(x = distance, colour = factor(BIGPOPA$Generation)))
    # distancebase +
    #   geom_density() +
    #   theme_classic() +
    #   labs(x = "Distance to the optima", y = "Individuals") +
    #   theme(legend.position = "bottom")

    #ggsave(paste0("Distance_density_onerun",j, "_", i, ".png"), device = "png")

    #mean density?
    TETRIS$distance <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(distance = mean(distance)) %>%
      pull(distance)


    ###potential interfering for save data

    distancebase2 <- ggplot(TETRIS, aes(x = Generation, y = distance))
    # distancebase2 +
    #   geom_point() +
    #   theme_classic() +
    #   labs(x = "Generations", y = "Distance to the optima") +
    #   theme(legend.position = "none")

    #ggsave(paste0("Distance_jitter_onerun",j, "_", i, ".png"), device = "png")


    #facet code cfor nice graphs
    g1 <-
      graph1base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )
    g2 <-
      graph2base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")
    g3 <-
      graph3base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )
    g4 <-
      graph4base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")
    g5 <-
      graph5base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean ACONC")
    g6 <-
      graph6base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BCONC")
    g7 <-
      graph7base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")
    # g8 <-
    #   distancebase2 +
    #   geom_point(color = "orchid2") +
    #   geom_line(color = "skyblue1") +
    #   theme_classic() +
    #   labs(x = "Generations", y = "Distance to the optima") +
    #   ylim(-41, -39) +
    #   theme(legend.position = "none")

    lay <- rbind(c(1,1,1,2,2,2,3,3,3,4,4,4),
                 c(5,5,5,5,6,6,6,6,7,7,7,7),
                 c(5,5,5,5,6,6,6,6,7,7,7,7))

    #to plot
    grid.arrange(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)

    #to save
    g <- arrangeGrob(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)
    ggsave(file = paste0("Facet_graphs_onerun_",j, "_", i, ".png"), g, device = "png")




    #SAVE CODE

    #for the graphs is under the actual graph code

  } #foreach closing bracket


### mutation code in the making ####

i <- 1
j<- seeds$Seed[1]


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
    base + geom_col(position = "stack")




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



  }

 #ideas for collapsing

    #number of mutations in gen
    #histogram of effect size bins by generation and distribution? subset here?
    #same loop for fixed gens
    #plot mean effect size for polymorphs and fixed as a line over gens?

    #histogram of mutational effect sizes (stacked for polymorphs and fixed)

    #distribution of effect sizes (half violin plots)

    #subset by region plot mean prevalence by region histograms or boxplots

    #subset by region plot selection coefficients x prevalence with color for regions (histogram!)
