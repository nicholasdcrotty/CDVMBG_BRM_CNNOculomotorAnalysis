library(ggplot2)
library(eyelinkReader)
rm(list=ls())
options(digits = 10)
set.seed(1823)
path1 = "C:/Users/nicho/OneDrive - Trinity College"
path2 = "/Users/nickcrotty/Library/CloudStorage/OneDrive-TrinityCollege"
if(file.exists(path1)){
  path = path1
  print("Windows")
} else if(file.exists(path2)){
  path= path2
  print("MacOS")
} else { 
  print("No path :( ")}

screenRes = c(2559,1439)
origin = screenRes/2

targetLocations_inPixels = data.frame(targetLocation = c(0, 60, 120, 180, 240, 300),
                                        targetX = c(1559.5, 1419.5, 1139.5, 999.5, 1139.5, 1419.5), 
                                        targetY = c(719.5, 477.5, 477.5, 719.5, 961.5, 961.5))
rownames(targetLocations_inPixels) = targetLocations_inPixels$targetLocation


correctGuess = vector()
randomGuess = FALSE
actualGuesses = vector()

setwd(paste(path, "/NicoleVDACThesis/DNN_TimeCourse", sep = ""))
xData = read.csv("CDVMBG_BRM_Massa_XPos.csv")
xData$X = NULL
yData = read.csv("CDVMBG_BRM_Massa_YPos.csv")
yData$X = NULL
labels = read.csv("CDVMBG_BRM_Massa_Conditions.csv")
labels$X = NULL

averageDistances = matrix(nrow = nrow(xData), ncol = 6)
index = 1
for (t in 1:nrow(xData)){# all files saved under gaze
  tsx = as.vector(t(xData[t,]))
  #undo preprocessing of NAs 
  tsx[tsx == origin[1]] = NA
  
  if ( max(is.na(tsx)) == 1 & length(unique(is.na(tsx))) ==1 ){#random guessing if no eye data
    if (randomGuess == TRUE){
      guess =targetLocations_inPixels$targetLocation[sample(nrow(targetLocations_inPixels), size = 1)]
    } else if (randomGuess ==FALSE){
      guess = NA
    }
    
  } else {
    #tsx[tsx>screenRes[1]] = screenRes[1]
    #tsx[tsx<0] = 0
    #if (length(tsx) > samples){tsx = tsx[1:samples]}
    
    #tsx = tsx - origin[1]
    #tsx = pixToDVA(tsx, axis = 'x')
    tsy = as.vector(t(yData[t,])) # y-coord of current pos of right eye (only right) during the search array portion of trial 1
    tsy[tsy == origin[2]] = NA
    #preprocessing
    #tsy[is.na(tsy)] <- origin[2]
    #tsy[tsy>screenRes[2]] = screenRes[2]
    #tsy[tsy<0] = 0
    #if (length(tsy) > samples){tsy = tsy[1:samples]}
    
    #tsy = tsy - origin[2]
    #tsy = -1*tsy #inverse y-axis
    #tsy = pixToDVA(tsy, axis = 'y')
    distances = matrix(nrow=length(tsx), ncol=6)
    colnames(distances) = rownames(targetLocations_inPixels)
    #calculate distance from each possible target loc on each sample, return smallest
    for (d in 1:nrow(targetLocations_inPixels)){
      distances[,d] = sqrt( (targetLocations_inPixels[d,2]-tsx)^2 + (targetLocations_inPixels[d,3]-tsy)^2)
    }
    avDist = colMeans(distances, na.rm = TRUE)
    averageDistances[index,] = avDist
    guess = as.numeric(names(which.min(avDist))) #finds the name of the column of "distances" containing the minimum average value; returns it as an integer
  }
  actualGuesses[index] = guess
  correctGuess[index] = (guess==labels$targetLocation[t])
  index = index +1
  print(t)
}

prepForSubjLevel = data.frame(acc = correctGuess, ID = rep(1:72, each = 480))
summary = aggregate(prepForSubjLevel, list(ID = prepForSubjLevel$ID), mean)

errorsSubj = data.frame()
errorsSubj[1:2, 1] = quantile(replicate(10000,mean(sample(summary$acc,length(summary$acc), replace =TRUE), na.rm = TRUE)),c(.975,.025))

save(prepForSubjLevel, summary, errorsSubj, actualGuesses, file = "CDVMBG_BRM_distanceMinimization.RData")

