library(ggplot2)
library(ggforce)
rm(list=ls())
options(digits = 10) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ''


screenCM = c(59, (1439*(59))/2559) #from manuscript
viewingDist = 70 #from manuscript

resolution = 10 #toggle for KDE
subsetCorrects = 1


#----- Load in data and functions -----
setwd(paste(path, "/dataForDownload/environments", sep = ""))
source('CDVMBG_BRM_SpatialSHAPFunctions.R') #Separate script for KDE functions -- COMPLETE THIS
load("CDVMBG_BRM_TargPredictionsAndEyeSorted.RData")
#----- Load in data -----
setwd(paste(path, "/dataForDownload/cnnResults/SHAP", sep = ""))
shapData = read.csv("shapValues_MassaTargLoc_Decay.csv")
shapData$X = NULL

# CNN predicting target location from Massa et al (2024) data
setwd(paste(path, "/dataForDownload/cnnResults/accuracies/trial-level accuracies from best epoch", sep = ""))
trialLevelTarg = read.csv("trialLevelAccuracy_MassaTargLoc_Decay.csv")
trialLevelTarg = trialLevelTarg[,2] #remove index column added by Excel
trialLevelTarg = as.data.frame(as.logical(trialLevelTarg)) 


objSize = DVAtoPix(1.15,1.15,screenCM, viewingDist)
#pixel location of each potential target location 
objectLocations_inPixels = data.frame(objectLocation = c(0, 60, 120, 180, 240, 300),
                                      objectX = c(1559.5, 1419.5, 1139.5, 999.5, 1139.5, 1419.5),
                                      objectY = c(719.5, 477.5, 477.5, 719.5, 961.5, 961.5),
                                      objectSize=rep(objSize[1], times = 6))


#----- Iterate through plotting correct CNN trials on same plane -----
if (subsetCorrects ==1){
condsDup = massaConditions
conditional = massaPredictions==(condsDup$targetLocation/60) 

massaX = massaX[conditional,]
massaY = massaY[conditional,]
shapData = shapData[conditional,]

massaConditions = massaConditions[conditional,]
massaBeh = massaBeh[conditional,]
}

trialsToOverlay = 1:nrow(massaConditions)
targLocationBasis = as.numeric(objectLocations_inPixels[1, 2:3])

rotatedDistancesFromTarg = matrix(nrow = nrow(massaConditions), ncol = 600)

trialsOverlayed = ggplot()+
  coord_cartesian(xlim=c(origin[1]-300,origin[1]+300), ylim =c(origin[2]-300,origin[2]+300))+
  labs(x = "x-position (pixels)", y = "y-position (pixels)")+
  theme_classic()

tracesList = list()
maxSHAPPos = data.frame()

for(index in trialsToOverlay){
  #get corresponding subset
  DF4GRAPH = data.frame(idx = 1:length(massaX[index,]),
                        xPos = as.vector(t(massaX[index,])),
                        yPos = as.vector(t(massaY[index,])),
                        shap = as.vector(t(shapData[index,])))
  targetX = objectLocations_inPixels$objectX[objectLocations_inPixels$objectLocation==massaConditions$targetLocation[index]]
  targetY = objectLocations_inPixels$objectY[objectLocations_inPixels$objectLocation==massaConditions$targetLocation[index]]
  targetVec = as.numeric(c(targetX, targetY))
  
  DF4GRAPH$shapNorm = (DF4GRAPH$shap-min(DF4GRAPH$shap)) / (max(DF4GRAPH$shap)-min(DF4GRAPH$shap))
  
  coordinateMatrix = matrix(c(DF4GRAPH$xPos,  DF4GRAPH$yPos),
                            nrow = 2, ncol = nrow(DF4GRAPH), byrow = TRUE)
  #transform data by rotating target to basis location on each trial
  rotation = rotatePlane(vec1 = targLocationBasis, vec2 = targetVec)
  
  rotatedCoords =  rotation%*%(coordinateMatrix-origin)#rotates vec2 to align with vec1
  DF4GRAPH$xPos_Rotated = rotatedCoords[1,]
  DF4GRAPH$yPos_Rotated = rotatedCoords[2,]
  for (sample in 1:ncol(rotatedCoords)){
    rotatedDistancesFromTarg[index, sample] = sqrt(sum((rotatedCoords[,sample]-targLocationBasis)^2))
  }
  
  #add coords of maximum SHAP value to dataframe
  maxSHAPVec = c(DF4GRAPH$xPos_Rotated[which.max(DF4GRAPH$shap)]+origin[1], 
                 screenRes[2] - (DF4GRAPH$yPos_Rotated[which.max(DF4GRAPH$shap)]+origin[2]), 
                 DF4GRAPH$shap[which.max(DF4GRAPH$shap)],
                 rotatedDistancesFromTarg[index, which.max(DF4GRAPH$shap)],
                 trialLevelTarg[index,1])
  maxSHAPPos = rbind(maxSHAPPos, maxSHAPVec)
  print(index)
  #BIG THING = rbind(BIG THING, little thing)
}

