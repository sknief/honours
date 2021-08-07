######################################################
# R CODE FOR ODE MODELS [Hill Function Debug]   #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################

library(deSolve)
library(tibble)
library(dplyr)
library(DescTools)


#for parallel purposes
args <- commandArgs(trailingOnly = TRUE)
if ( length(args) < 2 ) {
  cat("Need 2 command line parameters i.e. SEED, PAR\n")
  q()
}

parallelseed     <- as.numeric(args[1])
modelindex    <- as.numeric(args[2])



###

#### Part 1. read in filVersVersVersVersVerse, format and potentially clean #################################################################
params <- read.csv(paste0("/scratch/user/s4471959/ODE_Neutral/TEST2/SLiM-output_", parallelseed, "_", modelindex, ".csv"), header = FALSE, sep = ",", dec = ".")

#trim generation + seed out
#store as values
gen <- as.numeric(unique(params[6][1]))
seed <- as.numeric(unique(params[7][1][1]))


#trim
params[7] <- NULL
params[6] <- NULL

colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta")

#debug feature
print(head(params))

####  Part 2. calculate ODE values ########################################################################################
#Freya depends on a Hill Function
Freya <-function(t, state, parameters) {
  with(as.list(c(state,parameters)), {
    dA <- Abeta * (t > Xstart && t <= Xstop) * 1/(1 + A^Hilln) - Aalpha*A
     dB <- Bbeta * A^Hilln/(Bthreshold^Hilln + A^Hilln) - Balpha*B
    list(c(dA, dB))
  })
}




#Values for the ODE to come
state <- c(A = 0, B = 0)
times <- seq(0, 10, by = 0.1)

#introduce tidyverse and nesting abilities
raw_dat <- as_tibble(params)

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
                                                Bthreshold = 0.2,
                                                Hilln = 100))) %>%
                          mutate_all(.funs = as.numeric)))

#base loops for the AUC functions
dat$integral_out = 0
dat$integral_outt = for (h in 1:length(dat$ID)) {
  dat$integral_out[h] = (AUC(dat[[6]][[h]]$time,
                             dat[[6]][[h]]$B,
                             absolutearea = TRUE))
}
#same again to get a value for A
dat$A_out = 0
dat$A_outt = for (h in 1:length(dat$ID)) {
  dat$A_out[h] = (AUC(dat[[6]][[h]]$time,
                      dat[[6]][[h]]$A,
                      absolutearea = TRUE))
}

#debugfeature
print("heres the new values apparently")
print(head(dat))

### Part 3. save that into MULTIPLE singleton files ####################################################################################
#luna is the things to keep and parse to slim


luna <- as.data.frame(x = cbind(dat$ID, dat$integral_out, dat$A_out), col.names = names(c("Index", "BConc", "Aconc")))

luna[is.na(luna)] <- 0

write.table(luna, paste0("/scratch/user/s4471959/ODE_Neutral/TEST2/ODEoutput_", parallelseed, "_", modelindex,  ".txt"),
            append = FALSE,
            row.names = FALSE,
            col.names = FALSE)

#val is the savepoint of all data for the records

val <- as.data.frame(x = cbind(dat$ID,
                               dat$Aalpha,
                               dat$Abeta,
                               dat$Balpha,
                               dat$Bbeta,
                               dat$integral_out,
                               dat$A_out))
colnames(val) = c("Index",
                  "AAlpha",
                  "ABeta",
                  "BAlpha",
                  "BBeta",
                  "BConc",
                  "AConc")


valname <- paste("/scratch/user/s4471959/ODE_Neutral/TEST2/Val_",seed,"_generation_",gen,".txt")

write.table(val, valname,
            append = FALSE,
            row.names = FALSE,
            col.names = TRUE)
