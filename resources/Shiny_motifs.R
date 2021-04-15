#############################################################################
# shiny app to illustrate important motifs in gene regulatory networks
# Author: Jan Engelstaedter
# Last changed: 8/3/2021
#############################################################################

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

genes <- data.frame(name = c("X", "Y", "Z"))
activation <- data.frame(from = c("X", "X", "Y"),
                         to =   c("Y", "Z", "Z"))
g <- graph_from_data_frame(activation, directed = TRUE, vertices = genes)
coords <- data.frame(x=c(0,-1,1), y=c(1,0,0))
plotFFLC1graph <- ggraph(g, layout = "manual", x = c(0,-0.7,0.7), y=c(1,0,0)) +
  geom_node_point(size = 16, color = c(colX, colY, colZ)) +
  geom_node_point(size = 15, color = c(colXbg, colYbg, colZbg)) +
  geom_node_text(aes(label = name), size = 10) +
  geom_edge_arc(aes(start_cap = circle(8, unit = "mm"),
                    end_cap = circle(8, unit = "mm")),
                arrow = arrow(type = "open", angle = 30, length = unit(3, 'mm')),
                strength = c(-0.2,0.2,-0.2)) +
  scale_x_continuous(limits = c(-1.5,1.5)) +
  scale_y_continuous(limits = c(-0.5,1.5)) +
  coord_fixed() +
  theme_graph()

plotFFLI1graph <- ggraph(g, layout = "manual", x = c(0,-0.7,0.7), y=c(1,0,0)) +
  geom_node_point(size = 16, color = c(colX, colY, colZ)) +
  geom_node_point(size = 15, color = c(colXbg, colYbg, colZbg)) +
  geom_node_text(aes(label = name), size = 10) +
  geom_edge_arc(aes(start_cap = circle(8, unit = "mm"),
                    end_cap = circle(8, unit = "mm")),
                arrow = arrow(type = "open", angle = c(30,30,90), length = unit(3, 'mm')),
                strength = c(-0.2,0.2,-0.2)) +
  scale_x_continuous(limits = c(-1.5,1.5)) +
  scale_y_continuous(limits = c(-0.5,1.5)) +
  coord_fixed() +
  theme_graph()

# exporting as figures:
#ggsave("./plots/Simplegraph.pdf", plotSimplegraph, width = 5, height = 5)
#ggsave("./plots/NARgraph.pdf", plotNARgraph, width = 5, height = 5)
#ggsave("./plots/FFLC1graph.pdf", plotFFLC1graph, width = 5, height = 5)
#ggsave("./plots/FFLI1graph.pdf", plotFFLI1graph, width = 5, height = 5)

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

# ODE system for coherent-type1 feed-forward loop system:
ODEs_FFLC1 <- function(t, state, parameters) {
  with (as.list(c(state, parameters)), {
    dY <- bY * (t > Xstart && t <= Xstop) - bY*Y
    dZ <- bZ * (t > Xstart && t <= Xstop & Y > KYZ) - bZ*Z
    return(list(c(dY, dZ)))
  })
}