#----- Plot position of largest SHAP values -----
colnames(maxSHAPPos) = c("xPos", "yPos", "value", "distanceFromTarg", "cnnAcc")
truncation = 1
maxSHAPPos$truncatedValue = maxSHAPPos$value
maxSHAPPos$truncatedValue[maxSHAPPos$truncatedValue>truncation] = truncation
maxSHAPPos$accuracy = ifelse(maxSHAPPos$cnnAcc,"limegreen","firebrick1")

nonTargets = objectLocations_inPixels[2:6,]

trialMaxPositions = ggplot()+ #1200 x 1200
  geom_point(data = maxSHAPPos, aes(x = xPos, y = yPos), alpha = 0.2) +
  geom_circle(data = objectLocations_inPixels, aes(x0 = objectX,  y0 = screenRes[2]-objectY, r = objectSize), color = "blue", stroke = 2, alpha = 0.7)+
  geom_point(data = objectLocations_inPixels, aes(x = objectX[1], y = screenRes[2] -objectY[1]), 
             pch = 8, size = 10, color = "blue",  stroke = 2, alpha = 1) + 
  coord_cartesian(xlim=c(origin[1]-500,origin[1]+500), ylim =c(origin[2]-500,origin[2]+500))+
  labs(x = "x-position (pixels)", y = "y-position (pixels)")+
  theme_classic()
plot(trialMaxPositions)

#----- KDE ----- 
grid_points = gaussianKDE(maxSHAPPos, resolution)

kde_plot <- ggplot() +
  # Use geom_raster to map the density values onto the grid
  geom_raster(data = grid_points, aes(x = X_grid, y = Y_grid, fill = (Density-min(Density)) / (max(Density)-min(Density)))) +
  geom_circle(data = objectLocations_inPixels, aes(x0 = objectX,  y0 = screenRes[2]-objectY, r = objectSize), color = "white", alpha = 0.7)+
  
  geom_point(data = objectLocations_inPixels, aes(x = objectX[1], y = screenRes[2] -objectY[1]), 
             pch = 8, size = 4, color = "white") +
  # Optional: Overlay the original point locations for context
  # geom_point(data = df_points, aes(x = xPos, y = yPos),
  #            color = "white", shape =1, size = 3, alpha = 0.8) +
  
  # Set a continuous color scale (e.g., Viridis for perceptually uniform colors)
  scale_fill_viridis_c(name = "Weighted Density",option = 'plasma') + 
  
  # Apply a clean theme and labels
  labs(
    x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(legend.position = "none")+
  coord_cartesian(xlim=c(origin[1]-500,origin[1]+500), ylim =c(origin[2]-500,origin[2]+500)) # Ensure aspect ratio is preserved

print(kde_plot)

