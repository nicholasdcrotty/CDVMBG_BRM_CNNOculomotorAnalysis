# Statistical interpretation of CNN results through R/RStudio
This directory contains all of the R scripts we used to interpret the CNN results (as reported in the manuscript). To utilize these scripts, you will need: 
* A method of running .R code
* The **``dataForDownload``** folder, from the link provided [here](https://doi.org/10.5281/zenodo.19489022)
* The file path (as a string) to where you downloaded the **``dataForDownload``** folder (which you'll assign to a variable called ``path`` at the beginning of every script)

## Folders
### `SHAP`
Contains all R scripts related to the SHAP analysis of both distractor-predicting and target-predicting CNNs.

### `Environments`
Contains all scripts used to generate the .RData environments that contain the objects necessary for analysis.

## Files
### ``CDVMBG_BRM_FrequentistResults.R``
This script performs all of the frequentist results reported in the manuscript. This script will generate an ``.RData`` file that gets used in the Bayesian script (below) for quicker and simpler code.

### ``CDVMBG_BRM_BayesianModel.R``
Utilizing data structures generated from ``CDVMBG_BRM_FrequentistResults.R``, this script applies a heirarchical Bayesian model to the observed CNN accuracies, producing the posterior distributions reported in the manuscript.

### ``CDVMBG_BRM_SaccadeAnalysis.R``
This script compares distractor-predicting CNN participant-level classification accuracy to the participant-level proportions of first saccades landing near distractors, both for Massa *et al.* (2024) data and Doyle *et al.* (2025) data.

### ``CDVMBG_BRM_TargetConfusionAnalysis.R``
This script generates confusion matrices for the predictions of the target-predicting CNNs applied to Massa *et al.* (2024) data and Grubb &amp; Li (2018) data .

### ``CDVMBG_BRM_distanceMinimization.R``
This script applies a distance minimization algorithm to the entire dataset from Massa *et al.* (2024), as described in the Supplementary Results.

