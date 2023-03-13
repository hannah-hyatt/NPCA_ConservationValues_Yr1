# rm(list = ls())

# This script:
# 1)  Converts background value of 120 in MoBI raster to NA.
#     Note that in order for this step to run, the MoBI raster needs to be at 990m resolution.
# 2)  Calculates the quantile breaks for the 3 datasets (TNC Resilient Sites, TNC Connectivity & Climate Flow, and MoBI RSR).
#     The default settings were used, but see ?quantile to understand different options for how to calculate percentiles by setting type== and integer
# 3)  Converts quantile breaks to dataframes as exports as csv files.
#     Note that the 'as.data.frame' function couldn't be thrown into quantile calculation step, otherwise the resulting df doesn't match what's printed as the raw/printed quantile outputs (see Richness as example). 

# The output quantile breaks will be used in a python script to reclassify the rasters (the rasters are too big to be reclassified in R).

# Written by Ellie Linden in September 2022.

library(raster)
library(tidyverse)

#####################
### Set Variables ###
#####################

### Set Workspaces ###
inWS <- "S:/Projects/NPCA/Workspace/Hannah_Hyatt/NationalAnalysis/CONUS/1_DecileCalculationInputs/"
outWS <- "S:/Projects/NPCA/Workspace/Hannah_Hyatt/NationalAnalysis/CONUS/2_Percentiles/"

### Import Rasters ###
ResilientSites <- raster::raster(str_c(inWS, "ResilientSites_null.tif"))
ConnectivityClimateFlow <- raster::raster(str_c(inWS, "ConnectivityClimateFlow_30m.tif"))
# RSR <- raster::raster(str_c(inWS, "RSR_30m.tif")) # large value conversion wouldn't work with 30m raster
RSR.990m <- raster::raster("S:/Data/NatureServe/Species_Distributions/MoBI_HabitatModels/April2021/RSR_All.tif")

### Define Thresholds ###
# thresholds<-c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9) # original decile breaks
thresholds<-c(0.2, 0.4, 0.6, 0.8)

##########################
### Check/Prep Rasters ###
##########################

### Checking Rasters ###
 plot(ResilientSites) # got error when tried to do this (possibly because of the raster size)
 plot(ConnectivityClimateFlow)
 plot(RSR.990m)

### Convert 120 value to NA in RSR Raster ###
 summary(RSR.990m$RSR_All)
 RSR.990m[RSR.990m==128] <- NA
 summary(RSR.990m$RSR_All)
 plot(RSR.990m)

###################################
### Calculate Percentile Breaks ###
###################################
 ResilientSites.percentiles <-raster::quantile(ResilientSites, probs=thresholds, ncells=1000000)
 print("Resilient Site percentiles calculated")

 ConnectivityClimateFlow.percentiles <-raster::quantile(ConnectivityClimateFlow, probs=thresholds, ncells=1000000)
 print("Connectivity & Climate Flow percentiles calculated")
 
 RSR.percentiles <-raster::quantile(RSR.990m, probs=thresholds, ncells=1000000)
 print("RSR percentiles calculated")

####################################
### Convert to Dataframes/Export ###
####################################

### Resilient Sites ###
 ResilientSites.percentiles.df <- as.data.frame(ResilientSites.percentiles)
 write.csv(ResilientSites.percentiles.df, str_c(outWS, "ResilientSites_percentiles.csv"))
 
 ### Connectivity & Climate Flow ###
 ConnectivityClimateFlow.percentiles.df <- as.data.frame(ConnectivityClimateFlow.percentiles)
 write.csv(ConnectivityClimateFlow.percentiles.df, str_c(outWS, "ConnectivityClimateFlow_percentiles.csv"))
 
 ### RSR ###
 RSR.percentiles.df <- as.data.frame(RSR.percentiles)
 write.csv(RSR.percentiles.df, str_c(outWS, "RSR_percentiles.csv"))

print("Script complete")
