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
#ODE VERSION

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


    #### make the plots ####
    #violin plots will make more sense than line plots i reckon

    ## GRAPH 1: Mean Gene A1 versus time (line plots and violin plots)
    #only points
    graph1base <- ggplot(data = SHELLDON, aes(x = Generation, y = GeneA1))
    graph1base +
      geom_point(color = "grey", position = "jitter") +
      geom_line(data = RICHARD, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )

    #ggsave(paste0("Mean_AlphaA_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin1 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = GeneA1))
    violin1 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph1base +
      # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1")

    #ggsave(paste0("Mean_AlphaA_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 2: Mean Gene A2 versus time (line plots and violin plots)
    #only points
    graph2base <- ggplot(data = SHELLDON, aes(x = Generation, y = GeneA2))
    graph2base +
      geom_point(color = "grey") +
      geom_line(data = RICHARD, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2" )

    #ggsave(paste0("Mean_BetaA_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin2 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = GeneA2))
    violin2 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph2base +
      geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")

    #ggsave(paste0("Mean_BetaA_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 3: Mean Gene B1 versus time (line plots and violin plots)
    #only points
    graph3base <- ggplot(data = SHELLDON, aes(x = Generation, y = GeneB1))
    graph3base +
      geom_point(color = "grey") +
      geom_point(data = RICHARD,  color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )

    #ggsave(paste0("Mean_AlphaB_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin3 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = GeneB1))
    violin3 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph3base +
      geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1")

    #ggsave(paste0("Mean_AlphaB_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 4: Mean Gene B2 versus time (line plots and violin plots)
    #only points
    graph4base <- ggplot(data = SHELLDON, aes(x = Generation, y = GeneB2))
    graph4base +
      geom_point(color = "grey") +
      geom_line(data = RICHARD, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2" )

    #ggsave(paste0("Mean_BetaB_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin4 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = GeneB2))
    violin4 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph4base +
      geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")

    #ggsave(paste0("Mean_BetaB_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)
    #only points
    graph5base <- ggplot(data = SHELLDON, aes(x = Generation, y = AConc))
    graph5base +
      geom_point(color = "grey") +
      geom_line(data = RICHARD, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc" )

    #ggsave(paste0("Mean_AConc_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin5 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = AConc))
    violin5 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")

    #ggsave(paste0("Mean_AConc_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph5base +
      geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")

    #ggsave(paste0("Mean_AConc_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)
    #only points
    graph6base <- ggplot(data = SHELLDON, aes(x = Generation, y = BConc))
    graph6base +
      geom_point(color = "grey") +
      geom_line(data = RICHARD, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc" )

    #ggsave(paste0("Mean_BConc_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin6 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = BConc))
    violin6 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")

    #ggsave(paste0("Mean_BConc_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph6base +
      geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")

    #ggsave(paste0("Mean_BConc_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
    graph7base <- ggplot(data = SHELLDON, aes(x = Generation, y = fitness))
    graph7base +
      geom_point(color = "grey") +
      geom_point(data = RICHARD, x = RICHARD$Generation,  y = RICHARD$fitness, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness" )

    #ggsave(paste0("Mean_Fitness_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin7 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = fitness))
    violin7 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Mean_Fitness_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph7base +
      geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")

    #ggsave(paste0("Mean_Fitness_lines_acrossseeds",i, "_", l, ".png"), device = "png")


    ## GRAPH 8*: distance from the optima
    graph8base <- ggplot(data = SHELLDON, aes(x = Generation, y = distance))
    graph8base +
      geom_point(color = "grey") +
      geom_line(data = RICHARD, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima" )

    #ggsave(paste0("Mean_distance_jitter_acrossseeds",i, "_", l, ".png"), device = "png")


    #violin plots
    violin8 <- ggplot(data = SHELLDON, aes(x = factor(Generation), y = fitness))
    violin8 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")

    #ggsave(paste0("Mean_distance_violin_acrossseeds",i, "_", l, ".png"), device = "png")


    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph8base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = RICHARD, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")

    #ggsave(paste0("Mean_distance_lines_", MODELTYPE, "_", OPTIMA,".png"), device = "png")


    #facet code
    g1 <-
      graph1base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A1" )
    g2 <-
      graph2base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene A2")
    g3 <-
      graph3base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B1" )
    g4 <-
      graph4base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Gene B2")
    g5 <-
      graph5base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean ACONC")
    g6 <-
      graph6base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BCONC")
    g7 <-
      graph7base +
      geom_point(position = "jitter", color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")
    g8 <-
      graph8base +
      geom_point(color = "orchid2") +
      geom_line(data = RICHARD, color = "skyblue1") +
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
    ggsave("Facetted_graphs_acrossreps_test.png")

    #nice adaptive walk graph
    adaptivewalkbase <- ggplot()
    adaptivewalkbase +
      geom_line(data = SHELLDON, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
      geom_line(data = RICHARD, aes( x = Generation, y = BConc), color = "red") +
      theme_classic() +
      guides(fill = "none") +
      labs(x = "Generation", y = "Mean BConc" )

    ggsave(paste0("Adaptive Walk_", MODELTYPE, "_", OPTIMA,".png"), device = "png")


} #foreach loop ends here
