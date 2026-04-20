library(ggplot2)
library(ggforce)
rm(list=ls())
options(digits = 10) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!


#replace the empty quotes with the file path to the location where you downloaded the files from Zenodo below
path = ''

screenCM = c(59, (1439*(59))/2559) #from manuscript
viewingDist = 70 #from manuscript

offset = 3 #toggle for polar plots
resolution = 10 #toggle for KDE



#----- Load in data and functions -----
setwd(paste(path, "/dataForDownload/environments", sep = ""))
source('CDVMBG_BRM_SpatialSHAPFunctions.R') #Separate script for KDE functions
load("CDVMBG_BRM_DistPredictionsAndEyeSorted.RData")

#----- Load in data -----
setwd(paste(path, "/dataForDownload/cnnResults/SHAP", sep = ""))
shapData = read.csv("shapValues_TransferLearning_MassaDistOnDoyleDist_Decay.csv")
shapData$X = NULL



# CNN trained on data from Massa et al. (2025) predicting distractor location from Doyle et al. (2025) data
setwd(paste(path, "/dataForDownload/cnnResults/accuracies/trial-level accuracies from best epoch", sep = ""))
trialLevelDist = read.csv("trialLevelAcc_TransferLearning_MassaDistOnDoyleDist_Decay.csv")
trialLevelDist = trialLevelDist[,2] #remove index column added by Excel
trialLevelDist = as.data.frame(as.logical(trialLevelDist)) 

#pixel location of each potential distractor location 
objSize = DVAtoPix(1.15,1.15,screenCM, viewingDist)

objectLocations_inPixels = data.frame(objectLocation = c(0, 60, 120, 180, 240, 300),
                                      objectX = c(1559.5, 1419.5, 1139.5, 999.5, 1139.5, 1419.5),
                                      objectY = c(719.5, 477.5, 477.5, 719.5, 961.5, 961.5),
                                      objectSize=rep(objSize[1], times = 6))

#----- Iterate through plotting correct CNN trials on same plane -----


condsDup = doyleConditions
conditional = doyleBeh$firstSacLocation.category!=doyleConditions$targetLocation & doylePredictions==(condsDup$distractorLocation/60) & !is.na(doyleBeh$firstSacLocation.category)

doyleX = doyleX[conditional,]
doyleY = doyleY[conditional,]
shapData = shapData[conditional,]

doyleConditions = doyleConditions[conditional,]
doyleBeh = doyleBeh[conditional,]

normalizedShaps = as.data.frame(t(apply(shapData, 1, function(x) (x-min(x)) / (max(x)-min(x)) ) ))

trialsToOverlay = 1:nrow(doyleConditions)
distLocationBasis = as.numeric(objectLocations_inPixels[1, 2:3])

rotatedDistancesFromDist = matrix(nrow = nrow(doyleConditions), ncol = 600)

trialsOverlayed = ggplot()+
  coord_cartesian(xlim=c(origin[1]-300,origin[1]+300), ylim =c(origin[2]-300,origin[2]+300))+

  labs(x = "x-position (pixels)", y = "y-position (pixels)")+
  theme_classic()

tracesList = list()
maxSHAPPos = data.frame()

rotAngles = array(dim =dim(shapData))

for(index in trialsToOverlay){
  #get corresponding subset
  DF4GRAPH = data.frame(idx = 1:length(doyleX[index,]),
                        xPos = as.vector(t(doyleX[index,])),
                        yPos = as.vector(t(doyleY[index,])),
                        shap = as.vector(t(shapData[index,])))
  distractorX = objectLocations_inPixels$objectX[objectLocations_inPixels$objectLocation==doyleConditions$distractorLocation[index]]
  distractorY = objectLocations_inPixels$objectY[objectLocations_inPixels$objectLocation==doyleConditions$distractorLocation[index]]
  distractorVec = as.numeric(c(distractorX, distractorY))
  
  DF4GRAPH$shapNorm = (DF4GRAPH$shap-min(DF4GRAPH$shap)) / (max(DF4GRAPH$shap)-min(DF4GRAPH$shap))
  
  coordinateMatrix = matrix(c(DF4GRAPH$xPos,  DF4GRAPH$yPos),
                            nrow = 2, ncol = nrow(DF4GRAPH), byrow = TRUE)
  #transform data by rotating distractor to basis location on each trial
  rotation = rotatePlane(vec1 = distLocationBasis, vec2 = distractorVec)
  
  rotAngles[index] = rotateAngle(vec1 = distLocationBasis, vec2 = distractorVec)
  rotatedCoords =  rotation%*%(coordinateMatrix-origin)#rotates vec2 to align with vec1
  DF4GRAPH$xPos_Rotated = rotatedCoords[1,]
  DF4GRAPH$yPos_Rotated = rotatedCoords[2,]
  for (sample in 1:ncol(rotatedCoords)){
    rotatedDistancesFromDist[index, sample] = sqrt(sum((rotatedCoords[,sample]-distLocationBasis)^2))
    coordVec  = rotatedCoords
    coordVec[1,] =  coordVec[1,] + origin[1]
    coordVec[2,] =  screenRes[2] - (coordVec[2,] + origin[2])
    
    rotAngles[index,sample] = rotateAngle(vec1 = distLocationBasis, vec2 = coordVec[,sample])
  }
  
  #add coords of maximum SHAP value to dataframe
  maxSHAP_X = DF4GRAPH$xPos_Rotated[which.max(DF4GRAPH$shap)]+origin[1]
  maxSHAP_Y = screenRes[2] - (DF4GRAPH$yPos_Rotated[which.max(DF4GRAPH$shap)]+origin[2])
  
  maxSHAPVec = c(which.max(DF4GRAPH$shap),
                 maxSHAP_X, 
                 maxSHAP_Y, 
                 DF4GRAPH$shap[which.max(DF4GRAPH$shap)],
                 rotatedDistancesFromDist[index, which.max(DF4GRAPH$shap)],
                 trialLevelDist[index,1],
                 rotateAngle(vec1 = distLocationBasis, vec2 = c(maxSHAP_X,maxSHAP_Y)))
  maxSHAPPos = rbind(maxSHAPPos, maxSHAPVec)
  #BIG THING = rbind(BIG THING, little thing)
  print(index)
}


