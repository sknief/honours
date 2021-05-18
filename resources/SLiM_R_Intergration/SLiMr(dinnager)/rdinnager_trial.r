##########################DOCCO#############################

## Using rdinnager's SLiMr, as taken from GitHub; trial run
## script taken from the README.md of the main GitHub package
## Tested: 23/04/21 // out_dat not working clearly, but else impressive
## Extended: 12/05/21

###########################################################

#### SET-UP #######

install.packages("devtools")
library(devtools)

devtools::install_github("hadley/devtools")
devtools::install_github("rdinnager/slimr")

library(slimr)
#> Welcome to the slimr package for forward population genetics simulation in SLiM. For more information on SLiM please visit https://messerlab.org/slim/ .



######### 1. Basic Test/Example of SLiMr ##################

#script ends in a new variable "script_1"
slim_script(
  slim_block(initialize(),
             {
               ## set the overall mutation rate
               initializeMutationRate(1e-7);
               ## m1 mutation type: neutral
               initializeMutationType("m1", 0.5, "f", 0.0);
               ## g1 genomic element type: uses m1 for all mutations
               initializeGenomicElementType("g1", m1, 1.0);
               ## uniform chromosome of length 100 kb
               initializeGenomicElement(g1, 0, 99999);
               ## uniform recombination along the chromosome
               initializeRecombinationRate(1e-8);
             }),
  slim_block(1,
             {
               sim.addSubpop("p1", 500);
             }),
  slim_block(10000, late(),
             {
               sim.simulationFinished();
               sim.outputFull();
             })
) -> script_1

#writing only the variable/script name should output the script as given
script_1
#> <slimr_script[3]>
#> block_init:initialize() {
#>     initializeMutationRate(1e-07);
#>     initializeMutationType("m1", 0.5, "f", 0);
#>     initializeGenomicElementType("g1", m1, 1);
#>     initializeGenomicElement(g1, 0, 99999);
#>     initializeRecombinationRate(1e-08);
#> }
#>
#> block_2:1 early() {
#>     sim.addSubpop("p1", 500);
#> }
#>
#> block_3:10000 early() {
#>     sim.simulationFinished();
#> }


#Next, convert it to a text file/form
script_txt <- as_slim_text(script_1)

cat(script_txt)

out <- slim_run(script_txt, simple_run = TRUE, capture_output = TRUE)
head(out$output, n = 50L)

out$output


out_dat <- slim_extract_output_data(out$output)
print(out_dat)


#################### 2. SLiM_output #######################

#lets try slim_output (for slim to produce output that R can work with)

#script
slim_script(
  slim_block(initialize(),
             {
               ## set the overall mutation rate
               initializeMutationRate(1e-7);
               ## m1 mutation type: neutral
               initializeMutationType("m1", 0.5, "f", 0.0);
               ## g1 genomic element type: uses m1 for all mutations
               initializeGenomicElementType("g1", m1, 1.0);
               ## uniform chromosome of length 100 kb
               initializeGenomicElement(g1, 0, 99999);
               ## uniform recombination along the chromosome
               initializeRecombinationRate(1e-8);
             }),
  slim_block(1,
             {
               sim.addSubpop("p1", 500);
             }),
  slim_block(1, .., late(),
             {
               ## output sample of 10 individuals' genomes in VCF format
               slimr_output(p1%.%.P$outputVCFSample(sampleSize = 10), name = "VCF");
               catn("Another successful round of evolution completed!")

             }),
  slim_block(100,
             {
               sim.simulationFinished();
             })
) -> script_w_out

#check the script
script_w_out

#convert to text so that we can send it to slim
script_txt <- as_slim_text(script_w_out)

cat(script_txt)
#printed script can be copy-pasted but also, run in R

out <- slim_run(script_txt, simple_run = TRUE, capture_output = TRUE)
head(out$output, n = 50L)

#output looks a bit like ass so how about a "tibble":
out_dat <- slim_extract_output_data(out$output)
print(out_dat)

#this data can then be looked at and manipulated in R i think:
newdataframe <- as.data.frame(out_dat$data)
#yeah thats a dataframe now!! so this is how you take out data essentially



################# 2.1 Modification ########################

#you can also modify the script from here
modify(script_w_out, "end_gen", 3) <- 1000

out <- slim_run(script_w_out, show_output = FALSE)
head(out$output, n = 20L)
out$output_data
#now theres more data, so you can tell it works!




############## 3. INLINE Function #########################

#so far so good, what about inline stuff
#inline object



#holy_script V1, without the inline function yet
slim_script(
  slim_block(initialize(),
             {
               ## set the overall mutation rate
               initializeMutationRate(1e-7);
               ## m1 mutation type: neutral
               initializeMutationType("m1",0.5, "g", -0.2, 0.2);
               ## g1 genomic element type: uses m1 for all mutations
               initializeGenomicElementType("g1", m1, 1.0);
               ## uniform chromosome of length 100 kb
               initializeGenomicElement(g1, 0, 99999);
               ## uniform recombination along the chromosome
               initializeRecombinationRate(1e-8);
             }),

  slim_block(1,
             {
               sim.addSubpop("p1", 500);
             }),

  slim_block(1, .., early(),
             {
               for (ind in sim.subpopulations.individuals)
                 {
                 AAD = ind.sumOfMutationsOfType(m1);
                 ind.setValue("aad", AAD);
                  }
             }),


  slim_block(200, .., late(),
             {
               inds = sim.subpopulations.individuals;
               test1 = mean(inds.getValue("aad"));

               slimr_output(test1, name = "Test1");
               catn("Please work!");
             }),


  slim_block(10000, late(),
             {
               sim.simulationFinished();
               sim.outputFull();
             })
) -> holy_script


#check script, looks good
holy_script

#text conversion
holy_script_txt <- as_slim_text(holy_script)
cat(holy_script_txt)

holy_script_run <- slim_run(holy_script_txt, simple_run = TRUE, capture_output = TRUE)

#output extraction
holy_output <- slim_extract_output_data(holy_script_run$output)
holy_output_legit <- as.data.frame(holy_output$data)

#cool, now i got the like hypothetical AAD value
#can i plug it back in tho?


###########################'''''WHERE I LEFT OFF #####################
#transform data into a new value (mimick ODE and turn it into an inline)
holy_output_legit$testinline = (holy_output_legit$data) * 0.5

###HOLY SMOKES V2
slim_script(
  slim_block(initialize(),
             {
               ## set the overall mutation rate
               initializeMutationRate(1e-7);
               ## m1 mutation type: neutral
               initializeMutationType("m1",0.5, "g", -0.2, 0.2);
               ## g1 genomic element type: uses m1 for all mutations
               initializeGenomicElementType("g1", m1, 1.0);
               ## uniform chromosome of length 100 kb
               initializeGenomicElement(g1, 0, 99999);
               ## uniform recombination along the chromosome
               initializeRecombinationRate(1e-8);
             }),

  slim_block(1,
             {
               sim.addSubpop("p1", 500);
             }),

  slim_block(1, .., early(),
             {
               for (ind in sim.subpopulations.individuals)
               {
                 AAD = ind.sumOfMutationsOfType(m1);
                 ind.setValue("aad", AAD);

                 slimr_inline()
                 inline =
               }
             }),


  slim_block(200, .., late(),
             {
               inds = sim.subpopulations.individuals;
               test1 = mean(inds.getValue("aad"));

               slimr_output(test1, name = "Test1");
               catn("Please work!");
             }),


  slim_block(10000, late(),
             {
               sim.simulationFinished();
               sim.outputFull();
             })
) -> holy_script
