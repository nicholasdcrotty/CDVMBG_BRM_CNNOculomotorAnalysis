library(ggplot2)
rm(list=ls())
options(digits = 4) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Zenodo below
path = ""

setwd(paste(path, "/dataForDownload/environments", sep = ""))

load("CDVMBG_BRM_DistPredictionsAndEyeSorted.RData")


setwd(paste(path, "/dataForDownload/cnnResults/accuracies/trial-level accuracies from best epoch", sep = ""))

#CNN predicting distractor location from Massa et al. (2024) data
trialLevelValueLoc = read.csv("trialLevelAccuracy_MassaDistLoc_Decay.csv")
trialLevelValueLoc = trialLevelValueLoc[,2] #remove index column added by Excel
trialLevelValueLoc = as.data.frame(as.logical(trialLevelValueLoc))


transferAcc = read.csv("trialLevelAcc_TransferLearning_MassaDistOnDoyleDist_Decay.csv")
transferAcc = transferAcc[,2] #remove index column added by Excel
transferAcc = as.data.frame(as.logical(transferAcc))


#----- Massa et al. (2024)-----
setwd(path)

saccadeCNN_Massa = trialLevelValueLoc[!is.na(massaBeh$firstSacLocation.category),]
saccadeDF_Massa = massaBeh[!is.na(massaBeh$firstSacLocation.category),]

subjCNNAcc_Massa = aggregate(saccadeCNN_Massa, list(ID = saccadeDF_Massa$subjNum), mean)
subjSaccadeRates_Massa = aggregate(saccadeDF_Massa$firstSacLocation.category==saccadeDF_Massa$valueDistractorLocation, list(ID = saccadeDF_Massa$subjNum), mean)

names(subjCNNAcc_Massa) = c("ID", "x")
names(subjSaccadeRates_Massa) = c("ID", "x")

#----- stats -----
#saccade-present
#comparison for CNN acc and saccade landing for saccade present trials
t.test(subjCNNAcc_Massa$x, subjSaccadeRates_Massa$x, paired = TRUE)

DF4GRAPH_Massa = data.frame(cnn = subjCNNAcc_Massa$x, saccade = subjSaccadeRates_Massa$x, difference = subjCNNAcc_Massa$x - subjSaccadeRates_Massa$x)
means_Massa = as.data.frame(t(colMeans(DF4GRAPH_Massa)))
# bootstrapped subject-level 95% CIs
errorsSubj_Massa = data.frame()
for (c in 1:ncol(DF4GRAPH_Massa)){
  errorsSubj_Massa[1:2, c] = quantile(replicate(10000,mean(sample(DF4GRAPH_Massa[ , c],length(DF4GRAPH_Massa[ , c]), replace =TRUE))),c(.975,.025)) # subject level
  print(c)
}
colnames(errorsSubj_Massa) = colnames(DF4GRAPH_Massa)

#----- graph -----
massaSaccUnityPlot = ggplot()+
  geom_abline(slope = 1, intercept = 0, color = "black")+
  geom_point(data = DF4GRAPH_Massa, aes(x = saccade, y = cnn), color = "black", fill = "grey", alpha = 0.3, size = 3) +
  geom_point(data = means_Massa, aes(x = saccade, y = cnn), shape = 23, color = "black",fill = "black", size = 5) +
  coord_cartesian(xlim=c(0,0.4), ylim = c(0,0.4))+
  theme_classic()
plot(massaSaccUnityPlot)

massaSaccDiff = ggplot()+
  geom_col(data = means_Massa, aes(x=1, y = difference), color = "black", fill = "grey") + 
  geom_errorbar(data = errorsSubj_Massa, aes(x=1, ymax = errorsSubj_Massa[2,3], ymin = errorsSubj_Massa[1,3]), width = 0.5)+
  geom_point(data = DF4GRAPH_Massa, aes(x=1, y = difference), color = "black", fill = "black", alpha = 0.3, size = 3)+
  coord_cartesian(xlim = c(0,2), ylim = c(-.15,.2))+
  geom_hline(yintercept = 0, linetype = 2, alpha = 0.5)+
  theme_classic()
plot(massaSaccDiff)


#----- Doyle et al (2025) -----

saccadeCNN_Doyle = as.data.frame(transferAcc[!is.na(doyleBeh$firstSacLocation.category),])
saccadeDF_Doyle = doyleBeh[!is.na(doyleBeh$firstSacLocation.category),]

subjCNNAcc_Doyle = aggregate(saccadeCNN_Doyle, list(ID = saccadeDF_Doyle$subjNum), mean)
subjSaccadeRates_Doyle = aggregate(saccadeDF_Doyle$firstSacLocation.category==saccadeDF_Doyle$distractorLocation, list(ID = saccadeDF_Doyle$subjNum), mean)

names(subjCNNAcc_Doyle) = c("ID", "x")
names(subjSaccadeRates_Doyle) = c("ID", "x")

#stats
#saccade-present
#comparison for CNN acc and saccade landing for saccade present trials
t.test(subjCNNAcc_Doyle$x, subjSaccadeRates_Doyle$x, paired = TRUE)

DF4GRAPH_Doyle = data.frame(cnn = subjCNNAcc_Doyle$x, saccade = subjSaccadeRates_Doyle$x, difference = subjCNNAcc_Doyle$x - subjSaccadeRates_Doyle$x)

means_Doyle = as.data.frame(t(colMeans(DF4GRAPH_Doyle)))

# bootstrapped subject-level 95% CIs
errorsSubj_Doyle = data.frame()
for (c in 1:ncol(DF4GRAPH_Doyle)){
  errorsSubj_Doyle[1:2, c] = quantile(replicate(10000,mean(sample(DF4GRAPH_Doyle[ , c],length(DF4GRAPH_Doyle[ , c]), replace =TRUE))),c(.975,.025)) # subject level
  print(c)
}
colnames(errorsSubj_Doyle) = colnames(DF4GRAPH_Doyle)

#graph
doyleSaccUnityPlot = ggplot()+ #700 x 600
  geom_abline(slope = 1, intercept = 0, color = "black")+
  geom_point(data = DF4GRAPH_Doyle, aes(x = saccade, y = cnn), color = "black", fill = "grey", alpha = 0.3, size = 3) +
  geom_point(data = means_Doyle, aes(x = saccade, y = cnn), shape = 23, color = "black",fill = "black", size = 5) +
  coord_cartesian(xlim=c(0,0.4), ylim = c(0,0.4))+
  theme_classic()
plot(doyleSaccUnityPlot)

doyleSaccDiff = ggplot()+ #300 x 600
  geom_col(data = means_Doyle, aes(x=1, y = difference), color = "black", fill = "grey") + 
  geom_errorbar(data = errorsSubj_Doyle, aes(x=1, ymax = errorsSubj_Doyle[2,3], ymin = errorsSubj_Doyle[1,3]), width = 0.5)+
  geom_point(data = DF4GRAPH_Doyle, aes(x=1, y = difference), color = "black", fill = "black", alpha = 0.3, size = 3)+
  coord_cartesian(xlim = c(0,2), ylim = c(-.15,.2))+
  geom_hline(yintercept = 0, linetype = 2, alpha = 0.5)+
  theme_classic()
plot(doyleSaccDiff)
