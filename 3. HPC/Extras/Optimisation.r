######################################################
# R CODE FOR ODE MODELS Optim                        #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################

library(deSolve)
library(tidyverse)
library(DescTools)

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

param <- read.csv("/Users/sknie/github/honours/NAR/_HPC/Extras/Latinhypercube_100.csv")
param[6] <- NULL
param[5] <- 100





raw_dat <- as_tibble(param)

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
                                                Hilln = Hilln)))
              %>%
                mutate_all(.funs = as.numeric)))


dat$integral_out = 0
dat$integral_outt = for (h in 1:length(dat$Aalpha)) {
  dat$integral_out[h] = (AUC(dat[[6]][[h]]$time,
                             dat[[6]][[h]]$B,
                             absolutearea = TRUE))
}

dat

plot(dat$integral_out)
mean(dat$integral_out)

plot(x = dat[[2]][[1]]$time, y = dat[[2]][[1]]$B)
plot(x = dat[[2]][[1]]$time, y = dat[[2]][[1]]$A)


#same again to get a value for A
dat$A_out = 0
dat$A_outt = for (h in 1:length(dat$ID)) {
  dat$A_out[h] = (AUC(dat[[7]][[h]]$time,
                      dat[[7]][[h]]$A,
                      absolutearea = TRUE))
}
