library(ggplot2)
rm(list=ls())
options(digits = 4) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ""

chance = rep((1/6), times = 110) #define vector of chance values for t-tests

#----- Load in data -----
setwd(paste(path, "/dataForDownload/cnnResults/accuracies/trial-level accuracies from best epoch", sep = ""))

# CNN predicting target location from Massa et al. (2024) data
trialLevelAll = read.csv("trialLevelAccuracy_MassaTargLoc_Decay.csv")
trialLevelAll = trialLevelAll[,2] #remove index column added by Excel

#CNN predicting distractor location from Massa et al. (2024) data
trialLevelValueLoc = read.csv("trialLevelAccuracy_MassaDistLoc_Decay.csv")
trialLevelValueLoc = trialLevelValueLoc[,2] #remove index column added by Excel

# CNN predicting target location from Grubb & Li (2018) data
trialLevelTargLoc = read.csv("trialLevelAccuracy_GrubbLiTargLoc_Decay.csv")
trialLevelTargLoc = trialLevelTargLoc[,2] #remove index column added by Excel

# CNN predicting distractor location from Grubb & Li (2018) data
trialLevelDistLoc = read.csv("trialLevelAccuracy_GrubbLiDistLoc_Decay.csv")
trialLevelDistLoc = trialLevelDistLoc[,2] #remove index column added by Excel

#CNN trained on Massa et al. (2024) data and tested by predicting distractor location from Doyle et al. (2025) data
trialLevelTransferDist = read.csv("trialLevelAcc_TransferLearning_MassaDistOnDoyleDist_Decay.csv")
trialLevelTransferDist = trialLevelTransferDist[,2] #remove index column added by Excel

#Since Python and R save trues and falses differently (True/False vs. TRUE/FALSE), change "True" and "False" strings to booleans
trialLevelAll = as.data.frame(as.logical(trialLevelAll)) 
trialLevelTargLoc = as.data.frame(as.logical(trialLevelTargLoc))
trialLevelDistLoc = as.data.frame(as.logical(trialLevelDistLoc))
trialLevelValueLoc = as.data.frame(as.logical(trialLevelValueLoc))
trialLevelTransferDist = as.data.frame(as.logical(trialLevelTransferDist))


#add subject IDs
trialLevelAll$subjID = rep(1:72, each = 160)
trialLevelTargLoc$subjID = rep(1:97, each = 80)
trialLevelDistLoc$subjID = rep(1:97, each = 40)
trialLevelValueLoc$subjID = rep(1:72, each = 80)
trialLevelTransferDist$subjID = rep(1:110, each = 240)

# get subject-level accuracies, apply inferential statistics
subjLevelAll = vector()
subjLevelTargLoc = vector()
subjLevelDistLoc = vector()
subjLevelValueLoc = vector()
subjLevelTransferDist = vector()

for (s in 1:110){
  if(s <=72){
    subjLevelAll[s] = mean(trialLevelAll[trialLevelAll$subjID==s,ncol(trialLevelAll)-1])
    subjLevelValueLoc[s] = mean(trialLevelValueLoc[trialLevelValueLoc$subjID==s,ncol(trialLevelValueLoc)-1])
  }
  if(s<=97){
    subjLevelTargLoc[s] = mean(trialLevelTargLoc[trialLevelTargLoc$subjID==s,ncol(trialLevelTargLoc)-1])
    subjLevelDistLoc[s] = mean(trialLevelDistLoc[trialLevelDistLoc$subjID==s,ncol(trialLevelDistLoc)-1])
  }
  subjLevelTransferDist[s] = mean(trialLevelTransferDist[trialLevelTransferDist$subjID==s,ncol(trialLevelTransferDist)-1])
}

#----- Prep necessary dataframes for networks applied to Massa et al. (2024) -----

#trial-level accuracy dataframe for both target and distractor
DF4GRAPH = data.frame(cnn = trialLevelAll[,ncol(trialLevelAll)-1], valueDist = trialLevelValueLoc[,ncol(trialLevelValueLoc)-1])
colnames(DF4GRAPH) = c("all", "valueDist")

