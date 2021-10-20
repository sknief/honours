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
REP <- 1
########################################################

### Set WD ####
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("/scratch/user/s4471959/", MODELTYPE, "_", OPTIMA, "/Mini", REP , "/state/partition1/pbs/tmpdir/pbs.", WD, ".tinmgr2")
setwd(workdirectory)

### mutation code in the making ####

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

#subset by region plot selection coefficients x prevalence with color for regions (histogram!)
