# SHAP analysis of CNNs through R/RStudio 
This directory contains all of the SHAP-related R scripts we used to interpret what patterns in the eye data were most informative for CNN classification (as reported in the manuscript). To utilize these scripts, you will need: 
* A method of running .R code
* The **``dataForDownload``** folder, from the link provided [here](https://doi.org/10.5281/zenodo.19489022)
* The file path (as a string) to where you downloaded the **``dataForDownload``** folder (which you'll assign to a variable called ``path`` at the beginning of every script)

Note: The R script **`CDVMBG_BRM_SpatialSHAPFunctions.R`** is also located in the **``dataForDownload``** folder (under the `environments` tab) as it gets loaded into other scripts via a `source` call (*i.e.*, it functions just like all the `.RData` environments used in the analysis).



## What is a "SHAP analysis"?
In broad terms, a SHapley Additive exPlanation (SHAP) analysis quantifies how much each feature in a model's input influences the overall prediction of the model. In our case, SHAP analysis quantifies how much every sample of gaze (x- and y-position) in each trial's timecourse contributed to the CNN's prediction of object location (either target or distractor location). This approach is derived from a game theory concept known as Shapley values (hence the name), which signify the fair payout of each player in a collaborative game given their contribution to the game's outcome. Translating from game theory parlance, Shapley values are calculated for every feature of an input to a given model through the following: 
1. Taking a subset of the input that includes a given feature and finding the model's output for that subset
2. Find the model's output for the same subset but with the given feature removed (the "explainer model")
3. Calculating the difference between the two outputs
4. Repeating steps 1-3 for every possible subset of the input that includes the feature
5. Calculating a weighted sum of these differences (to get the Shapley value for one feature)
6. Repeating steps 1-5 for every input feature (to get the Shapley values for every feature)

The benefit of Shapley values (and thus SHAP values) is that they are additive: the overall model output is equal to the sum of all Shapley values plus the model's output when there are no input features. This additivity means that SHAP values have several nice properties that other feature attribution methods do not (we won't go over these here, but they're nicely explained in Lundburg & Lee, 2017).

Rather than calculating exact Shapley values, SHAP analysis approximates them for more computational efficiency. In the context of machine learning, the simplest way to estimate a given feature's Shapley value would be to retrain your model on an input subset containing the feature, find the difference between the resulting prediction and that of the explainer model trained on the feature-removed subset, repeat for all possible subsets, and compute the weighted sum of differences. While this works great for simpler regression models, using this approach for deeper/ more complex models is really computationally expensive. SHAP instead approximates Shapley values for a conditional expectation of the model's prediction. In other words, instead of removing a feature and retraining the explainer model, SHAP approximates the expected value of the model's prediction given that the features are those not set to 0 by a mapping function. There are several different ways to approximate SHAP values; we used Deep SHAP, which is designed for deeper networks and calculates the expected value through the DeepLIFT algorithm (see Shrikumar *et al.*, 2016). 

One point of note: a SHAP analysis applied to classifier models (such as the CNNs used presently) produces a unique SHAP value for every possible class to predict, not just the one that the model actually predicted. This means that the SHAP analysis performed on the *number-of-trials X number-of-samples-in-each-trial X 2* validation set (the 2 comes from the fact that there's an x-position and y-position value in each sample) produces a *number-of-trials X number-of-samples-in-each-trial X 2 X number-of-possible-object-locations* array. Here, large positive numbers mean that the given trial-level sample pushes the prediction towards a specific class and large negative numbers mean that the trial-level sample pulls the prediction away from a given class. Since we are more concerned about the overall importance of a given sample rather that its contribution to a given class, we take the absolute value of every SHAP value and average across classes (see the `.ipynb` files in the `analysisForReplication` folder for where we compute this). We then average across x- and y-position to get a single number for each sample.  Thus, our SHAP analysis produces a *number-of-trials X number-of-samples-in-each-trial* matrix of positive values, which gets read into the R scripts described below as a `.csv` file. In the manuscript, we refer to these max average SHAP values as just 'SHAP values' for simplicity's sake. 

If you'd like some additional explanation, Scott Lundberg and Su-In Lee provide a nice walkthrough in their [2017 seminal publication](https://arxiv.org/pdf/1705.07874), comparing SHAP to other feature explanation methods and describing different ways of approximating SHAP values. For a more hands-on approach, see the [tutorial](https://shap.readthedocs.io/en/latest/example_notebooks/overviews/An%20introduction%20to%20explainable%20AI%20with%20Shapley%20values.html) in the `shap` package documentation. 

**TL,DR:**  SHAP values quantify the contribution of each input feature (in our case, every gaze sample in each trial's timecourse) to a model's output (in our case, the CNNs' trial-level predictions of target/distractor location). We used a version of SHAP best suited to deeper models and calculated overall feature importance rather than how much a feature pushes/pulls the model towards predicting a specific location.

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
