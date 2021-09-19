########################################################
##      HONOURS ANALYIS CODE (across model VERS)       ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#######################################
#no more user input needed!
#######################################

####  set WD to ocean #####
workdirectory <- "C:/Users/sknie/github/honours/4_Analysis/ocean"
setwd(workdirectory)

### read in all 8 Richard files

Richard_ODE_BOptHigh <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ODE_BOptHigh.csv", header = TRUE)
Richard_ODE_BOptMed <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ODE_BOptMed.csv", header = TRUE)
Richard_ODE_BOptLow <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ODE_BOptLow.csv", header = TRUE)
Richard_ODE_Neutral <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ODE_Neutral.csv", header = TRUE)
Richard_ADD_BOptHigh <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ADD_BOptHigh.csv", header = TRUE)
Richard_ADD_BOptMed <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ADD_BOptMed.csv", header = TRUE)
Richard_ADD_BOptLow <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ADD_BOptLow.csv", header = TRUE)
Richard_ADD_Neutral <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Richard_ADD_Neutral.csv", header = TRUE)

### same for all 8 shelldon files

Shelldon_ODE_BOptHigh <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ODE_BOptHigh.csv", header = TRUE)
Shelldon_ODE_BOptMed <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ODE_BOptMed.csv", header = TRUE)
Shelldon_ODE_BOptLow <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ODE_BOptLow.csv", header = TRUE)
Shelldon_ODE_Neutral <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ODE_Neutral.csv", header = TRUE)
Shelldon_ADD_BOptHigh <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ADD_BOptHigh.csv", header = TRUE)
Shelldon_ADD_BOptMed <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ADD_BOptMed.csv", header = TRUE)
Shelldon_ADD_BOptLow <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ADD_BOptLow.csv", header = TRUE)
Shelldon_ADD_Neutral <- read.table("C:/Users/sknie/github/honours/4_Analysis/ocean/Shelldon_ADD_Neutral.csv", header = TRUE)

# nice graphs.exe ####

# Graph 1: average adaptive walk of all of these but in different colours

#nice adaptive walk graph
adaptivewalkbase <- ggplot()
adaptivewalkbase + 
  #ode
  geom_line(data = Richard_ODE_BOptHigh, aes( x = Generation, y = BConc), color = "red") +
  geom_line(data = Richard_ODE_BOptMed, aes( x = Generation, y = BConc), color = "orange") +
  geom_line(data = Richard_ODE_BOptLow, aes( x = Generation, y = BConc), color = "yellow2") +
  geom_line(data = Richard_ODE_Neutral, aes( x = Generation, y = BConc), color = "yellowgreen") +
  geom_point(data = Richard_ODE_BOptHigh, aes( x = Generation, y = BConc), color = "red") +
  geom_point(data = Richard_ODE_BOptMed, aes( x = Generation, y = BConc), color = "orange") +
  geom_point(data = Richard_ODE_BOptLow, aes( x = Generation, y = BConc), color = "yellow2") +
  geom_point(data = Richard_ODE_Neutral, aes( x = Generation, y = BConc), color = "yellowgreen") +
  #add
  geom_line(data = Richard_ADD_BOptHigh, aes( x = Generation, y = BConc), color = "limegreen") +
  geom_line(data = Richard_ADD_BOptMed, aes( x = Generation, y = BConc), color = "turquoise2") +
  geom_line(data = Richard_ADD_BOptLow, aes( x = Generation, y = BConc), color = "royalblue2") +
  geom_line(data = Richard_ADD_Neutral, aes( x = Generation, y = BConc), color = "darkorchid4") +
  geom_point(data = Richard_ADD_BOptHigh, aes( x = Generation, y = BConc), color = "limegreen") +
  geom_point(data = Richard_ADD_BOptMed, aes( x = Generation, y = BConc), color = "turquoise2") +
  geom_point(data = Richard_ADD_BOptLow, aes( x = Generation, y = BConc), color = "royalblue2") +
  geom_point(data = Richard_ADD_Neutral, aes( x = Generation, y = BConc), color = "darkorchid4") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ggsave(paste0("Comparative Walks.png"), device = "png")


# Graph 2: same walks but facetted with their replicate walks (shelldons) behind them
# lets make this facetted 
#ode
ODEHigh <- adaptivewalkbase + 
  geom_line(data = Shelldon_ODE_BOptHigh, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ODE_BOptHigh, aes( x = Generation, y = BConc), color = "red") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ODEMed <- adaptivewalkbase + 
  geom_line(data = Shelldon_ODE_BOptMed, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ODE_BOptMed, aes( x = Generation, y = BConc), color = "yellow2") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ODELow <- adaptivewalkbase + 
  geom_line(data = Shelldon_ODE_BOptLow, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ODE_BOptLow, aes( x = Generation, y = BConc), color = "yellowgreen") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ODENeutral <- adaptivewalkbase + 
  geom_line(data = Shelldon_ODE_Neutral, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ODE_Neutral, aes( x = Generation, y = BConc), color = "red") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

#add
ADDHigh <- adaptivewalkbase + 
  geom_line(data = Shelldon_ADD_BOptHigh, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ADD_BOptHigh, aes( x = Generation, y = BConc), color = "limegreen") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ADDMed <- adaptivewalkbase + 
  geom_line(data = Shelldon_ADD_BOptMed, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ADD_BOptMed, aes( x = Generation, y = BConc), color = "turquoise2") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ADDLow <- adaptivewalkbase + 
  geom_line(data = Shelldon_ADD_BOptLow, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ADD_BOptLow, aes( x = Generation, y = BConc), color = "royalblue2") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

ADDNeutral <- adaptivewalkbase + 
  geom_line(data = Shelldon_ADD_Neutral, aes(x = Generation, y = BConc, group = UniqueCombo, color = UniqueCombo), color = "grey") +
  geom_line(data = Richard_ADD_Neutral, aes( x = Generation, y = BConc), color = "darkorchid4") +
  theme_classic() +
  guides(fill = "none") +
  labs(x = "Generation", y = "Mean BConc" )

lay <- rbind(c(1,2),
             c(3, 4),
             c(5,6,),
             c(7, 8))


grid.arrange(ODEHigh, ODEMed, ODELow, ODENeutral, ADDHigh, ADDMed, ADDLow, ADDNeutral, layout_matrix = lay)

ggsave(paste0("Adaptive Walks.png"), device = "png")





#graphs below cannot be done due to lack of data as of now. 
# Graph 3: histogram of mutational effect sizes

# Graph 4: distribution of mutational effect sizes (violin plots)

# Graph 5: phenotypic variation 



# compare how the different optima compare? make a graph with inidivudal lines to the optima and all lines lead to the different optima?