#subject-level accuracy dataframe for both target and distractor
subjLevels = data.frame(subjLevelAll=subjLevelAll, subjLevelValueLoc = subjLevelValueLoc)
colnames(subjLevels) = c("all", "valueDist")

#across-trial mean accuracies
means=  as.data.frame(t(colMeans(DF4GRAPH)))

#across-subject mean accuracies (same as across-trials b/c equal number of trials per participant)
meansSubj=  as.data.frame(t(colMeans(subjLevels)))

# bootstrapped subject-level 95% CIs
errorsSubj = data.frame()
for (c in 1:ncol(DF4GRAPH)){
  errorsSubj[1:2, c] = quantile(replicate(10000,mean(sample(subjLevels[ , c],length(subjLevels[ , c]), replace =TRUE))),c(.975,.025)) # subject level
  print(c)
}
colnames(errorsSubj) = colnames(subjLevels)

#sort subject-level accuracies by increasing magnitude for figures
magSortAll = data.frame(acc = subjLevels$all, ID = 1:72)#, naProp = naCountAll) # proportion for graphing on same axis
magSortVal = data.frame(acc = subjLevels$valueDist, ID = 1:72)

magSortAll = arrange(magSortAll, acc)
magSortAll$graphPlacement = 1:72
magSortVal = arrange(magSortVal, acc)
magSortVal$graphPlacement = 1:72

#----- Prep necessary dataframes for networks applied to Grubb & Li (2018) -----

#trial-level accuracy dataframe for both target and distractor
DF4GRAPH_GL = data.frame(targLoc = trialLevelTargLoc[,ncol(trialLevelTargLoc)-1], distLoc = trialLevelDistLoc[,ncol(trialLevelDistLoc)-1])#, 
colnames(DF4GRAPH_GL) = c("targLoc","distLoc")

#subject-level accuracy dataframe for both target and distractor
subjLevels_GL = data.frame(subjLevelTargLoc = subjLevelTargLoc, subjLevelDistLoc=subjLevelDistLoc)
colnames(subjLevels_GL) = c("targLoc", "distLoc")

#across-trial mean accuracies
means_GL=  as.data.frame(t(colMeans(DF4GRAPH_GL)))

#across-subject mean accuracies (same as across-trials b/c equal number of trials per participant)
meansSubj_GL=  as.data.frame(t(colMeans(subjLevels_GL)))

#bootstrapped subject-level 95% CIs
errorsSubj_GL = data.frame()
for (c in 1:ncol(DF4GRAPH_GL)){
  errorsSubj_GL[1:2, c] = quantile(replicate(10000,mean(sample(subjLevels_GL[ , c],length(subjLevels_GL[ , c]), replace =TRUE))),c(.975,.025)) # subject level
  print(c)
}
colnames(errorsSubj_GL) = colnames(subjLevels_GL)

#sort subject-level accuracies by increasing magnitude for figures
magSortTargLoc = data.frame(acc = subjLevels_GL$targLoc, ID = 1:97)
magSortDistLoc = data.frame(acc = subjLevels_GL$distLoc, ID = 1:97)

magSortTargLoc = arrange(magSortTargLoc, acc)
magSortTargLoc$graphPlacement = 1:97
magSortDistLoc = arrange(magSortDistLoc, acc)
magSortDistLoc$graphPlacement = 1:97

#----- Prep necessary dataframes for transfer learning network applied to Doyle et al. (2025) -----

#trial-level accuracy dataframe
DF4GRAPH_Doyle = data.frame(transfer = trialLevelTransferDist[,ncol(trialLevelTransferDist)-1])
colnames(DF4GRAPH_Doyle) = c("transfer")

#subject-level accuracy dataframe
subjLevels_Doyle = data.frame(subjLevelTransferDist = subjLevelTransferDist)
colnames(subjLevels_Doyle) = c("transfer")

