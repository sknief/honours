![Funnel](https://github.com/sknief/honours/blob/master/4.%20Analysis/Data%20funnel%20Infographics.png)




# File Inventory #

My models generate a LOT of data, so a file inventory helps me stay on top of what these files are and what they are called! View this as a guide to how I have been writing my R code.

## File and Folder Structure ##

Regardless of model type, I will end up with four subfolders, named in the vein of `pbs.JOBID[#].tinmgr2`, where # refers to the node number and JOBID refers to the Job ID obtained when the job was queued.

Unfortunately, you CANNOT amalgamate the contents of these folders! All files will have a structure similar to `XXXXX_SEED_MODELINDEX_GEN.extension` where XXXX refers to the type of file/output and seed refers to the seed of the simulation. Model index refers to the unique parameter combination used (so which combination out of the 100 available ones). That being said, this number will range from 1-25 as it renumbers these models across each node rather than keeping track of the model index across all models. So if you try and combine these folders, you end up having files with the same name with have **DIFFERENT CONTENT**.

Possible solutions for this:
1. Correct for this when doing the individual model run analyses in R
2. Find/Write a script to rename? (Might be a bit too much extra work though)

HMMMM. TBD.

Regardless, all files needed to conduct analysis on one simulation run is in one folder, and the mega files can be saved to overarching folders I reckon.

Key factors for the handling of this data:
* Automate as much as Possible
* `paste0` will be a blessing

## Output generated from one ADD Model ##
### File index ####

Each ADD job will generate:

**1** file *each generation* named `SLiM-output_ADD_[seed]_[index]_[gen].csv`

and

**2** files *after the simulation finished** named
`SLiMulation_Output_Full_ADD_[seed]_[index].txt` and `SLiMulation_Output_FixedMutations_ADD_[seed]_[index].txt`.

### File Content ###

The `SLiM-output_ADD_[seed]_[index]_[gen].csv` files contain:
* Individual ID (from 0-999)
* Gene A1 Value
* Gene A2 Value
* Gene B1 Value
* Gene B2 Value
* AConc
* BConc
* generation
* Seed

The `SLiMulation_Output_Full_ADD_[seed]_[index].txt` files contain:
* complete information on all subpopulations,
* individuals,
* and genomes, including all currently segregating mutations (but not including mutations that have fixed and been converted into Substitution objects).


The `SLiMulation_Output_FixedMutations_ADD_[seed]_[index].txt` files contain:
* information on all mutations that have fixed and been turned into Substitution objects. It therefore complements the information produced by
outputFull().

### Structure for analysis ###

All `SLiM-output_ADD_[seed]_[index]_[gen].csv` files need to be read into one R script and assigned a variable named based on their generation.
These can then be combined to create a big master set. From that point onwards, analysis can be conducted.

No clue how to handle the txt files yet but I am sure the SLiM manual has some pointers.



## Output generated from one ODE Model ##
### File index ####

Each ODE job will generate:

**1** file *each generation* named `Val_[seed]_generation_[index]_[gen].txt`

and

**2** files *after the simulation finished** named
`SLiMulation_Output_Full_[seed]_[index].txt` and `SLiMulation_Output_FixedMutations_[seed]_[index].txt`.

as well as `ODEoutput_[seed]_[modelindex].txt` and `SLiM-output_[seed]_[modelindex].csv` files, but these are only used to transfer data between SLiM and R, so these should be disregarded when doing the stats analysis.

### File Content ###

The `Val_[seed]_generation_[index]_[gen].txt` files contain:
* Individual ID (from 0-999)
* AAlpha
* ABeta
* BAlpha
* BBeta
* BConc
* AConc


The `SLiMulation_Output_Full_[seed]_[index].txt` files contain:
* complete information on all subpopulations,
* individuals,
* and genomes, including all currently segregating mutations (but not including mutations that have fixed and been converted into Substitution objects).


The `SLiMulation_Output_FixedMutations_[seed]_[index].txt` files contain:
* information on all mutations that have fixed and been turned into Substitution objects. It therefore complements the information produced by
outputFull().

### Structure for analysis ###

All `Val_[seed]_generation_[index]_[gen].txt` files need to be read into one R script and assigned a variable named based on their generation; slash these parameters need to be **manually added** to the data set I reckon. MY bad for not including that earlier.

These can then be combined to create a big master set. From that point onwards, analysis can be conducted.

No clue how to handle the txt files yet but I am sure the SLiM manual has some pointers.