#----- Plot position of largest SHAP values -----
colnames(maxSHAPPos) = c("idx", "xPos", "yPos", "value", "distanceFromTarg", "cnnAcc","angle")
truncation = 1
maxSHAPPos$truncatedValue = maxSHAPPos$value
maxSHAPPos$truncatedValue[maxSHAPPos$truncatedValue>truncation] = truncation
maxSHAPPos$accuracy = ifelse(maxSHAPPos$cnnAcc,"limegreen","firebrick1")
maxSHAPPos$angle = maxSHAPPos$angle
maxSHAPPos$angle = maxSHAPPos$angle *(180/pi)
maxSHAPPos$angle[maxSHAPPos$angle<0 & !is.na(maxSHAPPos$angle)] = 360 + maxSHAPPos$angle[maxSHAPPos$angle<0 & !is.na(maxSHAPPos$angle)]


nonTargets = objectLocations_inPixels[2:6,]

trialMaxPositions = ggplot()+
  geom_point(data = maxSHAPPos, aes(x = xPos, y = yPos), alpha = 0.2) +
  geom_circle(data = objectLocations_inPixels, aes(x0 = objectX,  y0 = screenRes[2] -objectY,r = objectSize), color = "blue", stroke = 2, alpha = 0.7)+
  geom_point(data = objectLocations_inPixels, aes(x = objectX[1], y = screenRes[2] -objectY[1]), 
             pch = 8, size = 10, color = "blue",  stroke = 2, alpha = 1) + 
  coord_cartesian(xlim=c(origin[1]-500,origin[1]+500), ylim =c(origin[2]-500,origin[2]+500))+
  labs(x = "x-position (pixels)", y = "y-position (pixels)")+
  theme_classic()
plot(trialMaxPositions)


#----- KDE -----
grid_points = gaussianKDE(maxSHAPPos, resolution)

# Plot the Observed Weighted KDE Surface
kde_plot <- ggplot() +
  # Use geom_raster to map the density values onto the grid
  geom_raster(data = grid_points, aes(x = X_grid, y = Y_grid, fill = (Density-min(Density)) / (max(Density)-min(Density)) )) +
  geom_circle(data = objectLocations_inPixels, aes(x0 = objectX,  y0 = screenRes[2]-objectY, r = objectSize), color = "white", alpha = 0.7)+
  
  geom_point(data = objectLocations_inPixels, aes(x = objectX[1], y = screenRes[2] -objectY[1]), 
             pch = 8, size = 4, color = "white") +
  
  # Set a continuous color scale (e.g., Viridis for perceptually uniform colors)
  scale_fill_viridis_c(name = "Weighted Density",option = 'plasma') + 
  
  # Apply a clean theme and labels
  labs(
    x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(legend.position = "none")+
  coord_cartesian(xlim=c(origin[1]-500,origin[1]+500), ylim =c(origin[2]-500,origin[2]+500)) # Ensure aspect ratio is preserved

print(kde_plot)

#----- Polar histogram of SHAP values w/ timing information -----

maxSHAPPos$bin = cut(maxSHAPPos$angle, breaks = 100)
maxSHAPPos$bin = as.numeric(gsub("\\((.+),.*", "\\1", as.character(maxSHAPPos$bin))) 

maxSHAPPosPlotDF = aggregate(maxSHAPPos$idx,list(bin = maxSHAPPos$bin), mean)

maxSHAPPosPlotDF$bin[maxSHAPPosPlotDF$bin<0] = 360 + maxSHAPPosPlotDF$bin[maxSHAPPosPlotDF$bin<0] #neg values when using lower bound in bin
maxSHAPPosPlotDF$bin = maxSHAPPosPlotDF$bin + 90
maxSHAPPosPlotDF$bin[maxSHAPPosPlotDF$bin>360] = maxSHAPPosPlotDF$bin[maxSHAPPosPlotDF$bin>360] - 360 #THINK ABOUT IF THIS IS CORRECT

maxSHAPPosPlotDF$count = as.vector(t(aggregate(maxSHAPPos$angle,list(bin = maxSHAPPos$bin), length)[2]))
names(maxSHAPPosPlotDF) = c("bin", "idx", "count")


polarMaxSHAPPlotAvg = ggplot()+
  geom_rect(data = maxSHAPPosPlotDF, aes(xmin=bin,xmax=bin+3.6,ymin=offset,ymax=count+offset, fill = idx)) +
  coord_polar(theta ='x')+
  theme_minimal() +
  scale_x_continuous(breaks = c(0,90,180,270))+
  theme(legend.position = "none")+
  theme(axis.text.y = element_blank(), axis.title = element_blank(),legend.key.size = unit(1.5, "cm"),)
plot(polarMaxSHAPPlotAvg)






