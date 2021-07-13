######################################################
# R CODE FOR ODE MODELS [Step version a la Daniel]   #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################
# The functions used here are those given by Daniel in his e-mail "ODE evolution"

#install.packages("deSolve")
#install.packages("tidyverse")
#install.packages("DescTools")

library(deSolve)
library(tidyverse)
library(DescTools)

#### 1. read in file, format and potentially clean ######

#UBUNTU:params <- read.csv("/home/stella/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#WINDOWS:
params <- read.csv(file = "/Users/sknie/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")

#debug note:
params$K <- runif(1000, 0, 3)


colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta", "K")

#### 2. calculate ODE values ###########################

#the ODE function (here based on a step function)
Sylvia <-function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    dA <- (ThetaK * Aalpha - Abeta * A)
    dB <- (Balpha - Bbeta*A)
    list(c(dA, dB))
  })
}

#this is what defined your threshold
params$ThetaK <- 0

params$TK <- {
  for(i in 1:length(params$K)) {
  if (params$K[i] < 1) {
     params$ThetaK[i] = 1}
  else {
    params$ThetaK[i] = 0}
  }
}


params$ODEout <- 0
state <- c(A = 1, B = 1)
times <- seq(0, 100, by = 1)


# FIXED SOLUTIONS
raw_dat <- as_tibble(params)
            #  ode_out = nest(showjack))

dat <- raw_dat %>%
  rowwise() %>%
  mutate(ode_out = nest(as_tibble(ode(y = state,
                                      times = times,
                                      func = Sylvia,
                                      parms = c(Aalpha = Aalpha,
                                                Abeta = Abeta,
                                                Balpha = Balpha,
                                                Bbeta = Bbeta,
                                                ThetaK = ThetaK))) %>%
                          mutate_all(.funs = as.numeric)))


smalldat <- head(dat)


dat2 <- smalldat %>%
  rowwise() %>%
    mutate(integral_out = list(map(.x = seq(from = 1, to = 6, by = 1),
                              .f = ~ AUC(smalldat$ode_out[[1]][[.x]]$time, smalldat$ode_out[[1]][[.x]]$B,
                                         from = 0, to = 100, absolutearea = TRUE))))
#from the console
dat2 <- smalldat %>%
  +     mutate(integral_out = list(map(.x = seq(from = 1, to = 6, by = 1),
                                       +                               .f = ~ AUC(smalldat$ode_out[[1]][[.x]]$time, smalldat$ode_out[[1]][[.x]]$B,
                                                                                  +                                          from = 0, to = 100, absolutearea = TRUE))))


#integral trial code section
integral_out = integrate(f = (approxfun(unnest(dat$ode_out, cols = c(time, B)))),
                         lower = range(range(times)[1]),
                         upper = range(range(times)[2])
                          )


#how to refer to things within that big bracket tmrw:
.$ode_out[[1]][[1]]$time

### 3. save that into MULTIPLE singleton files ########

#This sections needs to be modified with the actual output content, rn its just the functional skeleton
# ie change the variable names thats all.

individualid <- params$ID
outputA <- dat$Bbeta
outputA <- data.frame(cbind(individualid, outputA))
NodeAOutput <- write.table(outputA, "NodeAoutput.txt")

outputB <- as.matrix(outputB)
outputB <- data.frame(cbind(individualid, outputB))
NodeBOutput <- write.csv((c(individualid, outputB)), "NodeBoutput.csv")
#note: make output code tighter, plus trim header, just internet is down atm


###################################################################
para <- c(
  ThetaK = params$ThetaK,
  Aalpha = params$Aalpha,
  Abeta = params$Abeta,
  Balpha = params$Balpha,
  Bbeta = params$Bbeta)

#testing section
parameters <- c(ThetaK = params$ThetaK[3],
                Aalpha = params$Aalpha[3],
                Abeta = params$Abeta[3],
                Balpha = params$Balpha[3],
                Bbeta = params$Bbeta[3])
print(parameters)
state <- c(A = 1, B = 1)
times <- seq(0, 100, by = 1)


showjack <- as_tibble(ode(y = state,
                          times = times,
                          func = Sylvia,
                          parms = params))
