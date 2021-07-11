# ODE Model Version Control #

Compiled here are notes on the different models found above. Included are descriptions, features, noted bugs and log entires of the progress made/staus of these models.

----

Version | Description | Build Status
------------- | ------------- | -------------
V1 | Experimental Barebone Coding Version | ***WIP***
V2 | First Bug-Free Release | ***Not Started Yet***
V3 | HPC-ready Model | ***Not Started Yet***

Please Note that this Versions system corresponds both to the SliM model AND its corresponding R script - these will have the same version number!

----

## Notes on the Different Models ##
### Null Model V.1 ###

*03/07/2021* - Started Working on V1.

*05/07/2021 - 06/07/21* Blind-coded (BC) the key components.  

<details>
  <summary>Patch Notes for NAR_ODE_V1.slim</summary>
  <p> * BC early event to read in files </p>
  <p> * BC early event component where AConc and Bconc Values are assigned to individuals </p>
  <p> * BC Paramstoexport & write to File Code </p>
  <p> * BC two potential fitnessScaling events </p>
 </details>


*07/07/21* Started testing the blind-coded sections & cleaned code. Started working on the corresponding R script!

<details>
  <summary>Patch Notes for NAR_ODE_V1.slim</summary>
  <p> * Tested Paramstoexport & write to File Code (works!) </p>
  <p> * BC two potential fitnessScaling events </p>
 </details>

 <details>
   <summary>Patch Notes for ODE_V1.r</summary>
   <p> * Stage one complete: data entry, cleaning & tidying </p>
  </details>

*10/07/21* Continued working on R script - functions need more thinking but the groundwork is there

   <details>
     <summary>Patch Notes for ODE_V1.r</summary>
     <p> * Stage two semi-complete: ODE functions need improvement up but exist </p>
     <p> * Stage three complete: writing to file and exporting </p>
    </details>


*11/07/21* Huge Coding Day: working on R script and SliM model.

Note to self: SLiM wd on Linux boot is the desktop, which I should probably change in the long run. 

THESE NOTES ARE PROVISIONAL AS OF 18:25PM
<details>
  <summary>Patch Notes for NAR_ODE_V1.slim</summary>
  <p> * Added an indication of Seed and generation number to file output names </p>
  <p> * worked K into the code ? </p>
  <p> * Tested and fixed code that reads in R code </p>
 </details>

<details>
  <summary>Patch Notes for ODE_V1.r</summary>
   <p> * Fixed ODE functions</p>
   <p> * anything else? </p>
</details>
