library(ggplot2)
rm(list=ls())
options(digits = 10) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ""

#----- Load in data -----
setwd(paste(path, "/dataForDownload/cnnResults/accuracies/trial-level accuracies from best epoch", sep = ""))
transferAcc = read.csv("trialLevelAcc_TransferLearning_MassaDistOnDoyleDist_Decay.csv")
transferAcc = transferAcc[,2]
transferAcc = as.data.frame(as.logical(transferAcc))
names(transferAcc) = "cnnAcc"

setwd(paste(path, "/dataForDownload/behavioralData", sep = ""))
doyleData = read.csv("CDVMBG_BRM_Doyle_distractorAttended.csv")


#----- Prep data and perform correlation -----
#exclude distractor-absent trials
doyleDataDist = doyleData[doyleData$distractorIsPresent==1,]

#set up correlation df + aggregate summary
correlationDF = data.frame(cnnAcc = transferAcc$cnnAcc, attendedDist = doyleDataDist$distractorIsAttended, ID = doyleDataDist$subjID)
corrSummary = aggregate(correlationDF, list(ID = correlationDF$ID), mean, na.rm = TRUE) #only removes cells with NA, not whole row

cor.test(corrSummary$cnnAcc, corrSummary$attendedDist)
