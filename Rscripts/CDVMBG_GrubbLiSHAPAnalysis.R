library(ggplot2)
rm(list=ls())
options(digits = 10) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ""

#----- Load in data -----
setwd(paste(path, "/dataForDownload/cnnResults/SHAP", sep = ""))
shapData = read.csv("shapValues_GrubbLiTargLoc_Decay.csv")
shapData$X = NULL

setwd(paste(path, "/dataForDownload/behavioralData", sep = ""))
behData = read.csv("CDVMBG_BRM_GrubbLi_RT.csv")

#preprocess
shapData = shapData[!is.na(behData$RT),]
behData = behData[!is.na(behData$RT),]



#----- Time-locking function -----
timeLockToRT = function(timeCourseData, behavioralData){
  counter = 1
  maxRT_asSample = round(max(behavioralData$RT) / 2)
  if(maxRT_asSample > ncol(timeCourseData)){maxRT_asSample = ncol(timeCourseData)}
  
  timeLockedDF = array(dim = c(nrow(timeCourseData), maxRT_asSample)) 
  
  for (row in 1:nrow(timeCourseData)){
    timecourse = as.vector(t(timeCourseData[row,]))
    RT_asSample = round(behavioralData$RT[row] / 2)
    if (RT_asSample > maxRT_asSample){RT_asSample = maxRT_asSample}
    if (RT_asSample < 0){RT_asSample = 1} #negative RTs in Grubb & Li
    endingPadding = maxRT_asSample - RT_asSample
    timeLockedDF[row, 1:endingPadding] = NA
    timeLockedDF[row, (endingPadding + 1):maxRT_asSample] = timecourse[1:RT_asSample]
    print(counter)
    counter = counter +1
  }
  print("Done!")
  return(timeLockedDF)
}

#----- Generate Figure S1B -----
RTs = behData$RT 
maxSHAPs = 2*max.col(shapData) #multiplying by 2 b/c of 500Hz sampling rate
maxSHAPVal = apply(shapData, 1, max) # get actual shap values at positions

corrDF = data.frame(RTs = RTs, maxSHAPs = maxSHAPs, maxSHAPVal=maxSHAPVal)
corrDF = corrDF[!is.na(corrDF$RTs),]

#Plot of maximum SHAP value position vs. observed RT -- Figure S1B
g = ggplot()+
  geom_point(data = corrDF, aes(x=RTs, y =maxSHAPs), color = "black", fill = "grey", pch = 21, alpha = 0.3)+
  geom_abline(slope = 1, intercept = 0, color = "black")+
  coord_cartesian(xlim=c(0,1175), ylim=c(0,1175))+ #1200ms long trial
  labs(x="RT", y="Position of maximum SHAP value") +
  theme_classic()
plot(g)



#----- Generate Figure S1D -----
timeLockedSHAPs = timeLockToRT(timeCourseData = shapData, behavioralData = behData)

#Uncomment the lines below if you want to generate your own error bars -- this takes a long time
# errorsTimeLocked = data.frame()
# for (c in 1:ncol(timeLockedSHAPs)){
#   #errors[1:2, c] = quantile(replicate(10000,mean(sample(shapData[ , c],length(shapData[ , c]), replace =TRUE))),c(.975,.025))
#   errorsTimeLocked[1:2, c] = quantile(replicate(10000,mean(sample(timeLockedSHAPs[ , c],length(timeLockedSHAPs[ , c]), replace =TRUE), na.rm = TRUE)),c(.975,.025), na.rm = TRUE) #time locked
#   print(c)
# }
#write.csv(errorsTimeLocked,"CDVMBG_GrubbLi_shapErrorBars.csv")

#Use the chunk below if you want to read in the .csv of previously-generated error bars
setwd(paste(path, "/dataForDownload/shapErrorBars", sep = ""))
errorsTimeLocked = read.csv("CDVMBG_GrubbLi_shapErrorBars.csv")
errorsTimeLocked$X = NULL

#prepare data for graph
avgTimeCourse_TimeLocked = colMeans(timeLockedSHAPs, na.rm = TRUE)
DF4GRAPH = data.frame(sample = seq(1,length(avgTimeCourse_TimeLocked)*2, by =2), 
                                    avgTimeCourse_TimeLocked = avgTimeCourse_TimeLocked,
                                    upperBound = as.vector(t(errorsTimeLocked[1,])), lowerBound = as.vector(t(errorsTimeLocked[2,])))

#time-locked average trial -- Figure S1D
g2 = ggplot() +
  geom_ribbon(data =DF4GRAPH, aes(x = sample, ymin = lowerBound, ymax = upperBound), color = "grey", fill = "grey") +
  geom_line(data = DF4GRAPH, aes(x = sample, y = avgTimeCourse_TimeLocked), color = "black") +
  geom_hline(yintercept = 0,linetype = 2) +
  coord_cartesian(ylim = c(0, 0.25)) + 
  theme_classic()
plot(g2)
