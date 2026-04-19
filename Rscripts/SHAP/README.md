# Statistical interpretation of CNN results through R/RStudio - SHAP analysis
This directory contains all of the SHAP-related R scripts we used to interpret what patterns in the eye data were most informative for CNN classification (as reported in the manuscript). To utilize these scripts, you will need: 
* A method of running .R code
* The **``dataForDownload``** folder, from the link provided [here](https://doi.org/10.5281/zenodo.19489022)
* The file path (as a string) to where you downloaded the **``dataForDownload``** folder (which you'll assign to a variable called ``path`` at the beginning of every script)

Note: The R script **`CDVMBG_BRM_SpatialSHAPFunctions.R`** is also located in the **``dataForDownload``** folder (under the `environments` tab) as it gets loaded into other scripts via a `source` call (*i.e.*, it functions just like all the `.RData` environments used in the analysis).

## What is a SHAP analysis?
(PLAIN-LANGUAGE DESCRIPTION HERE)

## Files
### ``CDVMBG_BRM_MassaTargSHAPAnalysis.R``
This script focuses on temporal patterns in feature importance for the CNN predicting target location using Massa *et al.* (2024) data. It compares the timing of trial-level maximum SHAP values to the corresponding response time (RT), then time-locks all trials to the RT and illustrates how feature importance changes along the time-locked timecourse.

### ``CDVMBG_BRM_GrubbLiTargSHAPAnalysis.R``
This script focuses on temporal patterns in feature importance for the CNN predicting target location using Grubb &amp; (2018) data. It compares the timing of trial-level maximum SHAP values to the corresponding response time (RT), then time-locks all trials to the RT and illustrates how feature importance changes along the time-locked timecourse.

### ``CDVMBG_BRM_MassaSpatialSHAP_Distractor.R``
This script focuses on spatial patterns in feature importance for the CNN predicting distractor location using Massa *et al.* (2024) data. It plots out the position of maximum SHAP values after aligning all distractors, then performs a Gaussian-weighted kernel density estimate (KDE) on the resulting distribution of points.

### ``CDVMBG_BRM_GrubbLiSpatialSHAP_Distractor.R``
This script focuses on spatial patterns in feature importance for the CNN predicting distractor location using Grubb &amp; (2018) data. It plots out the position of maximum SHAP values after aligning all distractors, then performs a Gaussian-weighted KDE on the resulting distribution of points.

### ``CDVMBG_BRM_DoyleSpatialSHAP_Distractor.R``
This script focuses on *both* spatial and temporal patterns in feature importance, for the distractor-predicting CNN trained on Massa *et al.* (2024) data, and tested on Doyle *et al.* (2025) data. It plots out the position of maximum SHAP values after aligning all distractors, performs a Gaussian-weighted KDE on the resulting distribution of points, then generates a polar angle histogram of this distribution with color indicating trial-level timing. 

### ``CDVMBG_BRM_MassaSpatialSHAP_Target.R``
This script focuses on spatial patterns in feature importance for the CNN predicting target location using Massa *et al.* (2024) data. It plots out the position of maximum SHAP values after aligning all targets, then performs a Gaussian-weighted KDE on the resulting distribution of points. 

### ``CDVMBG_BRM_GrubbLiSpatialSHAP_Target.R``
This script focuses on spatial patterns in feature importance for the CNN predicting target location using Grubb &amp; (2018) data. It plots out the position of maximum SHAP values after aligning all target, then performs a Gaussian-weighted KDE on the resulting distribution of points.

### ``CDVMBG_BRM_DistractorSHAPSanityCheck.R``
This script compares the timing of trial-level maximum SHAP values to the corresponding RT for both trained distractor-predicting CNNs.

### ``CDVMBG_BRM_DistractorSHAPSanityCheck.R``
This script contains all of the functions used in the SHAP analyses outlines above.
