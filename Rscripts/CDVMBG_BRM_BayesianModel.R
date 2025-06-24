library(ggplot2)
library(reticulate)
library("rstan")
library(rethinking)
rm(list=ls())
options(digits = 4) # by default, print results to four decimal digits
set.seed(1823) #for replication - the year Trinity College was founded!

#replace the empty quotes with the file path to the location where you downloaded the files from Dropbox below
path = ""

#----- Load in environment from frequentist analysis -----
setwd(path)
load("CDVMBG_BRM_FrequentistResults_Environment.RData")

#----- function for heirarchical Bayesian model -----
modelBayes = function(subjects, subjLevel, nTrials){
  modelData = data.frame(Ci = subjLevel*nTrials, N = rep(nTrials, times = length(subjects)), ID = subjects)
  fit = ulam(
    alist(
      Ci ~ dbinom(N, probab),
      probab <- p[ID],
      p[ID] ~ dbeta( shape1=a, shape2 = b),
      a ~ dexp(.1),
      b ~ dexp(.05)
    ), data=modelData, chains = 4, iter = 1000, cores = 4
  )
  return(list(fit,precis(fit, depth = 2)))
}

#----- Generate objects to store model results -----

#lists to hold results and summary stats (mode, HPDI)
allResults = list()
reportedStats = list()

#data used for modeling
modelDFs = list(
  # subject level DFs used in modeling
  subjLevelAll=subjLevelAll, 
  subjLevelTargLoc=subjLevelTargLoc,  subjLevelDistLoc=subjLevelDistLoc, subjLevelValueLoc = subjLevelValueLoc, 
  subjLevelTransferDist = subjLevelTransferDist,
  
  #trial level DFs used for calculating nTrials
  trialLevelAll=trialLevelAll,
  trialLevelTargLoc=trialLevelTargLoc,  trialLevelDistLoc=trialLevelDistLoc, trialLevelValueLoc = trialLevelValueLoc,
  trialLevelTransferDist = trialLevelTransferDist
)

#empirically observed CNN accuracies
empirAcc = data.frame(all=means$all,
                      targLoc = means_GL$targLoc, distLoc = means_GL$distLoc, valueDist = means$valueDist,
                      transferDist = means_Doyle$transfer)

#graph lists
graphs = list(graph1=NA, graph2=NA,graph3=NA,graph4=NA,graph5=NA)
graphNames = list("massa target loc - Figure 3B", "grubb li target loc - Figure 3D",  
                  "grubb li distractor loc - Figure 4D", "massa distractor loc - Figure 4B", 
                  "transfer learning distractor loc - Figure 5B")

#subject IDs for graphing
subjMassa = sort(unique(trialLevelAll$subjID))
subjGL = sort(unique(trialLevelTargLoc$subjID))
subjDoyle = sort(unique(trialLevelTransferDist$subjID))

#----- Apply model + create graph for each set of CNN accuracies -----

for (df in 1:5){ #only first 5 values of list used, since back half just for nTrials calculation
  #which IDs to use
  if (df == 1 | df ==4){IDs = subjMassa}else if(df==5){IDs = subjDoyle}else{IDs=subjGL}
  
  #how tall to make the y-axis
  if(df == 3 | df ==4){ height = 60} else if(df==5){height =120} else {height = 20}
  
  #where to truncate the x-axis
  if(df >=3){ limit = 0.5} else {limit = 1}
  
  #fit model
  results = modelBayes(IDs, modelDFs[[df]], nrow(modelDFs[[df + 5]])/length(modelDFs[[df]]) )
  post = extract.samples(results[[1]])
  
  #graphing prep 
  probDF = data.frame(a = post$a, b = post$b)
  betaMeans = post$a / (post$a+ post$b)
  hpdi = data.frame(lower = HPDI(betaMeans, prob = 0.95)[1], upper = HPDI(betaMeans, prob = 0.95)[2])
  
  distMode = chainmode(betaMeans) #best for mode of density
  
  #save posterior 
  allResults[[df]] = results
  
  #save summary stats
  stats = list(mode = distMode, hpdi = hpdi)
  reportedStats[[df]] = stats
  
  
  #graph posterior distribution for mean of beta distribution 
  graphs[[df]] = ggplot()+
    geom_density(data = probDF, aes(x=a/(a+b)), fill = "lightgrey") + 
    geom_vline( xintercept = hpdi$upper, linetype = 2) + #UB of cred interval
    geom_vline( xintercept = hpdi$lower, linetype = 2) + #LB of cred interval
    geom_vline(xintercept = (1/6))+ #chance
    geom_vline(xintercept = empirAcc[[df]], linetype = 3) + #empirically correct values
    geom_hline(yintercept = 0) + #horizontal line on current ms figures
    labs(x = "mean computed with posterior distributions of a and b",
         y = "Density",
         title = as.name(paste("Bayesian - ", graphNames[[df]], sep =""))) +
    coord_cartesian(xlim=c(0,limit), ylim=c(0,height))+ #"height" defined in conditional at beginning of loop
    theme_classic()+
    theme(plot.title = element_text(hjust = 0.5)) #center title
  plot(graphs[[df]])
  print(c(graphNames[[df]], distMode, hpdi))
}

#----- Summary statistics -----
names(allResults) = graphNames
names(reportedStats) = graphNames
print(reportedStats)
