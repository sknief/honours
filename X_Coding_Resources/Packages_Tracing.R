######################################################
# R CODE FOR UNDERSTANDING WHERE MY PACKAGES GO AAA  #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################


 .libPaths()
#[1] "/home/stella/R/x86_64-pc-linux-gnu-library/4.1" "/usr/local/lib/R/site-library"
#[3] "/usr/lib/R/site-library"                        "/usr/lib/R/library"

library()
#Warning message:
#In library() : library ‘/usr/lib/R/site-library’ contains no packages

#Output:

Packages in library ‘/home/stella/R/x86_64-pc-linux-gnu-library/4.1’:

AlgDesign                       Algorithmic Experimental Design
assertthat                      Easy Pre and Post Assertions
backports                       Reimplementations of Functions Introduced Since R-3.0.0
base64enc                       Tools for base64 encoding
blob                            A Simple S3 Class for Representing Vectors of Binary Data
                                ('BLOBS')
broom                           Convert Statistical Objects into Tidy Tibbles
bslib                           Custom 'Bootstrap' 'Sass' Themes for 'shiny' and 'rmarkdown'
cellranger                      Translate Spreadsheet Cell Ranges to Rows and Columns
cli                             Helpers for Developing Command Line Interfaces
colorspace                      A Toolbox for Manipulating and Assessing Colors and Palettes
combinat                        combinatorics utilities
conf.design                     Construction of factorial designs
data.table                      Extension of `data.frame`
DBI                             R Database Interface
dbplyr                          A 'dplyr' Back End for Databases
DiceDesign                      Designs of Computer Experiments
dtplyr                          Data Table Back-End for 'dplyr'
e1071                           Misc Functions of the Department of Statistics, Probability
                                Theory Group (Formerly: E1071), TU Wien
estimability                    Tools for Assessing Estimability of Linear Predictions
farver                          High Performance Colour Space Manipulation
forcats                         Tools for Working with Categorical Variables (Factors)
gargle                          Utilities for Working with Google APIs
GGally                          Extension to 'ggplot2'
ggplot2                         Create Elegant Data Visualisations Using the Grammar of
                                Graphics
googledrive                     An Interface to Google Drive
googlesheets4                   Access Google Sheets using the Sheets API V4
gtable                          Arrange 'Grobs' in Tables
htmltools                       Tools for HTML
httpuv                          HTTP and WebSocket Server Library
ids                             Generate Random Identifiers
isoband                         Generate Isolines and Isobands from Regularly Spaced Elevation
                                Grids
jquerylib                       Obtain 'jQuery' as an HTML Dependency Object
labeling                        Axis Labeling
later                           Utilities for Scheduling Functions to Execute Later with Event
                                Loops
lhs                             Latin Hypercube Samples
lubridate                       Make Dealing with Dates a Little Easier
mathjaxr                        Using 'Mathjax' in Rd Files
modelr                          Modelling Functions that Work with the Pipe
munsell                         Utilities for Using Munsell Colours
numbers                         Number-Theoretic Functions
plyr                            Tools for Splitting, Applying and Combining Data
polynom                         A Collection of Functions to Implement a Class for Univariate
                                Polynomial Manipulations
promises                        Abstractions for Promise-Based Asynchronous Programming
proxy                           Distance and Similarity Measures
RColorBrewer                    ColorBrewer Palettes
readxl                          Read Excel Files
rematch                         Match Regular Expressions with a Nicer 'API'
reprex                          Prepare Reproducible Example Code via the Clipboard
reshape                         Flexibly Reshape Data
rmarkdown                       Dynamic Documents for R
rsm                             Response-Surface Analysis
rvest                           Easily Harvest (Scrape) Web Pages
sass                            Syntactically Awesome Style Sheets ('Sass')
scales                          Scale Functions for Visualization
scatterplot3d                   3D Scatter Plot
selectr                         Translate CSS Selectors to XPath Expressions
sets                            Sets, Generalized Sets, Customizable Sets and Intervals
sfsmisc                         Utilities from 'Seminar fuer Statistik' ETH Zurich
shiny                           Web Application Framework for R
shinyalert                      Easily Create Pretty Popup Messages (Modals) in 'Shiny'
shinyjs                         Easily Improve the User Experience of Your Shiny Apps in
                                Seconds
sourcetools                     Tools for Reading, Tokenizing and Parsing R Code
tinytex                         Helper Functions to Install and Maintain TeX Live, and Compile
                                LaTeX Documents
