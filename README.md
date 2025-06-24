# CDVMBG_BRM_CNNOculomotorAnalysis
This repository contains the scripts for a CNN-based analysis of time-course oculomotor data, as described in Crotty, Doyle, Volkova, Massa, Benson, &amp; Grubb (in prep).

**NOTE:** All associated data and results (see **Data** below) are freely available [here](https://www.dropbox.com/scl/fo/gk3dmvuezb0x2jpfuaz25/ADTFmr_LaAReYmQpPYjJO-s?rlkey=m7qz4nl04vohbbmgu6jt9ihlv&st=7wfcqtui&dl=0). Due to Github file size constraints, these files couldn't be included in the current repo.

## Authors:
**Nicholas Crotty**

Trinity College, Hartford, CT, USA


**Alenka Doyle**

Trinity College, Hartford, CT, USA

**Kamilla Volkova**

Trinity College, Hartford, CT, USA

**Nicole Massa**

Mass General Brigham, Boston, MA, USA

**Noah C. Benson**

eScience Institute, University of Washington, Seattle, WA, USA

**Michael A. Grubb** -- Corresponding Author (michael.grubb@trincoll.edu)

Trinity College, Hartford, CT, USA

## Contents
### ``analysisForReplication``: 
This folder contains all of the analysis scripts (as .ipynb files) we utilized to produce the results reported in the manuscript.

### ``analysisForUser``: 
This folder contains a script (as a .ipynb file) designed to be a framework for users to apply our approach to their own data.

### ``Rscripts``
This folder contains all of the .R files we used for the statistical interpretation of the CNN results, as well as the summary files for the Bayesian models.

### ``README.md``
The README file you're reading right now.

### ``LICENSE``
This project has been posted under an MIT license. 

## Data
As mentioned earlier, all of the relevant data for this project is available [here](https://www.dropbox.com/scl/fo/gk3dmvuezb0x2jpfuaz25/ADTFmr_LaAReYmQpPYjJO-s?rlkey=m7qz4nl04vohbbmgu6jt9ihlv&st=7wfcqtui&dl=0). Here is what each file contains:

### ``cnnResults``
Contains the results from the CNN-based analyses that we report in the manuscript, including the trial-level CNN accuracies, SHAP values, and model weights.

### ``oculomotorData``
Contains the raw eye traces and experimental conditions files from all three studies used in the reported analyses.

### ``behavioralData``
Contains the behavioral data used in the supplementary analysis, including the RTs for Massa *et al.* (2024) and Grubb &amp; Li (2018), as well as the distractor-attended info from Doyle *et al.* (2025)

### ``shapErrorBars``
Contains .csv files of the sample-level error bars for the time-locked SHAP analysis (in case the user doesn't want to run the computationally exhaustive script that generates these error bars)

## Acknowledgements
This work was funded by NSF CAREER #2141860 to MAG and NIH grant R01EY033628 to NCB.