# ODE system for incoherent-type1 feed-forward loop system:
ODEs_FFLI1 <- function(t, state, parameters) {
  with (as.list(c(state, parameters)), {
    dY <- bY * (t > Xstart && t <= Xstop) - bY*Y
    dZ <- bZ * (t > Xstart && t <= Xstop & Y < KYZ) - bZ*Z
    return(list(c(dY, dZ)))
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

plotDynamics_FFLC1 <- function(Xstart = 1,
                               Xstop = 6,
                               bY = 1,
                               bZ = 0.5,
                               KYZ = 0.8,
                               tmax = 10,
                               dt = 0.01) {

params <- c(Xstart = Xstart, Xstop = Xstop,
            bY = bY, bZ = bZ, KYZ = KYZ)
  iniState <- c(Y=0, Z=0)
  times <- seq(0,tmax,by=dt)
  solution <- ode(iniState, times, ODEs_FFLC1, params) %>%
    as.data.frame() %>%
    as_tibble() %>%
    mutate(X = ifelse(time > params["Xstart"] & time <= params["Xstop"], 1, 0)) %>%
    select(time, X, Y, Z)

  plotY <- ggplot(solution) +
    annotate("rect", xmin = Xstart, xmax = Xstop, ymin = 0, ymax = 1.05,
             alpha = .2, fill = colX) +
    geom_line(aes(time, Y), color = colY, size = 1.5) +
    scale_y_continuous(limits = c(0,1.05)) +
    theme_bw(base_size = 16)

  plotZ <- ggplot(solution) +
    annotate("rect", xmin = Xstart, xmax = Xstop, ymin = 0, ymax = 1.05,
             alpha = .2, fill = colX) +
    geom_line(aes(time, Z), color = colZ, size = 1.5) +
    scale_y_continuous(limits = c(0,1.05)) +
    theme_bw(base_size = 16)

  plotAll <- plot_grid(plotFFLC1graph, plotY, plotZ, nrow = 3, scale = c(1.5,1,1))
  plotAll
}


plotDynamics_FFLI1 <- function(Xstart = 1,
                               Xstop = 6,
                               bY = 1,
                               bZ = 0.5,
                               KYZ = 0.8,
                               tmax = 10,
                               dt = 0.01) {

  params <- c(Xstart = Xstart, Xstop = Xstop,
              bY = bY, bZ = bZ, KYZ = KYZ)
  iniState <- c(Y =0, Z=0)
  times <- seq(0,tmax,by=dt)
  solution <- ode(iniState, times, ODEs_FFLI1, params) %>%
    as.data.frame() %>%
    as_tibble() %>%
    mutate(X = ifelse(time > params["Xstart"] & time <= params["Xstop"], 1, 0)) %>%
    select(time, X, Y, Z)

  plotY <- ggplot(solution) +
    annotate("rect", xmin = Xstart, xmax = Xstop, ymin = 0, ymax = 1.05,
             alpha = .2, fill = colX) +
    geom_line(aes(time, Y), color = colY, size = 1.5) +
    scale_y_continuous(limits = c(0,1.05)) +
    theme_bw(base_size = 16)

  plotZ <- ggplot(solution) +
    annotate("rect", xmin = Xstart, xmax = Xstop, ymin = 0, ymax = 1.05,
             alpha = .2, fill = colX) +
    geom_line(aes(time, Z), color = colZ, size = 1.5) +
    scale_y_continuous(limits = c(0,1.05)) +
    theme_bw(base_size = 16)

  plotAll <- plot_grid(plotFFLI1graph, plotY, plotZ, nrow = 3, scale = c(1.5,1,1))
  plotAll
}

plotDynamics <- function(motif, Xstart, Xstop, tmax,
                         bY = NULL, bZ1 = NULL, bZ2 = NULL, aZ = NULL, KYZ = NULL) {
  if (motif == "FBA") {
    plotDynamics_FBA(Xstart = Xstart, Xstop = Xstop,
                       bZ = bZ1, aZ = aZ, tmax = tmax)
  } else if (motif == "FFLC1") {
    plotDynamics_FFLC1(Xstart = Xstart, Xstop = Xstop,
                       bY = bY, bZ = bZ2, KYZ = KYZ, tmax = tmax)
  } else if (motif == "FFLI1") {
    plotDynamics_FFLI1(Xstart = Xstart, Xstop = Xstop,
                       bY = bY, bZ = bZ2, KYZ = KYZ, tmax = tmax)
  }
}

server<-function(input, output) {
  output$main_plot <- renderPlot({
    plotDynamics(motif = input$motif, Xstart = input$Xstart, Xstop = input$Xstop,
                 bY = input$bY, bZ1 = input$bZ1, bZ2 = input$bZ2, aZ = input$aZ, KYZ = input$KYZ, tmax = input$tmax)
  })
}

ui<-fluidPage(
  titlePanel("Network motifs in transcription networks"),

  sidebarLayout(
    sidebarPanel(
      radioButtons(inputId="motif", label="Network motif:", choices=c("FBA","FFLC1","FFLI1"), inline=TRUE),
      sliderInput(inputId = "Xstart",label = "Signal starts at:",
                  min = 0, max = 100, value = 10, step = 0.1),
      sliderInput(inputId = "Xstop", label = "Signal stops at:",
                  min = 0, max = 100, value = 30, step = 0.1),
      conditionalPanel(condition = "input.motif != 'FBA'",
        sliderInput(inputId = "bY", label = "Expression & decay rate bY:",
                    min = 0, max = 2, value = 0.2, step = 0.01)),
      conditionalPanel(condition = "input.motif == 'FBA'",
        sliderInput(inputId = "aZ", label = "Decay rate aZ:",
                    min = 0, max = 2, value = 0.5, step = 0.01)),
      conditionalPanel(condition = "input.motif == 'FBA'",
        sliderInput(inputId = "bZ1", label = "Expression (& decay) rate bZ:",
                    min = 0, max = 2, value = 0.6, step = 0.01)),
      conditionalPanel(condition = "input.motif != 'FBA'",
                       sliderInput(inputId = "bZ2", label = "Expression & decay rate bZ:",
                                   min = 0, max = 2, value = 0.6, step = 0.01)),
      conditionalPanel(condition = "input.motif != 'FBA'",
        sliderInput(inputId = "KYZ", label = "Activation threshold KYZ for Z:",
                    min = 0, max = 1, value = 0.8, step = 0.01)),
      sliderInput(inputId = "tmax", label="Time to be simulated", min = 0,
                  max = 100, value = 50, step = 1)
    ),
    mainPanel(
      conditionalPanel(condition = "input.motif == 'FBA'",
                       h3("Negative autoregulation"),
                       h5("(Z gets activated when X is on and Z<1. Activity of X shown as blue shading, and dynamics without feedback as dashed line for comparison.)")),
      conditionalPanel(condition = "input.motif == 'FFLC1'",
                       h3("Feed-forward loop, coherent type 1"),
                       h5("(Z gets activated when X is on AND when Y>KYZ. Activity of X shown as blue shading.)")),
      conditionalPanel(condition = "input.motif == 'FFLI1'",
                       h3("Feed-forward loop, incoherent type 1"),
                       h5("(Z gets activated when X is on AND when Y<KYZ. Activity of X shown as blue shading.)")),

      plotOutput(outputId = "main_plot", height = "600px"))
  )
)

shinyApp(ui=ui, server=server)