uuid                            Tools for Generating and Handling of UUIDs
viridisLite                     Colorblind-Friendly Color Maps (Lite Version)
xfun                            Supporting Functions for Packages Maintained by 'Yihui Xie'
xtable                          Export Tables to LaTeX or HTML
zoo                             S3 Infrastructure for Regular and Irregular Time Series (Z's
                                Ordered Observations)

Packages in library ‘/usr/local/lib/R/site-library’:

askpass                         Safe Password Entry for R, Git, and SSH
assertthat                      Easy Pre and Post Assertions
backports                       Reimplementations of Functions Introduced Since R-3.0.0
base64enc                       Tools for base64 encoding
BH                              Boost C++ Header Files
blob                            A Simple S3 Class for Representing Vectors of Binary Data
                                ('BLOBS')
brew                            Templating Framework for Report Generation
brio                            Basic R Input Output
broom                           Convert Statistical Objects into Tidy Tibbles
cachem                          Cache R Objects with Automatic Pruning
callr                           Call R from R
cellranger                      Translate Spreadsheet Cell Ranges to Rows and Columns
cli                             Helpers for Developing Command Line Interfaces
clipr                           Read and Write from the System Clipboard
colorspace                      A Toolbox for Manipulating and Assessing Colors and Palettes
commonmark                      High Performance CommonMark and Github Markdown Rendering in R
cpp11                           A C++11 Interface for R's C Interface
crayon                          Colored Terminal Output
credentials                     Tools for Managing SSH and Git Credentials
curl                            A Modern and Flexible Web Client for R
data.table                      Extension of `data.frame`
DBI                             R Database Interface
dbplyr                          A 'dplyr' Back End for Databases
desc                            Manipulate DESCRIPTION Files
devtools                        Tools to Make Developing R Packages Easier
diffobj                         Diffs for R Objects
digest                          Create Compact Hash Digests of R Objects
dplyr                           A Grammar of Data Manipulation
dtplyr                          Data Table Back-End for 'dplyr'
e1071                           Misc Functions of the Department of Statistics, Probability
                                Theory Group (Formerly: E1071), TU Wien
ellipsis                        Tools for Working with ...
evaluate                        Parsing and Evaluation Tools that Provide More Details than the
                                Default
fansi                           ANSI Control Sequence Aware String Functions
farver                          High Performance Colour Space Manipulation
fastmap                         Fast Data Structures
forcats                         Tools for Working with Categorical Variables (Factors)
fs                              Cross-Platform File System Operations Based on 'libuv'
gargle                          Utilities for Working with Google APIs
generics                        Common S3 Generics not Provided by Base R Methods Related to
                                Model Fitting
gert                            Simple Git Client for R
ggplot2                         Create Elegant Data Visualisations Using the Grammar of
                                Graphics
gh                              'GitHub' 'API'
gitcreds                        Query 'git' Credentials from 'R'
glue                            Interpreted String Literals
googledrive                     An Interface to Google Drive
googlesheets4                   Access Google Sheets using the Sheets API V4
gtable                          Arrange 'Grobs' in Tables
highr                           Syntax Highlighting for R Source Code
hms                             Pretty Time of Day
htmltools                       Tools for HTML
httr                            Tools for Working with URLs and HTTP
ids                             Generate Random Identifiers
ini                             Read and Write '.ini' Files
isoband                         Generate Isolines and Isobands from Regularly Spaced Elevation
                                Grids
jsonlite                        A Simple and Robust JSON Parser and Generator for R
knitr                           A General-Purpose Package for Dynamic Report Generation in R
labeling                        Axis Labeling
lifecycle                       Manage the Life Cycle of your Package Functions
lubridate                       Make Dealing with Dates a Little Easier
magrittr                        A Forward-Pipe Operator for R
markdown                        Render Markdown with the C Library 'Sundown'
memoise                         Memoisation of Functions
mime                            Map Filenames to MIME Types
modelr                          Modelling Functions that Work with the Pipe
munsell                         Utilities for Using Munsell Colours
openssl                         Toolkit for Encryption, Signatures and Certificates Based on
                                OpenSSL
