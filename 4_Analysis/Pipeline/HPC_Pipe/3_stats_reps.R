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
MODELTYPE <- "ODE"
OPTIMA <- "Neutral"
#########################################################

####  set WD to tank #####
workdirectory <- paste0("C:/Users/sknie/github/honours/4_Analysis/", MODELTYPE, "/", OPTIMA, "/tank")
setwd(workdirectory)

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
  seeds <- read.csv("C:/Users/sknie/github/honours/3_HPC/OutbackRuns/ADD/seeds.csv")
  index <- 1:25
} else if (MODELTYPE == "ODE") {
  seeds <- read.csv("C:/Users/sknie/github/honours/3_HPC/OutbackRuns/ODE/seeds.csv")
  index <- 1:5
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


## THE BIG LOOP INCL GRAPHS FOR ODE ##

foreach(i=1:length(index)) %:% #modelindex, should be 1-5 in the ODE and 1:25 in ADD, can be looped!
  foreach(l = 1:4) %do% { #1:4 never changes


    #this gives me all seeds (*) for a given combination of node and index
    myBigPopas <- lapply(Sys.glob(paste0("BigPopa_onerun_*_", i, "_node_", l, ".csv")), read.table) #individual data
    myTetri <- lapply(Sys.glob(paste0("Tetris_onerun_*_", i, "_node_", l, ".csv")), read.table) #one entry per generation

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


    ###generate the same graphs as before, but with overlay (need bigpopa files for that)
    ## GRAPH 1: Mean Gene A1 versus time (line plots and violin plots)
    #only points
    graph1base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneA1))
    graph1base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneA1, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )

    #ggsave(paste0("Mean_AlphaA_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin1 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneA1))
    violin1 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph1base +
     # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 2: Mean Gene A2 versus time (line plots and violin plots)
    #only points
    graph2base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneA2))
    graph2base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneA2, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2" )

    #ggsave(paste0("Mean_BetaA_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin2 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneA2))
    violin2 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph2base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 3: Mean Gene B1 versus time (line plots and violin plots)
    #only points
    graph3base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneB1))
    graph3base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneB1, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )

    #ggsave(paste0("Mean_AlphaB_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin3 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneB1))
    violin3 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph3base +
      # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 4: Mean Gene B2 versus time (line plots and violin plots)
    #only points
    graph4base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneB2))
    graph4base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneB2, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2" )

    #ggsave(paste0("Mean_BetaB_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin4 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneB2))
    violin4 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph4base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)
    #only points
    graph5base <- ggplot(data = POGNOODLE, aes(x = Generation, y = AConc))
    graph5base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$AConc, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc" )

    #ggsave(paste0("Mean_AConc_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin5 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = AConc))
    violin5 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")

    #ggsave(paste0("Mean_AConc_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph5base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")

    #ggsave(paste0("Mean_AConc_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)
    #only points
    graph6base <- ggplot(data = POGNOODLE, aes(x = Generation, y = BConc))
    graph6base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$BConc, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc" )

    #ggsave(paste0("Mean_BConc_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin6 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = BConc))
    violin6 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")

    #ggsave(paste0("Mean_BConc_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph6base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")

    #ggsave(paste0("Mean_BConc_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
    graph7base <- ggplot(data = POGNOODLE, aes(x = Generation, y = fitness))
    graph7base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$fitness, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness" )

    #ggsave(paste0("Mean_Fitness_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin7 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = fitness))
    violin7 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Mean_Fitness_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph7base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Mean_Fitness_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 8*: distance from the optima
    graph8base <- ggplot(data = POGNOODLE, aes(x = Generation, y = distance))
    graph8base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$distance, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima" )

    #ggsave(paste0("Mean_distance_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin8 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = fitness))
    violin8 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")

    #ggsave(paste0("Mean_distance_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph8base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")

    #ggsave(paste0("Mean_distance_lines_acrossseeds",i, "_", l, ".png"), device = "png")



    #facet code
    g1 <-
      graph1base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )
    g2 <-
      graph2base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")
    g3 <-
      graph3base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )
    g4 <-
      graph4base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")
    g5 <-
      graph5base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean ACONC")
    g6 <-
      graph6base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BCONC")
    g7 <-
      graph7base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")
    g8 <-
      graph8base +
      geom_point(color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generations", y = "Distance to the optima") +
      ylim(-41, -39) +
      theme(legend.position = "none")

    lay <- rbind(c(1,1,1,2,2,2,3,3,3,4,4,4),
                 c(5,5,5,5,6,6,6,6,7,7,7,7),
                 c(5,5,5,5,6,6,6,6,7,7,7,7))

    #to plot
    grid.arrange(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)

    #to save
    g <- arrangeGrob(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)
    ggsave(file = paste0("Facet_graphs_acrossreps_",j, "_", i, ".png"), g, device = "png")

   g8

    #Save code for all three datasets, regardless of use
    #PogNoodle
    pognood <- as.character(paste0("PogNoodle_(reps_for_unique_combo)_", i, "_node_", l,  ".csv"))

    PogNoodle <- as.data.frame(POGNOODLE)

    write.table(PogNoodle, pognood,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #PogNoodled
    pognoodled <- as.character(paste0("PogNoodled_(mean_across_seeds)_", i, "_node_", l,  ".csv"))

    PogNoodled <- as.data.frame(POGNOODLED)

    write.table(PogNoodled, pognoodled,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #ShrimpMoult
    moultyshrimp <- as.character(paste0("ShrimpMoult_(all_individuals)_", i, "_node_", l,  ".csv"))

    ShrimpMoult <- as.data.frame(SHRIMPMOULT)

    write.table(ShrimpMoult, moultyshrimp,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

} #foreach end loop

#Big ADD loop, including GRAPHS
foreach(i=1:length(index)) %:% #modelindex, should be 1-5 in the ODE and 1:25 in ADD, can be looped!
  foreach(l = 1:4) %do% { #1:4 never changes

    #this gives me all seeds (*) for a given combination of node and index
    myBigPopas <- lapply(Sys.glob(paste0("BigPopa_onerun_*_", i, "_node_", l, ".csv")), read.table) #individual data
    myTetri <- lapply(Sys.glob(paste0("Tetris_onerun_*_", i, "_node_", l, ".csv")), read.table) #one entry per generation

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


    ###generate the same graphs as before, but with overlay (need bigpopa files for that)
    ## GRAPH 1: Mean Gene A1 versus time (line plots and violin plots)
    #only points
    graph1base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneA1))
    graph1base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneA1, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )

    #ggsave(paste0("Mean_AlphaA_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin1 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneA1))
    violin1 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph1base +
     # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 2: Mean Gene A2 versus time (line plots and violin plots)
    #only points
    graph2base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneA2))
    graph2base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneA2, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2" )

    #ggsave(paste0("Mean_BetaA_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin2 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneA2))
    violin2 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph2base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 3: Mean Gene B1 versus time (line plots and violin plots)
    #only points
    graph3base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneB1))
    graph3base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneB1, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )

    #ggsave(paste0("Mean_AlphaB_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin3 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneB1))
    violin3 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph3base +
      # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 4: Mean Gene B2 versus time (line plots and violin plots)
    #only points
    graph4base <- ggplot(data = POGNOODLE, aes(x = Generation, y = GeneB2))
    graph4base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$GeneB2, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2" )

    #ggsave(paste0("Mean_BetaB_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin4 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = GeneB2))
    violin4 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph4base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)
    #only points
    graph5base <- ggplot(data = POGNOODLE, aes(x = Generation, y = AConc))
    graph5base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$AConc, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc" )

    #ggsave(paste0("Mean_AConc_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin5 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = AConc))
    violin5 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")

    #ggsave(paste0("Mean_AConc_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph5base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")

    #ggsave(paste0("Mean_AConc_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)
    #only points
    graph6base <- ggplot(data = POGNOODLE, aes(x = Generation, y = BConc))
    graph6base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$BConc, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc" )

    #ggsave(paste0("Mean_BConc_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin6 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = BConc))
    violin6 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")

    #ggsave(paste0("Mean_BConc_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph6base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")

    #ggsave(paste0("Mean_BConc_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
    graph7base <- ggplot(data = POGNOODLE, aes(x = Generation, y = fitness))
    graph7base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$fitness, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness" )

    #ggsave(paste0("Mean_Fitness_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin7 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = fitness))
    violin7 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Mean_Fitness_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph7base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Mean_Fitness_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 8*: distance from the optima
    graph8base <- ggplot(data = POGNOODLE, aes(x = Generation, y = distance))
    graph8base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$distance, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima" )

    #ggsave(paste0("Mean_distance_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin8 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = fitness))
    violin8 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")

    #ggsave(paste0("Mean_distance_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph8base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")

    #ggsave(paste0("Mean_distance_lines_acrossseeds",i, "_", l, ".png"), device = "png")



    #facet code
    g1 <-
      graph1base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )
    g2 <-
      graph2base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")
    g3 <-
      graph3base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )
    g4 <-
      graph4base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")
    g5 <-
      graph5base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean ACONC")
    g6 <-
      graph6base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BCONC")
    g7 <-
      graph7base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")
    g8 <-
      graph8base +
      geom_point(color = "orchid2") +
      geom_line(data = POGNOODLED, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generations", y = "Distance to the optima") +
      ylim(-41, -39) +
      theme(legend.position = "none")

    lay <- rbind(c(1,1,1,2,2,2,3,3,3,4,4,4),
                 c(5,5,5,5,6,6,6,6,7,7,7,7),
                 c(5,5,5,5,6,6,6,6,7,7,7,7))

    #to plot
    grid.arrange(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)

    #to save
    g <- arrangeGrob(g1, g2, g3, g4, g5, g6, g7, layout_matrix = lay)
    ggsave(file = paste0("Facet_graphs_acrossreps_",j, "_", i, ".png"), g, device = "png")

   g8

    #Save code for all three datasets, regardless of use
    #PogNoodle
    pognood <- as.character(paste0("PogNoodle_(reps_for_unique_combo)_", i, "_node_", l,  ".csv"))

    PogNoodle <- as.data.frame(POGNOODLE)

    write.table(PogNoodle, pognood,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #PogNoodled
    pognoodled <- as.character(paste0("PogNoodled_(mean_across_seeds)_", i, "_node_", l,  ".csv"))

    PogNoodled <- as.data.frame(POGNOODLED)

    write.table(PogNoodled, pognoodled,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #ShrimpMoult
    moultyshrimp <- as.character(paste0("ShrimpMoult_(all_individuals)_", i, "_node_", l,  ".csv"))

    ShrimpMoult <- as.data.frame(SHRIMPMOULT)

    write.table(ShrimpMoult, moultyshrimp,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

} #foreach end loop

#### mutation code in the making ####

mutations <- read_table2(paste0("SLiMulation_Output_Full_", j, "_", i ,".txt"),
                         col_names = FALSE, skip = 5)
#take out non mutation data
mutations <- na.omit(mutations)
colnames(mutations) <- c("WithinFileID", "MutationID", "Type", "Position", "SelectionCoeff", "DomCoeff", "Population", "GenOrigin", "Prevalence1000")
mutations <- mutations[c(2:5, 8:9)] #take out unnecessary columns

#these will need to be collated and averaged

#fixed mutations (no test data for that yet)
fixed <- read_table2(paste0("SLiMulation_Output_FixedMutations_", j, "_", i ,".txt"),
                     col_names = FALSE, skip = 2)
#take out non mutation data
fixed <- na.omit(fixed)
colnames(fixed) <- c("WithinFileID", "MutationID", "Type", "Position", "SelectionCoeff", "DomCoeff", "Population", "GenOrigin", "FixedinGen")
fixed <- fixed[c(2:5, 8:9)] #take out unnecessary columns

#graphs

#histogram of mutational effect sizes (stacked for polymorphs and fixed)

#distribution of effect sizes (half violin plots)

#subset by region plot mean prevalence by region histograms or boxplots

#subset by region plot selection coefficients x prevalance with color for regions (histogram!)
