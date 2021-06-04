# Getting SLiM and R to speak to each other #
~~really is not as easy as I thought it would be~~

At the heart of this project lie the differential equations that describe the interaction strength between nodes in our simulated genetic networks. These differential equations consist of three key parameters (alpha, beta and the hill coefficient), each of which are acted upon by mutations to change the value of these parameters. This in turn then changes the ODE and thus regulates the amount of subsequent protein produced through a change in interaction strength. My model needs to not only solve these ODE's, but I am also relying on the integral of each function (in other words: the area underneath the curve that these ODE's produce) as to have selection act upon a singular factor rather than act on all three parameters separately (for the sake of computing and my own sanity).

*workflow diagram to be added?*

SLiM, while brilliant in its own right, is not capable of solving ODEs, which means I turned towards R, hoping to use the deSolve package. The idea was that SLiM could produce the needed parameter values that had been changed by mutations and these are then fed into R, plugged into the ODEs and the output of those calculations is then fed back into SLiM in order for selection to act upon the individuals. Here in the NAR model, the trait that is selected upon is the concentration of final output produced, which is able to be proxied using the AUC of the interaction between node A and B.

While this sounds simple in principle, it has been a journey trying to get this workflow to work. In total, I have worked through 6 different methods in order to obtain my ODE results:

*Add a diagram of these six options lateron*

Method | Description | Outcome
------------- | ------------- | -------------
ODEs in SLiM | Using SLiM to solve ODEs natively | **FAILED**, as SLiM has no native ODE function
Writing an ODE function | Writing my own eidos function | **FAILED**, as SLiM lacks the framework to solve ODEs in its current state, as tested and confirmed by [Ben Haller](https://messerlab.org/slim/)
[SLiMr](https://github.com/sknief/honours/tree/master/SLiM_R_Intergration/SLiMr(dinnager)) by [RDinnager](https://github.com/rdinnager/slimr) | Running SLiM from RStudio | **FAILED**, as these simulations cannot be interrupted by R code, thus lacking the vertical integration I was chasing
[Nested System() Approach](https://github.com/sknief/honours/tree/master/SLiM_R_Intergration/system()/nested) | Nesting an R script in SLiM using the system() function | **REJECTED** as the output produced was finnicky and feeding the output back into SLiM failed repeatedly due to the constraints of having to use .txt files. Probably could have been able to get this to work, but it seemed not worth the trouble
[Lateral Integration](https://github.com/sknief/honours/tree/master/SLiM_R_Intergration/system()/parallel) | Running SLiM and R in parallel in a tight circuit | **VIABLE** after extensive testing, originally thought to be **FAILED** as well. Relies on the export and import of singleton text files that end up producing float vectors in SLiM. May be computational inefficient for larger models.  
[Matrix Approach](https://github.com/sknief/honours/tree/master/SLiM_R_Intergration/matrix) | Developing matrices of individual barcodes, mutation vectors and pre-calculated ODE solutions which are then all fed into SLiM. R is used to generate these matrices but is not active during the simulation run | **POTENTIALLY VIABLE**, I have yet to test if SLiM can match and call values from different matrices as the matrix support within SLiM is essentially a worser version of the R matrix support, as all matrices remain vectors within the SLiM scope. I have been working on the code to create these matrices, as this may prove to be computationally more efficient especially for larger models.

Essentially, the majority of my work in April and May has been working through these six approaches and attempting to integrate SLiM and R. This goes hand in hand with trawling through both the SLiM and Eidos manuals and learning nested and parallel coding structures.

While most of these six approaches are not viable for my project, there are three approaches which remain interesting in their own right. These were the approaches that I have spent most time on and I would recommend to other researchers that are interested in integrating SLiM and R or would like to extend the functionality of SLiM.

## SLiMr : Powerful for code optimisation ##

[SLiMr](https://github.com/rdinnager/slimr) is a package for R developed by RDinnager, which essentially allows the user to write and run SLiM scripts from R or RStudio. The true power of SLiMr lies in it's slim_inline() function, which allows the user to define a vector of values that should be used in subsequent runs of the slim model, without having to go in and change the code each time. It also allows the user to create output that is formatted so that R can immediately use it without the need to tidy or reformat slim output.

-[x] slim_inline() is very useful for creating replicates easily
-[x] slim_outline() allows for quick tidy data
-[x] superb choice if you need base SLiM functionality and would like to conduct R analysis
-[] cannot run R code within your simulations* so there is no true Integration
-[] documentation and debugging is still in the works

*SLiMr is still being developed, so its functionality may have expanded by the time I have finished uploading this readme, so take the fact that it has been rejected for this project as a product of the time I have worked on it.

## Lateral Integration ##

Lateral integration, in my books at least, refers to the fact that SLiM and R are running in parallel for the entirety of these SLiM simulation. Each generation, SLiM writes to a file which is read by R, R then writes to another file and this file is read in by SLiM and acted upon by SLiM. ***This is an incredibly powerful approach to working with SLiM and can be extended to any software that can write to .txt, not just R.***

*Add a diagram of that workflow lateron*

There are some basic ground rules, but essentially, as long as you can create a text file with the numeric output that you need, you can use lateral integration to work with any other supplementary programme. It is important to note that only singleton files may be read in (ie a file that contains one row of "1 2 3 4 5" and not a file with two rows in the format of
"1: 1 2 3 4 5, 2: 6 7 8 9 10"). Similarly, these text files have to be space-separated and must not contain whitespace after the last number, otherwise SLiM will throw an error message.

The basic code to use this approach is:
`x = readFile("~/Desktop/file.txt");
x = asFloat(strsplit(x));`

It is **imperial** that you use the `strsplit()` function, as SLiM will otherwise not recognize that there are multiple data entries within your text file.

If you would like to check that everything worked the way it should, here is some test code taken from my own project:
`	IDS = readFile("~/Desktop/test.txt");
	IDS = asFloat(strsplit(IDS));
	print("These are your individuals here:");
	print(IDS);
	val = isFloat(IDS);
	print("TRUE OR FALSE that we all  FLOAT down here?:" + val);`

This should print your file content and the `isFloat()` should return T.

With lateral integration, you can then manipulate your data like any other float vector within SLiM (for example, cbind() it to another imported text file if you need to make a matrix or a data frame within SLiM!).

This approach is my preferred approach to creating the NAR model, and is the one I am currently (04/06) working on.

## The Matrix Approach ##

*add a diagram of the different matrices created*

The Matrix approach essentially eliminates the need to use R within the simulations, and instead relies on the complete availability of all possible outcomes before the simulation even begins.
