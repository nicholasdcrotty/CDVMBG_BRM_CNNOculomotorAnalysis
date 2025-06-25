library(ggplot2)
rm(list=ls())
options(digits = 10) # by default, print results to ten decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ""



chance = rep((1/6), times = 72) #define vector of chance values for t-tests

#----- Load in data -----
setwd(paste(path, "/dataForDownload/oculomotorData", sep = ""))

xData = read.csv("CDVMBG_BRM_Massa_XPos.csv")
xData$X = NULL
yData = read.csv("CDVMBG_BRM_Massa_YPos.csv")
yData$X = NULL
labels = read.csv("CDVMBG_BRM_Massa_Conditions.csv")
labels$X = NULL

#----- Necessary information from experiment -----
#screen resolution and origin coordinates
screenRes = c(2559,1439)
origin = screenRes/2

#pixel location of each potential target location
targetLocations_inPixels = data.frame(targetLocation = c(0, 60, 120, 180, 240, 300),
                                        targetX = c(1559.5, 1419.5, 1139.5, 999.5, 1139.5, 1419.5), 
                                        targetY = c(719.5, 477.5, 477.5, 719.5, 961.5, 961.5))
rownames(targetLocations_inPixels) = targetLocations_inPixels$targetLocation

#----- Pre-allocate data structures before loop -----
actualGuesses = vector() #the location that was guessed
correctGuess = vector() #whether the guess was correct
averageDistances = matrix(nrow = nrow(xData), ncol = 6) #for storing the minimum distances
index = 1

randomGuess = TRUE #if no eye data is recorded, should we guess a random target location?

#----- Iterate through all trials and calculate minimum distance from a potential target location -----
for (t in 1:nrow(xData)){
  
  #load in x-position data from trial t
  tsx = as.vector(t(xData[t,]))
  #undo preprocessing of NAs when generating the dataset
  tsx[tsx == origin[1]] = NA
  
  #if no eye data is detected...
  if ( max(is.na(tsx)) == 1 & length(unique(is.na(tsx))) ==1 ){
    #... and we specified randomGuess as TRUE, randomly choose from six potential locations
    if (randomGuess == TRUE){
      guess =targetLocations_inPixels$targetLocation[sample(nrow(targetLocations_inPixels), size = 1)]
    #otherwise, return NA for guess with no eye data
    } else if (randomGuess ==FALSE){
      guess = NA
    }
    
  } else {
    #load in y-position data from trial t
    tsy = as.vector(t(yData[t,]))
    #undo preprocessing of NAs when generating the dataset
    tsy[tsy == origin[2]] = NA
    
    #predefine array to store sample-level distances for trial t
    distances = matrix(nrow=length(tsx), ncol=6)
    colnames(distances) = rownames(targetLocations_inPixels)
    
    #calculate distance from each possible target location on each sample
    for (d in 1:nrow(targetLocations_inPixels)){
      distances[,d] = sqrt( (targetLocations_inPixels[d,2]-tsx)^2 + (targetLocations_inPixels[d,3]-tsy)^2)
    }
    
    #get trial-level average distances and store them in 'averageDistances'
    avDist = colMeans(distances, na.rm = TRUE)
    averageDistances[index,] = avDist
    
    #save guess by finding the name of the "avDist" column containing the minimum average distance; return it as an integer
    guess = as.numeric(names(which.min(avDist))) 
  }
  #save guess made and whether guess was correct
  actualGuesses[index] = guess
  correctGuess[index] = (guess==labels$targetLocation[t])
  
  #iterate
  index = index +1
  print(t)
}


#----- Calculate summary statistics -----
#save trial-level identification accuracies with corresponding subject ID
prepForSubjLevel = data.frame(acc = correctGuess, ID = rep(1:72, each = 480))

#calculate subject-level accuracies
summary = aggregate(prepForSubjLevel, list(ID = prepForSubjLevel$ID), mean)

#generate subject-level error bars
errorsSubj = data.frame()
errorsSubj[1:2, 1] = quantile(replicate(10000,mean(sample(summary$acc,length(summary$acc), replace =TRUE), na.rm = TRUE)),c(.975,.025))

#----- Print summary statistics -----
print(c("Overall identification accuracy (%): ", mean(prepForSubjLevel$acc)*100))
print(c("Mean across subjects (%): ", mean(summary$acc)*100))
print(c("bootstrapped subject-level 95% CI (%): ", rev(as.vector(errorsSubj[,1]))*100))
print("t-test comparing subject-level accuracies to chance: ")
t.test(summary$acc*100, chance*100, paired = TRUE)
