######################################################
#     R CODE FOR DETERMINING NAR_ADD_Model PARAMS    #
#    Author: SMS Knief       Date: 02/07/21          #
######################################################

sylvialunafreyavalannabygate <- function(BOpt, AbetaINI, AalphaINI, BbetaINI,BalphaINI, S, x) {
  mut1 <- sum(rnorm(x, mean = 0, sd = 0.5))
  mut2 <- sum(rnorm(x, mean = 0, sd = 0.5))
  mut3 <- sum(rnorm(x, mean = 0, sd = 0.5))
  mut4 <- sum(rnorm(x, mean = 0, sd = 0.5))
  #alpha code
  Aalpha <- AalphaINI + (mut1 * AalphaINI)
  Abeta <- AbetaINI  + (mut2 * AbetaINI)
  AConc <- Abeta - Aalpha
  #beta code
  Balpha <- BalphaINI + (mut3 * BalphaINI)
  Bbeta <- BbetaINI + (mut4 * BbetaINI)
  BConc <- (Bbeta - Balpha)*AConc
  #fitnesscode
  fitnessfunction <- exp(-((BConc-BOpt)/S)^2)
  #detective code
  plot(fitnessfunction)
  print(fitnessfunction)
}

sylvialunafreyavalannabygate(200, 50, 20, 15, 10, 2, 1)

x = 2