#across-trial mean accuracy
means_Doyle=  as.data.frame(t(colMeans(DF4GRAPH_Doyle)))

#across-subject mean accuracy (same as across-trials b/c equal number of trials per participant)
meansSubj_Doyle=  as.data.frame(t(colMeans(subjLevels_Doyle)))

#bootstrapped subject-level 95% CI
errorsSubj_Doyle = data.frame()
for (c in 1:ncol(DF4GRAPH_Doyle)){
  errorsSubj_Doyle[1:2, c] = quantile(replicate(10000,mean(sample(subjLevels_Doyle[ , c],length(subjLevels_Doyle[ , c]), replace =TRUE))),c(.975,.025))
  print(c)
}
colnames(errorsSubj_Doyle) = colnames(subjLevels_Doyle)

#sort subject-level accuracy by increasing magnitude for figures
magSortTransfer = data.frame(acc = subjLevels_Doyle$transfer, ID = 1:110)

magSortTransfer = arrange(magSortTransfer, acc)
magSortTransfer$graphPlacement = 1:110

#----- Generate figures -----

#Figure 3A
MASSA_TARG = ggplot() +
  geom_vline(xintercept=(1/6), color ="black", linewidth = 1) +
  geom_point(data = magSortAll, aes(x=acc, y = graphPlacement), color = "black", fill ="grey", pch=21, size = 3)+
  geom_errorbar(data=errorsSubj,aes(y=75,xmax=errorsSubj[1,1],xmin=errorsSubj[2,1]), width = 0.5, linewidth = 0.5) +
  geom_point(data = means, aes(y=75, x=all), color = "black", fill ='black', pch=23, shape=18, size = 5) +
  labs(x="Prediction Accuracy - Target Location", y="Participant-Massa Dataset") +
  scale_x_continuous(breaks=seq(0, 1, by = .1)) +
  coord_cartesian(xlim=c(0,1))+ # change to "bound" if want different axes for contrast graph and 0-1 for others
  theme_classic()
plot(MASSA_TARG)

#Figure 3C
GRUBB_LI_TARG = ggplot() +
  geom_vline(xintercept=(1/6), color ='black', linewidth = 1) +
  geom_point(data = magSortTargLoc, aes(x=acc, y = graphPlacement), color = "black", fill ="grey", pch=21, size = 3)+
  geom_errorbar(data=errorsSubj_GL,aes(y=101,xmax=errorsSubj_GL[1,1],xmin=errorsSubj_GL[2,1]), width = 0.5, linewidth = 0.5) +
  geom_point(data = means_GL, aes(y=101, x=targLoc), color ="black", fill ='black', pch=23, shape=18, size = 5) +
  labs(x="Prediction Accuracy - Distractor Location", y="Participant-Grubb & Li Dataset") +
  scale_x_continuous(breaks=seq(0,1, by = .1)) +
  coord_cartesian(xlim=c(0,1))+ # change to "bound" if want different axes for contrast graph and 0-1 for others
  theme_classic()
plot(GRUBB_LI_TARG)

#Figure 4A
MASSA_DIST = ggplot() +
  geom_vline(xintercept=(1/6), color ="black", linewidth = 1) +
  geom_point(data = magSortVal, aes(x=acc, y = graphPlacement), color = "black", fill ="grey", pch=21, size = 2)+
  
  geom_errorbar(data=errorsSubj,aes(y=73,xmax=errorsSubj[1,2],xmin=errorsSubj[2,2]), width = 0.5, linewidth = 0.5) +
  geom_point(data = means, aes(y=73, x=valueDist), color = "black", shape=18, size = 5) +
  labs(x="Prediction Accuracy - Distractor Location", y="Participant-Massa Dataset") +
  scale_x_continuous(breaks=seq(0,1, by = .1)) +
  coord_cartesian(xlim=c(0,0.5))+
  theme_classic()
plot(MASSA_DIST)

