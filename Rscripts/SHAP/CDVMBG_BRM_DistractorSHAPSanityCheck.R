library(ggplot2)
rm(list=ls())
options(digits = 4) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ""

#----- Load in data -----
setwd(paste(path, "/dataForDownload/environments", sep = ""))
load("CDVMBG_BRM_DistPredictionsAndEyeSorted.RData")

setwd(paste(path, "/dataForDownload/cnnResults/SHAP", sep = ""))
massaSHAP = read.csv("shapValues_MassaDistLoc_Decay.csv")
massaSHAP$X = NULL

grubbLiSHAP = read.csv("shapValues_GrubbLiDistLoc_Decay.csv")
grubbLiSHAP$X = NULL



#----- Massa et al. (2024): Pre-processing -----
massaSHAP = massaSHAP[!is.na(massaBeh$RT),]
massaBeh = massaBeh[!is.na(massaBeh$RT),]

massaSHAP = massaSHAP[massaBeh$RT > 0,]
massaBeh = massaBeh[massaBeh$RT > 0,]



#----- Massa et al. (2024): plotting -----
massaMaxSHAPs = 2*max.col(massaSHAP) #multiplying by 2 b/c of 500Hz sampling rate

corrDF_Massa = data.frame(RTs = massaBeh$RT, maxSHAPs = massaMaxSHAPs)

#Plot of maximum SHAP value position vs. observed RT -- Figure S1A
massaPlot = ggplot()+
  geom_point(data = corrDF_Massa, aes(x=RTs, y =maxSHAPs),, color = "black", fill = "grey", pch = 21, alpha = 0.3)+
  geom_abline(slope = 1, intercept = 0, color = "black")+
  coord_cartesian(xlim=c(0,1175), ylim=c(0,1175))+
  labs(x="RT", y="Position of maximum SHAP value") +
  theme_classic()
plot(massaPlot)



#----- Grubb & Li (2018): Pre-processing -----
grubbLiSHAP = grubbLiSHAP[!is.na(grubbLiRT[,1]),]
grubbLiRT = grubbLiRT[!is.na(grubbLiRT[,1]),]

grubbLiSHAP = grubbLiSHAP[grubbLiRT > 0,] #`grubbLiRT` now vector after removing RTs above
grubbLiRT = grubbLiRT[grubbLiRT > 0]

#----- Grubb & Li (2018): Plotting -----
grubbLiMaxSHAPs = 2*max.col(grubbLiSHAP) #multiplying by 2 b/c of 500Hz sampling rate

corrDF_GrubbLi = data.frame(RTs = grubbLiRT, maxSHAPs = grubbLiMaxSHAPs)

#Plot of maximum SHAP value position vs. observed RT -- Figure S1B
grubbLiPlot = ggplot()+
  geom_point(data = corrDF_GrubbLi, aes(x=RTs, y =maxSHAPs), color = "black", fill = "grey", pch = 21, alpha = 0.3)+
  geom_abline(slope = 1, intercept = 0, color = "black")+
  coord_cartesian(xlim=c(0,1175), ylim=c(0,1175))+ #1200ms long trial
  labs(x="RT", y="Position of maximum SHAP value") +
  theme_classic()
plot(grubbLiPlot)