pillar                          Coloured Formatting for Columns
pkgbuild                        Find Tools Needed to Build R Packages
pkgconfig                       Private Configuration for 'R' Packages
pkgload                         Simulate Package Installation and Attach
praise                          Praise Users
prettycode                      Pretty Print R Code in the Terminal
prettyunits                     Pretty, Human Readable Formatting of Quantities
processx                        Execute and Control System Processes
progress                        Terminal Progress Bars
proxy                           Distance and Similarity Measures
ps                              List, Query, Manipulate System Processes
purrr                           Functional Programming Tools
R6                              Encapsulated Classes with Reference Semantics
rappdirs                        Application Directories: Determine Where to Save Data, Caches,
                                and Logs
rcmdcheck                       Run 'R CMD check' from 'R' and Capture Results
RColorBrewer                    ColorBrewer Palettes
Rcpp                            Seamless R and C++ Integration
readr                           Read Rectangular Text Data
readxl                          Read Excel Files
rematch                         Match Regular Expressions with a Nicer 'API'
rematch2                        Tidy Output from Regular Expression Matching
remotes                         R Package Installation from Remote Repositories, Including
                                'GitHub'
reprex                          Prepare Reproducible Example Code via the Clipboard
rlang                           Functions for Base Types and Core R and 'Tidyverse' Features
rmarkdown                       Dynamic Documents for R
roxygen2                        In-Line Documentation for R
rprojroot                       Finding Files in Project Subdirectories
rstudioapi                      Safely Access the RStudio API
rversions                       Query 'R' Versions, Including 'r-release' and 'r-oldrel'
rvest                           Easily Harvest (Scrape) Web Pages
scales                          Scale Functions for Visualization
selectr                         Translate CSS Selectors to XPath Expressions
sessioninfo                     R Session Information
slimr                           Create, Run and Post-Process SLiM Population Genetics Forward
                                Simulations
stringi                         Character String Processing Facilities
stringr                         Simple, Consistent Wrappers for Common String Operations
sys                             Powerful and Reliable Tools for Running System Commands in R
testthat                        Unit Testing for R
tibble                          Simple Data Frames
tidyr                           Tidy Messy Data
tidyselect                      Select from a Set of Strings
tinytex                         Helper Functions to Install and Maintain TeX Live, and Compile
                                LaTeX Documents
usethis                         Automate Package and Project Setup
utf8                            Unicode Text Processing
uuid                            Tools for Generating and Handling of UUIDs
vctrs                           Vector Helpers
viridisLite                     Colorblind-Friendly Color Maps (Lite Version)
waldo                           Find Differences Between R Objects
whisker                         {{mustache}} for R, Logicless Templating
withr                           Run Code 'With' Temporarily Modified Global State
xfun                            Supporting Functions for Packages Maintained by 'Yihui Xie'
xml2                            Parse XML
xopen                           Open System Files, 'URLs', Anything
yaml                            Methods to Convert R Data to YAML and Back
zeallot                         Multiple, Unpacking, and Destructuring Assignment
zip                             Cross-Platform 'zip' Compression

Packages in library ‘/usr/lib/R/library’:

base                            The R Base Package
boot                            Bootstrap Functions (Originally by Angelo Canty for S)
class                           Functions for Classification
cluster                         "Finding Groups in Data": Cluster Analysis Extended Rousseeuw
                                et al.
codetools                       Code Analysis Tools for R
compiler                        The R Compiler Package
datasets                        The R Datasets Package
foreign                         Read Data Stored by 'Minitab', 'S', 'SAS', 'SPSS', 'Stata',
                                'Systat', 'Weka', 'dBase', ...
graphics                        The R Graphics Package
grDevices                       The R Graphics Devices and Support for Colours and Fonts
grid                            The Grid Graphics Package
KernSmooth                      Functions for Kernel Smoothing Supporting Wand & Jones (1995)
lattice                         Trellis Graphics for R
MASS                            Support Functions and Datasets for Venables and Ripley's MASS
Matrix                          Sparse and Dense Matrix Classes and Methods
methods                         Formal Methods and Classes
mgcv                            Mixed GAM Computation Vehicle with Automatic Smoothness
                                Estimation
nlme                            Linear and Nonlinear Mixed Effects Models
nnet                            Feed-Forward Neural Networks and Multinomial Log-Linear Models
parallel                        Support for Parallel computation in R
rpart                           Recursive Partitioning and Regression Trees
spatial                         Functions for Kriging and Point Pattern Analysis
splines                         Regression Spline Functions and Classes
stats                           The R Stats Package
stats4                          Statistical Functions using S4 Classes
survival                        Survival Analysis
tcltk                           Tcl/Tk Interface
tools                           Tools for Package Development
utils                           The R Utils Package