#Figure 4C
GRUBB_LI_DIST = ggplot() +
  geom_vline(xintercept=(1/6), color ="black", linewidth = 1) +
  geom_point(data = magSortDistLoc, aes(x=acc, y = graphPlacement), color = "black", fill ="grey", pch=21, size = 2)+
  
  geom_errorbar(data=errorsSubj_GL,aes(y=101,xmax=errorsSubj_GL[1,2],xmin=errorsSubj_GL[2,2]), width = 0.5, linewidth = 0.5) +
  geom_point(data = means_GL, aes(y=101, x=distLoc), color = "black", shape=18, size = 5) +
  labs(x="Prediction Accuracy - Distractor Location", y="Participant-Grubb & Li Dataset") +
  scale_x_continuous(breaks=seq(0,1, by = .1)) +
  coord_cartesian(xlim=c(0,0.5))+ 
  theme_classic()
plot(GRUBB_LI_DIST)

#Figure 5A
DOYLE = ggplot() +
  geom_vline(xintercept=(1/6), color ="black", linewidth = 1) +
  geom_point(data = magSortTransfer, aes(x=acc, y = graphPlacement), color = "black", fill ="grey", pch=21, size = 2)+
  geom_errorbar(data=errorsSubj,aes(y=111,xmax=errorsSubj_Doyle[1,1],xmin=errorsSubj_Doyle[2,1]), width = 0.5, linewidth = 0.5) +
  geom_point(data = means_Doyle, aes(y=111, x=transfer), color = "black", shape=18, size = 3) +
  labs(x="Prediction Accuracy - Distractor Location", y="Participant-Doyle Dataset (Massa transfer)") +
  scale_x_continuous(breaks=seq(0,0.5, by = .1)) +
  coord_cartesian(xlim=c(0,0.5))+ 
  theme_classic()
plot(DOYLE)

#----- Report statistics -----
print("CNN predicting target location from Massa et al. (2024) data")
print(c("Overall accuracy: ", means$all))
print(c("Mean across subjects: ", meansSubj$all))
print(c("bootstrapped subject-level 95% CI: ", rev(as.vector(errorsSubj$all))))
print("t-test comparing to chance: ")
t.test(magSortAll$acc, chance[1:72], paired = TRUE)

print("CNN predicting target location from Grubb & Li (2018) data")
print(c("Overall accuracy: ", means_GL$targLoc))
print(c("Mean across subjects: ", meansSubj_GL$targLoc))
print(c("bootstrapped subject-level 95% CI: ", rev(as.vector(errorsSubj_GL$targLoc))))
print("t-test comparing to chance: ")
t.test(magSortTargLoc$acc, chance[1:97], paired = TRUE)

print("CNN predicting distractor location from Massa et al. (2024) data")
print(c("Overall accuracy: ", means$valueDist))
print(c("Mean across subjects: ", meansSubj$valueDist))
print(c("bootstrapped subject-level 95% CI: ", rev(as.vector(errorsSubj$valueDist))))
print("t-test comparing to chance: ")
t.test(magSortVal$acc, chance[1:72], paired = TRUE)

print("CNN predicting distractor location from Grubb & Li (2018) data")
print(c("Overall accuracy: ", means_GL$distLoc))
print(c("Mean across subjects: ", meansSubj_GL$distLoc))
print(c("bootstrapped subject-level 95% CI: ", rev(as.vector(errorsSubj_GL$distLoc))))
print("t-test comparing to chance: ")
t.test(magSortDistLoc$acc, chance[1:97], paired = TRUE)

print("CNN trained on Massa et al. (2024) data and predicting distractor location from Doyle et al. (2025) data")
print(c("Overall accuracy: ", means_Doyle$transfer))
print(c("Mean across subjects: ", meansSubj_Doyle$transfer))
print(c("bootstrapped subject-level 95% CI: ", rev(as.vector(errorsSubj_Doyle$transfer))))
print("t-test comparing to chance: ")
t.test(magSortTransfer$acc, chance, paired = TRUE)
