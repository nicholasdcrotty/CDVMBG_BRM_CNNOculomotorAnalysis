# Replicating results described in Crotty, Doyle, Volkova, Massa, Benson, & Grubb (in prep)
(Intro sentence) To utilize these scripts, you will need:
* A method of running ``.ipynb`` scripts
* the files in the **``oculomotorData``** folder within the **`dataForDownload`** folder, linked [here](https://doi.org/10.5281/zenodo.19489022)
* the model weights stored in the **``weights``** folder within the **`dataForDownload`** folder, linked [here](https://doi.org/10.5281/zenodo.19489022)
Note: If you're using Google Colab (as we did), use the GUI to get the necessary files into the environment - it's a lot faster than within-code functions for reading all those large .csv files (for some reason). 

## ``CDVMBG_BRM_CNNBasedAnalysis_ForReplication.ipynb``
This script conducts the CNN-based analyses for the networks predicting target location and those predicting distractor location in Massa *et al.* (2024) and Grubb &amp; Li (2018).

## ``CDVMBG_BRM_CNNModelGeneralizability.ipynb``
This script conducts the assessment of model generalizability, in which the network trained on the Massa *et al.* (2024) dataset is applied to the eye traces from Doyle *et al.* (2025).
