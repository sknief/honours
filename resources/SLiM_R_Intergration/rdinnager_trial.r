## Using rdinnager's SLiMr, as taken from GitHub; trial run
## script taken from the README.md of the main GitHub package
## Tested: 23/04/21 // out_dat not working clearly, but else impressive

install.packages("devtools")
library(devtools)

devtools::install_github("hadley/devtools")
devtools::install_github("rdinnager/slimr")

library(slimr)
#> Welcome to the slimr package for forward population genetics simulation in SLiM. For more information on SLiM please visit https://messerlab.org/slim/ .

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



script_txt <- as_slim_text(script_1)

cat(script_txt)

out <- slim_run(script_txt, simple_run = TRUE, capture_output = TRUE)
head(out$output, n = 50L)

out$output


out_dat <- slim_extract_output_data(out$output)
print(out_dat)
