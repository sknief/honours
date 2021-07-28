######################################################
# R CODE FOR ODE Optimisation (not to be run on HPC) #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################

library(deSolve)
library(tidyverse)
library(DescTools)

setwd("~/Documents/SLiM-Workhorse")

#### Part 1. read in file, format and potentially clean #################################################################

#UBUNTU:params <- read.csv("~/Documents/SLiM-Workhorse/SLiM-output.csv", header = FALSE, sep = ",", dec = ".")
#WINDOWS:params <- read.csv(file = "/Users/sknie/Documents/SLiM-Workhorse/SLiM-output.csv", header = FALSE, sep = ",", dec = ".")

#trim generation + seed out
#store as values
gen <- as.numeric(unique(params[7][1]))
seed <- as.numeric(unique(params[8][1][1]))


#trim
params[8] <- NULL
params[7] <- NULL

colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta", "Hilln")

####  Part 2. calculate ODE values ########################################################################################

#Sylvia is based on a step function
#Sylvia <-function(t, state, parameters) {
#  with(as.list(c(state, parameters)), {
#    dA <- (ThetaK * Aalpha - Abeta * A)
#    dB <- (Balpha - Bbeta*A)
#    list(c(dA, dB))
#  })
#}

#these lines are not needed unless you use Sylvia
#Turn K into the threshold value (from K to ThetaK)
#params$ThetaK <- 0

#params$TK <- {  #TK is not a part of the dataset, it is just a dummy variable
#  for(i in 1:length(params$K)) {
#    if (params$K[i] < 1) {
#      params$ThetaK[i] = 1}
#    else {
#      params$ThetaK[i] = 0}
#  }
#}


#Freya depends on a Hill Function
Freya <-function(t, state, parameters) {
  with(as.list(c(state,parameters)), {
    dA <- Abeta * (t > Xstart && t <= Xstop) * 1/(1 + A^Hilln) - Aalpha*A
    dB <- Bbeta * (A > Bthreshold && A <= Bthreshold )  - Balpha*B
    list(c(dA, dB))
  })
}


#Values for the ODE to come
state <- c(A = 10, B = 10)
times <- seq(0, 10, by = 1)

#introduce tidyverse and nesting abilities
raw_dat <- as_tibble(params)

########################################################################################################

#optimisation code comes in here:
#blindcoded as of now
solution <- ode(y = state,
                times = times,
                func = Freya,
                parms = c(Aalpha = raw_dat$Aalpha[1],
                          Abeta = raw_dat$Abeta[1],
                          Balpha = raw_dat$Balpha[1],
                          Bbeta = raw_dat$Bbeta[1],
                          Xstart = 1,
                          Xstop = 6,
                          Bthreshold = 5,
                          Hilln = raw_dat$Hilln[1]))

sampleTimes <- seq(0, 100, by = 5)
samples <- solution[solution[,"time"] %in% sampleTimes,]
set.seed(1)
samples[,"B"] <- round(samples[,"B"] * exp(rnorm(length(sampleTimes), sd = 0.02)))

#see if this looks decent
plot(solution, xlab = "time", ylab = "Trait", main = "")

#this should work?? I THINK??
anna <- function(parameters) {
              solution <- ode(y = state,
                              times = times,
                              func = Freya,
                              parms = c(Aalpha = raw_dat$Aalpha[1],
                                        Abeta = raw_dat$Abeta[1],
                                        Balpha = raw_dat$Balpha[1],
                                        Bbeta = raw_dat$Bbeta[1],
                                        Xstart = 1,
                                        Xstop = 6,
                                        Bthreshold = 5,
                                        Hilln = raw_dat$Hilln[1]))

              integral_out = (AUC(solution$time,
                                    solution$B,
                                    absolutearea = TRUE))

              return(integral_out)
}

opt <- optim(c(Aalpha = 20,
              Abeta = 50,
              Hilln = 10,
              Balpha = 10,
              Bbeta = 15), anna, method="L-BFGS-B")

opt

#########################################################################################################################

#ODE-OUT contains nested tibbles with the ODE-output, which is saved as.numeric so that it remains attribute-free data
dat <- raw_dat %>%
  rowwise() %>%
  mutate(ode_out = list(as_tibble(ode(y = state,
                                      times = times,
                                      func = Freya,
                                      parms = c(Aalpha = Aalpha,
                                                Abeta = Abeta,
                                                Balpha = Balpha,
                                                Bbeta = Bbeta,
                                                Xstart = 1,
                                                Xstop = 6,
                                                Bthreshold = 5,
                                                Hilln = Hilln))) %>%
                          mutate_all(.funs = as.numeric)))

#base loops for the AUC functions
dat$integral_out = 0
dat$integral_outt = for (h in 1:length(dat$ID)) {
  dat$integral_out[h] = (AUC(dat[[7]][[h]]$time,
                             dat[[7]][[h]]$B,
                             absolutearea = TRUE))
}

#same again to get a value for A
dat$A_out = 0
dat$A_outt = for (h in 1:length(dat$ID)) {
  dat$A_out[h] = (AUC(dat[[7]][[h]]$time,
                             dat[[7]][[h]]$A,
                             absolutearea = TRUE))
}
### Part 3. save that into MULTIPLE singleton files ####################################################################################
#luna is the things to keep and parse to slim


luna <- as.data.frame(x = cbind(dat$ID, dat$integral_out, dat$A_out), col.names = names(c("Index", "BConc", "Aconc")))

luna[is.na(luna)] <- 0

write.table(luna, "ODEoutput.txt",
            append = FALSE,
            row.names = FALSE,
            col.names = FALSE)

#val is the savepoint of all data for the records

val <- as.data.frame(x = cbind(dat$ID,
                               dat$Aalpha,
                               dat$Abeta,
                               dat$Balpha,
                               dat$Bbeta,
                               dat$Hilln,
                               dat$integral_out,
                               dat$A_out))
colnames(val) = c("Index",
                  "AAlpha",
                  "ABeta",
                  "BAlpha",
                  "BBeta",
                  "Hilln",
                  "BConc",
                  "AConc")


valname <- paste("Val_",seed,"_generation_",gen)

write.table(val, valname,
            append = FALSE,
            row.names = FALSE,
            col.names = TRUE)