# Statistical interpretation of CNN results through R/RStudio
This directory contains all of the R scripts we used to interpret the CNN results (as reported in the manuscript). To utilize these scripts, you will need: 
* A method of running .R code
* The **``dataForDownload``** folder, from the link provided [here](https://www.dropbox.com/scl/fo/gk3dmvuezb0x2jpfuaz25/ADTFmr_LaAReYmQpPYjJO-s?rlkey=m7qz4nl04vohbbmgu6jt9ihlv&st=7wfcqtui&dl=0)
* The file path (as a string) to where you downloaded the **``dataForDownload``** folder (which you'll assign to a variable called ``path`` at the beginning of every script)

## ``CDVMBG_BRM_FrequentistResults.R``
This script performs all of the frequentist results reported in the manuscript. This script will generate an ``.RData`` file that gets used in the Bayesian script (below) for quicker and simpler code.

## ``CDVMBG_BRM_BayesianModel.R``
Utilizing data structures generated from ``CDVMBG_BRM_FrequentistResults.R``, this script applies a heirarchical Bayesian model to the observed CNN accuracies, producing the posterior distributions reported in the manuscript.

## ``CDVMBG_BRM_MassaSHAPAnalysis.R``
This script conducts all of the supplementary SHAP analyses for the CNN predicting target location using Massa *et al.* (2024) data (Figures S1A &amp; S1C).

## ``CDVMBG_BRM_GrubbLiSHAPAnalysis.R``
This script conducts all of the supplementary SHAP analyses for the CNN predicting target location using Grubb & Li (2018) data (Figures S1B &amp; S1D).

## ``CDVMBG_BRM_distanceMinimization.R``
This script applies a distance minimization algorithm to the entire dataset from Massa *et al.* (2024), as described in the Supplementary Results.

## ``CDVMBG_BRM_TransferLearning_CNNAccVsDoyleMetricCorr.R``
This script compares the subject-level transfer learning CNN accuracy to the subject-level distractor attended rates from Doyle *et al.* (2025) via a correlation test, as reported in the Supplementary Results.
