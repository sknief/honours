#############################################################################
# shiny app to illustrate important motifs in gene regulatory networks
# Author: Jan Engelstaedter
# Heavily cut by Stella Knief
# Last changed: 8/3/2021 (Jan), modified 10/07/21
#############################################################################
#Modifcations made: trimmed everything that is not NAR or simple reg


#SK MODIIFICATION: added install code just for ease
install.packages("deSolve")
install.packages("tidyverse")
install.packages("ggraph")
install.packages("igraph")
install.packages("cowplot")
install.packages("shiny")
install.packages("RColorBrewer")



# attaching libraries, can all be installed from CRAN:
library(deSolve)
library(tidyverse)
library(ggraph)
library(igraph)
library(cowplot)
library(shiny)
library(RColorBrewer)

# Colour scheme:
colX   <- brewer.pal(6, "Paired")[2]
colXbg <- brewer.pal(6, "Paired")[1]
colY   <- brewer.pal(6, "Paired")[6]
colYbg <- brewer.pal(6, "Paired")[5]
colZ   <- brewer.pal(6, "Paired")[4]
colZbg <- brewer.pal(6, "Paired")[3]

# plot graphs:
genes <- data.frame(name = c("X", "Z"))
activation <- data.frame(from = c("X"),
                         to =   c("Z"))
g <- graph_from_data_frame(activation, directed = TRUE, vertices = genes)
plotSimplegraph <- ggraph(g, layout = "manual", x = c(0, 0), y=c(0.5, -0.5)) +
  geom_node_point(size = 16, color = c(colX, colZ)) +
  geom_node_point(size = 15, color = c(colXbg, colZbg)) +
  geom_node_text(aes(label = name), size = 10) +
  geom_edge_arc(aes(start_cap = circle(8, unit = "mm"),
                    end_cap = circle(8, unit = "mm")),
                arrow = arrow(type = "open", angle = 30, length = unit(3, 'mm')),
                strength = c(0)) +
  scale_x_continuous(limits = c(-1.5,1.5)) +
  scale_y_continuous(limits = c(-1,1)) +
  coord_fixed() +
  theme_graph()

genes <- data.frame(name = c("X", "Z"))
activation <- data.frame(from = c("X", "Z"),
                         to =   c("Z", "Z"))
g <- graph_from_data_frame(activation, directed = TRUE, vertices = genes)
plotNARgraph <- ggraph(g, layout = "manual", x = c(0, 0), y=c(0.5, -0.5)) +
  geom_node_point(size = 16, color = c(colX, colZ)) +
  geom_node_point(size = 15, color = c(colXbg, colZbg)) +
  geom_node_text(aes(label = name), size = 10) +
  geom_edge_arc(aes(start_cap = circle(8, unit = "mm"),
                    end_cap = circle(8, unit = "mm")),
                arrow = arrow(type = "open", angle = 30, length = unit(3, 'mm')),
                strength = c(0)) +
  geom_edge_loop(aes(start_cap = circle(8, unit = "mm"),
                     end_cap = circle(8, unit = "mm"),
                     span = 90, direction = 0, strength = 0.7),
                 arrow = arrow(type = "open", angle = 90, length = unit(3, 'mm'))) +
  scale_x_continuous(limits = c(-1.5,1.5)) +
  scale_y_continuous(limits = c(-1,1)) +
  coord_fixed() +
  theme_graph()

# exporting as figures:
#ggsave("./plots/Simplegraph.pdf", plotSimplegraph, width = 5, height = 5)
#ggsave("./plots/NARgraph.pdf", plotNARgraph, width = 5, height = 5)


Hilln <- 1000 # constant for Hill function

# ODE system for feedback autoregulation:
ODEs_FBA <- function(t, state, parameters) {
  with (as.list(c(state, parameters)), {
    # step function leads to numerical issues in lsoda:
    #dZ <- bZ * (t > Xstart && t <= Xstop & Z<1) - aZ*Z
    # use Hill function instead:
    dZ <- bZ * (t > Xstart && t <= Xstop) * 1/(1 + Z^Hilln) - aZ*Z
    dZnoFB <- aZ * (t > Xstart && t <= Xstop) - aZ*ZnoFB
    return(list(c(dZ, dZnoFB)))
  })
}


plotDynamics_FBA <- function(Xstart = 1,
                             Xstop = 6,
                             aZ = 1,
                             bZ = 0.5,
                             tmax = 10,
                             dt = 0.01) {

  params <- c(Xstart = Xstart, Xstop = Xstop, aZ = aZ, bZ = bZ)
  iniState <- c(Z=0, ZnoFB = 0)
  times <- seq(0,tmax,by=dt)
  solution <- ode(iniState, times, ODEs_FBA, params) %>%
    as.data.frame() %>%
    as_tibble() %>%
    mutate(X = ifelse(time > params["Xstart"] & time <= params["Xstop"], 1, 0)) %>%
    select(time, X, Z, ZnoFB)

  plotZ <- ggplot(solution) +
    annotate("rect", xmin = Xstart, xmax = Xstop, ymin = 0, ymax = 1.05,
             alpha = .2, fill = colX) +
    geom_line(aes(time, Z), color = colZ, size = 1.5) +
    geom_line(aes(time, ZnoFB), color = colZ, size = 1, linetype = "dashed") +
    scale_y_continuous(limits = c(0,1.05)) +
    theme_bw(base_size = 16)

  plotAll <- plot_grid(plotNARgraph, plotZ, NULL, nrow = 3, scale = c(1.5,1,1))
  plotAll
}

plotDynamics <- function(motif, Xstart, Xstop, tmax,
                         bY = NULL, bZ1 = NULL, bZ2 = NULL, aZ = NULL, KYZ = NULL) {
  if (motif == "FBA") {
    plotDynamics_FBA(Xstart = Xstart, Xstop = Xstop,
                       bZ = bZ1, aZ = aZ, tmax = tmax)
  }
}
