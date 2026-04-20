library(ggplot2)
library(ggforce)
rm(list=ls())
options(digits = 10) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!



mode = "BS"

#replace the empty quotes with the file path to the location where you downloaded the files from Zenodo below
path = ''

screenCM = c(59, (1439*(59))/2559) #from manuscript
if (mode == "BS"){
  viewingDist = 96
}else if (mode == "RR"){
  viewingDist = 60
}

resolution = 10 #toggle for KDE

subsetCorrects = 1

#----- Load in data and functions -----
setwd(paste(path, "/dataForDownload/environments", sep = ""))
source('CDVMBG_BRM_SpatialSHAPFunctions.R') #Separate script for KDE functions
load("CDVMBG_BRM_TargPredictionsAndEyeSorted.RData")
#----- Load in data -----
setwd(paste(path, "/dataForDownload/cnnResults/SHAP", sep = ""))
shapData = read.csv("shapValues_GrubbLiTargLoc_Decay.csv")
shapData$X = NULL

# CNN predicting target location from Grubb & Li (2018) data
setwd(paste(path, "/dataForDownload/cnnResults/accuracies/trial-level accuracies from best epoch", sep = ""))
trialLevelTarg = read.csv("trialLevelAccuracy_GrubbLiTargLoc_Decay.csv")
trialLevelTarg = trialLevelTarg[,2] #remove index column added by Excel
trialLevelTarg = as.data.frame(as.logical(trialLevelTarg)) 

#shortcut to read in eye data
setwd(path)
load("CDVMBG_BRM_TargPredictionsAndEyeSorted.RData")

#pixel location of each potential target location - UPDATE FOR GRUBB & LI, use vector math to extract from polar angles -- THEN MAKE RELATIVE TO ORIGIN
objectLocations_inDVA = data.frame(objectLocation = c(0, 60, 120, 180, 240, 300),
                                   objectX = c(0, 4.33, 4.33, 0, -4.33, -4.33),
                                   objectY = c(5, 2.5, -2.5, -5, -2.5, 2.5))

pixLocations = matrix(nrow = nrow(objectLocations_inDVA), ncol = 2)
for(i in 1:nrow(objectLocations_inDVA)){pixLocations[i,] = DVAtoPix(objectLocations_inDVA$objectX[i], objectLocations_inDVA$objectY[i],screenCM, viewingDist)}

objSize = DVAtoPix(1.15,1.15,screenCM, viewingDist)

objectLocations_inPixels = data.frame(
  objectLocation = objectLocations_inDVA$objectLocation,
  objectX = pixLocations[,1] + origin[1],
  objectY = screenRes[2] - (pixLocations[,2] + origin[2]),
  objectSize=rep(objSize[1], times = 6)
)
rownames(objectLocations_inPixels) = objectLocations_inPixels$objectLocation


#----- Iterate through plotting correct CNN trials on same plane -----
if (subsetCorrects==TRUE){
condsDup = grubbLiConditions
#conditional = !is.na(grubbLiBeh$trialNum)
conditional = grubbLiPredictions==(condsDup$targetLocation/60) 


grubbLiConditions = grubbLiConditions[conditional,]
grubbLiX = grubbLiX[conditional,]
grubbLiY = grubbLiY[conditional,]
shapData = shapData[conditional,]
grubbLiBeh = grubbLiBeh[conditional,]
}

trialsToOverlay = 1:nrow(grubbLiConditions)
targLocationBasis = as.numeric(objectLocations_inPixels[1, 2:3])

rotatedDistancesFromTarg = matrix(nrow = nrow(grubbLiConditions), ncol = 600)

trialsOverlayed = ggplot()+
  coord_cartesian(xlim=c(origin[1]-300,origin[1]+300), ylim =c(origin[2]-300,origin[2]+300))+
  #coord_cartesian(xlim=c(0,screenRes[1]), ylim =c(0, screenRes[2]))+
  labs(x = "x-position (pixels)", y = "y-position (pixels)")+
  theme_classic()

tracesList = list()
maxSHAPPos = data.frame()

for(index in trialsToOverlay){
  #get corresponding subset
  DF4GRAPH = data.frame(idx = 1:length(grubbLiX[index,]),
                        xPos = as.vector(t(grubbLiX[index,])),
                        yPos = as.vector(t(grubbLiY[index,])),
                        shap = as.vector(t(shapData[index,])))
  #shapNorm = as.vector(t(normalizedShaps[index,])))
  targetX = objectLocations_inPixels$objectX[objectLocations_inPixels$objectLocation==grubbLiConditions$targetLocation[index]]
  targetY = objectLocations_inPixels$objectY[objectLocations_inPixels$objectLocation==grubbLiConditions$targetLocation[index]]
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

trialMaxPositions = ggplot()+
  geom_point(data = maxSHAPPos, aes(x = xPos, y = yPos), alpha = 0.2) +
  geom_circle(data = objectLocations_inPixels, aes(x0 = objectX,  y0 = screenRes[2] -objectY,r = objectSize), color = "blue", stroke = 2, alpha = 0.7)+
  geom_point(data = objectLocations_inPixels, aes(x = objectX[1], y = screenRes[2] -objectY[1]), 
             pch = 8, size = 10, color = "blue",  stroke = 2, alpha = 1) + 
  coord_cartesian(xlim=c(origin[1]-500,origin[1]+500), ylim =c(origin[2]-500,origin[2]+500))+
  labs(x = "x-position (pixels)", y = "y-position (pixels)")+
  theme_classic()
plot(trialMaxPositions)

grid_points = gaussianKDE(maxSHAPPos, resolution)

# 2. Plot the Observed Weighted KDE Surface
kde_plot <- ggplot() +
  # Use geom_raster to map the density values onto the grid
  geom_raster(data = grid_points, aes(x = X_grid, y = Y_grid, fill = (Density-min(Density)) / (max(Density)-min(Density)) )) +
  geom_circle(data = objectLocations_inPixels, aes(x0 = objectX,  y0 = screenRes[2]-objectY, r = objectSize), color = "white", alpha = 0.7)+
  
  geom_point(data = objectLocations_inPixels, aes(x = objectX[1], y = screenRes[2] -objectY[1]), 
             pch = 8, size = 4, color = "white") +
  # Optional: Overlay the original point locations for context
  # geom_point(data = df_points, aes(x = xPos, y = yPos), 
  #            color = "white", size = 0.5, alpha = 0.6) +
  
  # Set a continuous color scale (e.g., Viridis for perceptually uniform colors)
  scale_fill_viridis_c(name = "Weighted Density",option = 'plasma') + 
  
  # Apply a clean theme and labels
  labs(
    x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(legend.position = 'none')+ #legend.position = "bottom",legend.key.size = unit(2, 'cm'))+
  coord_cartesian(xlim=c(origin[1]-500,origin[1]+500), ylim =c(origin[2]-500,origin[2]+500)) # Ensure aspect ratio is preserved

print(kde_plot)

