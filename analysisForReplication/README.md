# Replicating results described in Crotty, Doyle, Volkova, Massa, Benson, & Grubb (in prep)
(Intro sentence) To utilize these scripts, you will need:
* A method of running ``.ipynb`` scripts
* the files in the **``oculomotorData``** folder, linked [here](https://www.dropbox.com/scl/fo/gk3dmvuezb0x2jpfuaz25/AJQ7Um4zI_vkfxxY9t8NUq0/oculomotorData?dl=0&rlkey=m7qz4nl04vohbbmgu6jt9ihlv&subfolder_nav_tracking=1)
* the model weights stored in the **``weights``** folder, linked [here](https://www.dropbox.com/scl/fo/gk3dmvuezb0x2jpfuaz25/AOSgUAwEjWDmd8Pp3jiqfZo/cnnResults/weights?dl=0&rlkey=m7qz4nl04vohbbmgu6jt9ihlv&subfolder_nav_tracking=1)

## ``CDVMBG_BRM_CNNBasedAnalysis_ForReplication.ipynb``
This script conducts the CNN-based analyses for the networks predicting target location and those predicting distractor location in Massa *et al.* (2024) and Grubb &amp; Li (2018).

## ``CDVMBG_BRM_CNNModelGeneralizability.ipynb``
This script conducts the assessment of model generalizability, in which the network trained on the Massa *et al.* (2024) dataset is applied to the eye traces from Doyle *et al.* (2025).
