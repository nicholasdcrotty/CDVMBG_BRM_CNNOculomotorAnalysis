# Statistical interpretation of CNN results through R/RStudio
This directory contains all of the R scripts we used to interpret the CNN results (as reported in the manuscript). To utilize these scripts, you will need: 
* A method of running .R code
* The **``dataForDownload``** folder, from the link provided [here](https://www.dropbox.com/scl/fo/gk3dmvuezb0x2jpfuaz25/ADTFmr_LaAReYmQpPYjJO-s?rlkey=m7qz4nl04vohbbmgu6jt9ihlv&st=7wfcqtui&dl=0)
* The file path to where you downloaded the **``dataForDownload``** folder 

## ``CDVMBG_MassaSHAPAnalysis.R``
This script conducts all of the supplementary SHAP analyses for the CNN prediciting target location using Massa *et al.* (2024) data (Figures S1A &amp; S1C).

## ``CDVMBG_GrubbLiAnalysis.R``
This script conducts all of the supplementary SHAP analyses for the CNN prediciting target location using Grubb & Li (2018) data (Figures S1B &amp; S1D).

## ``CDVMBG_TransferLearning_CNNAccVsDoyleMetricCorr.R``
This script compares the subject-level transfer learning CNN accuracy to the subject-level distractor attended rates from Doyle *et al.* (2025) via a correlation test, as reported in the Supplementary Results.
