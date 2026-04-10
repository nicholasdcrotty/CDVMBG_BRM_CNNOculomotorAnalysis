library(ggplot2)
rm(list=ls())
options(digits = 4) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!
#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = "/Users/nicholascrotty/Desktop/Ongoing Trinity Projects/CDVMBG Reviews"


load("CDVMBG_BRM_TargPredictionsAndEyeSorted.RData")

massaLabels = massaConditions$targetLocation
grubbLiLabels = grubbLiConditions$targetLocation

#easy way to mimic the 'labels.map({0:0, 60:1, 120:2, 180:3, 240:4, 300:5})' from .ipynb scripts
massaLabels = massaLabels / 60
grubbLiLabels = grubbLiLabels / 60


#sanity check to make sure that train-test split was done correctly 
print(mean(massaPredictions == massaLabels)*100) #should be 67.28
print(mean(grubbLiPredictions == grubbLiLabels)*100) #should be 60.53 

#----- Confusion Matrix - Massa et al. (2024) -----
massaComp = data.frame(predictions = as.integer(massaPredictions), labels = as.integer(massaLabels))

massaConfusion = data.frame(predictions = rep(0:5, times = 6), 
                            labels = rep(0:5, each = 6),
                            frequency = rep(NA, times = 36))

uniqueLabels = sort(unique(massaComp$labels))
uniquePredictions = sort(unique(massaComp$predictions)) #identical to 'uniqueLabels', but makes for clearer code later on

for (l in 1:length(uniqueLabels)){
  for(p in 1:length(uniquePredictions)){
    confusionCount = (massaConfusion$labels==uniqueLabels[l] & massaConfusion$predictions == uniquePredictions[p])
    compCount = (massaComp$labels==uniqueLabels[l] & massaComp$predictions == uniquePredictions[p])
    massaConfusion$frequency[confusionCount] = length(massaComp$predictions[compCount])
    subsetX = massaX[compCount,]
    subsetY = massaY[compCount,]
    subsetBeh = massaBeh[compCount,]
   print(paste0(l, ", ", p))
  }
}

cmMassa = ggplot() + #1200 x 1200
  geom_tile(data = massaConfusion, aes(x = labels*60, y = predictions*60, fill = frequency), color = "white") +
  geom_text(data = massaConfusion, aes(x = labels*60, y = predictions*60+6, label = round(frequency, 3)), color = "black", size = 10, fontface = "bold") +
  labs(title = "Massa Confusion Matrix",
       x = "Observed Class (angles relative to horizontal meridian)",
       y = "Predicted Class (angles relative to horizontal meridian)",
       fill = "Count") +
  scale_x_continuous(breaks = seq(0, 300, by = 60), labels = c(0, 60, 120, 180, 240, 300)) +
  scale_y_continuous(breaks = seq(0, 300, by = 60), labels = c(0, 60, 120, 180, 240, 300)) +
  scale_fill_gradient(low = "white", high = "blue") +  
  theme_classic()
plot(cmMassa)


#----- Confusion Matrix - Grubb & Li (2018) -----
grubbLiComp = data.frame(predictions = as.integer(grubbLiPredictions), labels = as.integer(grubbLiLabels))



grubbLiConfusion = data.frame(predictions = rep(0:5, times = 6), 
                              labels = rep(0:5, each = 6),
                              frequency = rep(NA, times = 36))
                           

uniqueLabels = sort(unique(grubbLiComp$labels))
uniquePredictions = sort(unique(grubbLiComp$predictions)) #identical to 'uniqueLabels', but makes for clearer code later on

for (l in 1:length(uniqueLabels)){
  for(p in 1:length(uniquePredictions)){
    confusionCount = (grubbLiConfusion$labels==uniqueLabels[l] & grubbLiConfusion$predictions == uniquePredictions[p])
    compCount = (grubbLiComp$labels==uniqueLabels[l] & grubbLiComp$predictions == uniquePredictions[p])
    grubbLiConfusion$frequency[confusionCount] = length(grubbLiComp$predictions[compCount])
    subsetX = grubbLiX[compCount,]
    subsetY = grubbLiY[compCount,]
  print(paste0(l, ", ", p))
  }
}


#hard-coded matching of labels to Massa basis
grubbLiConfusion$predictions[grubbLiConfusion$predictions==0] = 90
grubbLiConfusion$predictions[grubbLiConfusion$predictions==1] = 30
grubbLiConfusion$predictions[grubbLiConfusion$predictions==2] = 330
grubbLiConfusion$predictions[grubbLiConfusion$predictions==3] = 270
grubbLiConfusion$predictions[grubbLiConfusion$predictions==4] = 210
grubbLiConfusion$predictions[grubbLiConfusion$predictions==5] = 150

grubbLiConfusion$labels[grubbLiConfusion$labels==0] = 90
grubbLiConfusion$labels[grubbLiConfusion$labels==1] = 30
grubbLiConfusion$labels[grubbLiConfusion$labels==2] = 330
grubbLiConfusion$labels[grubbLiConfusion$labels==3] = 270
grubbLiConfusion$labels[grubbLiConfusion$labels==4] = 210
grubbLiConfusion$labels[grubbLiConfusion$labels==5] = 150


cmGrubbLi = ggplot() + #1200 x 1200
  geom_tile(data = grubbLiConfusion, aes(x = labels, y = predictions, fill = frequency), color = "white") +
  geom_text(data = grubbLiConfusion, aes(x = labels, y = predictions+6, label = round(frequency, 3)), color = "black", size = 10, fontface = "bold") +
  scale_fill_gradient(low = "white", high = "blue") +
  labs(title = "Grubb Li Confusion Matrix",
       x = "Observed Class (angles relative to horizontal meridian)",
       y = "Predicted Class (angles relative to horizontal meridian)",
       fill = "Count") +
  scale_x_continuous(breaks = seq(30, 330, by = 60)) +
  scale_y_continuous(breaks = seq(30, 330, by = 60)) +
  theme_classic() 
plot(cmGrubbLi)

