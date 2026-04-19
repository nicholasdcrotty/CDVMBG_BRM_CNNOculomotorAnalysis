# Create environments for interpreting CNNs through R/RStudio 
This directory contains the two R scripts we used to generate environments that contained the relevant objects for analysis, with trials subsetted for  target-predicting CNNs or distractor-predicting CNNs when necessary. To utilize these scripts, you will need: 
* A method of running .R code
* The **``dataForDownload``** folder, from the link provided [here](https://doi.org/10.5281/zenodo.19489022)
* The file path (as a string) to where you downloaded the **``dataForDownload``** folder (which you'll assign to a variable called ``path`` at the beginning of every script)

## Files
### ``CDVMBG_BRM_GenerateDistractorLocationEnvironment.R``
This script generates the environment for all analyses of distractor-predicting CNNs.

### ``CDVMBG_BRM_GenerateTargetLocationEnvironment.R``
This script generates the environment for all analyses of target-predicting CNNs.
