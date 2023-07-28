# rm(list = ls())

# This script:
# 1)  Imports all CONUS/study area rasters
# 2)  Calculate CoNUS medians
# 3)  Calculates the min/max ranges across all study areas 
#     This step is currently very messy; I tried to set it up in a clean loop but it wasn't working - see script where I attempted to do this here: S:\Projects\NPCA\Scripts_Analysis\Boxplots\_AttemptingCleanRangeCalculations.R
# 4)  Created boxplots for each study area for each of the 4 rasters, setting the dotted line as the CONUS median and the min/max ranges to be consisent across all plots.

# Written by Ellie Linden in January 2023.

library(raster)
library(tidyverse)

######################
### Set Workspaces ###
######################
CONUS.inWS <- "S:/Projects/NPCA/Workspace/Hannah_Hyatt/NationalAnalysis/BoxPlots_AK/2_FloatingPoint/"
FocalArea.inWS <- "S:/Projects/NPCA/Workspace/Hannah_Hyatt/NationalAnalysis/BoxPlots_AK/3_Rasters_extracted_by_FocalAreas/"
outWS <- "S:/Projects/NPCA/Workspace/Hannah_Hyatt/NationalAnalysis/BoxPlots_AK/Boxplots_20230609/"

############################
### Import/Clean Rasters ###
############################

# ------------- #
# --- CONUS --- #
# ------------- #

### Import Rasters ###
CONUS.rasters <-list.files(path=CONUS.inWS, pattern="*.tif$")
CONUS.raster.list <- vector(mode = "list")

### Loop through TIF files and import as rasters
for (CONUS.raster in CONUS.rasters){
  raster.name <- str_split_fixed(CONUS.raster, pattern = "_", n=2)[1]
  print(raster.name)
  raster.file <- str_c(CONUS.inWS, "/",  CONUS.raster)
  raster.object <- raster(raster.file)
  CONUS.raster.list[[CONUS.raster]] <- raster.object

}

# Note that the CONUS richness NAs aren't showing up as 120 value anymore, so don't need to do that conversion ###
# The richness max value is stated here as 31 rather than 32; however, when calculating the max value across all focal area rasters below it did come to 32 (although this step is for CONUS, so not comparable). Not sure how much to be concerned about this.

### Check Alaska rasters ###
 plot(CONUS.raster.list$RSR_float.tif$RSR_float)
 summary(CONUS.raster.list$RSR_float.tif$RSR_float)
 
 plot(CONUS.raster.list$ConnectivityClimateFlow_float.tif$ConnectivityClimateFlow_float)
 summary(CONUS.raster.list$ConnectivityClimateFlow_float.tif$ConnectivityClimateFlow_float)
 
 plot(CONUS.raster.list$ConservationValues_float.tif$ConservationValues_float)
 summary(CONUS.raster.list$ConservationValues_float.tif$ConservationValues_float)
 
 plot(CONUS.raster.list$Resilience_float.tif$Resilience_float)
 summary(CONUS.raster.list$Resilience_float.tif$Resilience_float)

# ------------------- #
# --- Focal Areas --- #
# ------------------- #

### Import Rasters ###
FocalArea.rasters <-list.files(path=FocalArea.inWS, pattern="*.tif$")
FocalArea.raster.list <- vector(mode = "list")

### Loop through TIF files and import as rasters
for (FocalArea.raster in FocalArea.rasters){
  print(FocalArea.raster)
  raster.file <- str_c(FocalArea.inWS, "/",  FocalArea.raster)
  raster.object <- raster(raster.file)
  FocalArea.raster.list[[FocalArea.raster]] <- raster.object
  
}

# Didn't check all of the rasters, but plotted a few of the richness ones to make sure there wasn't a large background value (instead of NA) and they looked fine.

################################
### Calculate Medians/Ranges ###
################################

# ---------------------- #
# --- CONUS Medians ---- #
# ---------------------- #
CONUS.RSR.median <- raster::boxplot(CONUS.raster.list$RSR_float.tif$RSR_float)$stats[3,]
CONUS.Resilience.median <- raster::boxplot(CONUS.raster.list$Resilience_float.tif$Resilience_float)$stats[3,]
CONUS.ConnectivityClimateFlow.median <- raster::boxplot(CONUS.raster.list$ConnectivityClimateFlow_float.tif$ConnectivityClimateFlow_float)$stats[3,]
CONUS.ConservationValues.median <- raster::boxplot(CONUS.raster.list$ConservationValues_float.tif$ConservationValues_float)$stats[3,]

# ----------------------- #
# --- Variable Ranges --- #
# ----------------------- #

# ### Updating just Georgia River System ###
# ## Min ##
# RSR.Min <- min(summary(FocalArea.raster.list$GeorgiaRiverSystem_RSR.tif$GeorgiaRiverSystem_RSR)[[1]])
# Resilience.Min <- min(summary(FocalArea.raster.list$GeorgiaRiverSystem_Resilience.tif$GeorgiaRiverSystem_Resilience)[[1]])
# ConnectivityClimateFlow.Min <- min(summary(FocalArea.raster.list$GeorgiaRiverSystem_ConnectivityClimateFlow.tif$GeorgiaRiverSystem_ConnectivityClimateFlow)[[1]])
# ConservationValues.Min <- min(summary(FocalArea.raster.list$GeorgiaRiverSystem_ConservationValues.tif$GeorgiaRiverSystem_ConservationValues)[[1]])
# ## Max ##
# RSR.Max <- max(summary(FocalArea.raster.list$GeorgiaRiverSystem_RSR.tif$GeorgiaRiverSystem_RSR)[[5]])
# Resilience.Max <- max(summary(FocalArea.raster.list$GeorgiaRiverSystem_Resilience.tif$GeorgiaRiverSystem_Resilience)[[5]])
# ConnectivityClimateFlow.Max <- max(summary(FocalArea.raster.list$GeorgiaRiverSystem_ConnectivityClimateFlow.tif$GeorgiaRiverSystem_ConnectivityClimateFlow)[[5]])
# ConservationValues.Max <- max(summary(FocalArea.raster.list$GeorgiaRiverSystem_ConservationValues.tif$GeorgiaRiverSystem_ConservationValues)[[5]])

### Min ###
RSR.Min <- min(summary(FocalArea.raster.list$ArcticLandscape_RSR.tif$ArcticLandscape_RSR)[[1]],
                    summary(FocalArea.raster.list$BearCoast_RSR.tif$BearCoast_RSR)[[1]])
                    
Resilience.Min <- min(summary(FocalArea.raster.list$ArcticLandscape_Resilience.tif$ArcticLandscape_Resilience)[[1]],
                      summary(FocalArea.raster.list$BearCoast_Resilience.tif$BearCoast_Resilience)[[1]])

ConnectivityClimateFlow.Min <- min(summary(FocalArea.raster.list$ArcticLandscape_ConnectivityClimateFlow.tif$ArcticLandscape_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$BearCoast_ConnectivityClimateFlow.tif$BearCoast_ConnectivityClimateFlow)[[1]])
                                   
ConservationValues.Min <- min(summary(FocalArea.raster.list$ArcticLandscape_ConservationValues.tif$ArcticLandscape_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$BearCoast_ConservationValues.tif$BearCoast_ConservationValues)[[1]])
                      

### Max ###
RSR.Max <- max(summary(FocalArea.raster.list$ArcticLandscape_RSR.tif$ArcticLandscape_RSR)[[5]],
                    summary(FocalArea.raster.list$BearCoast_RSR.tif$BearCoast_RSR)[[5]])

Resilience.Max <- max(summary(FocalArea.raster.list$ArcticLandscape_Resilience.tif$ArcticLandscape_Resilience)[[5]],
                      summary(FocalArea.raster.list$BearCoast_Resilience.tif$BearCoast_Resilience)[[5]])

ConnectivityClimateFlow.Max <- max(summary(FocalArea.raster.list$ArcticLandscape_ConnectivityClimateFlow.tif$ArcticLandscape_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$BearCoast_ConnectivityClimateFlow.tif$BearCoast_ConnectivityClimateFlow)[[5]])
                                   
ConservationValues.Max <- max(summary(FocalArea.raster.list$ArcticLandscape_ConservationValues.tif$ArcticLandscape_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$BearCoast_ConservationValues.tif$BearCoast_ConservationValues)[[5]])
                              
# Check min/max objects created above
RSR.Min <- as.numeric(RSR.Min)
Resilience.Min <- as.numeric(Resilience.Min)
ConnectivityClimateFlow.Min <- as.numeric (ConnectivityClimateFlow.Min)

ConservationValues.Min <- as.numeric(ConservationValues.Min)
ConnectivityClimateFlow.Min <- Resilience.Min

RSR.Max
Resilience.Max
ConnectivityClimateFlow.Max
ConservationValues.Max
RSR.Min
Resilience.Min
ConnectivityClimateFlow.Min
ConservationValues.Min

#######################
### Create Boxplots ###
#######################
boxplot.list = list()

### Loop through Richness rasters to create boxplots
for (i in FocalArea.raster.list){
  layer.name <- i@data@names
  print(layer.name)
  raster.name <- str_c(layer.name, ".tif")
  boxplot.input.object <- str_c(raster.name, "$", layer.name)
  variable.name <- str_split_fixed(layer.name, pattern = "_", n=2)[2]

  # Set the min/max axis limits and CONUS median based on variables 
  if (variable.name == "RSR") {
    variable.min <- RSR.Min
    variable.max <- RSR.Max
    CONUS.median <- CONUS.RSR.median
  } else if (variable.name == "Resilience") {
    variable.min <- Resilience.Min
    variable.max <- Resilience.Max
    CONUS.median <- CONUS.Resilience.median
  } else if (variable.name == "ConnectivityClimateFlow") {
    variable.min <- ConnectivityClimateFlow.Min
    variable.max <- ConnectivityClimateFlow.Max
    CONUS.median <- CONUS.ConnectivityClimateFlow.median
  } else {
    variable.min <- ConservationValues.Min
    variable.max <- ConservationValues.Max
    CONUS.median <- CONUS.ConservationValues.median
  }
  
  # Set output file
  output.file <- str_c(outWS, layer.name, ".jpg")
  jpeg(output.file, width = 1000, height = 2000, units = "px", res = 300)
  
  # Create boxplot
  variable.min <- as.numeric(variable.min)
  boxplot <- raster::boxplot(i,
                             ylim=c(variable.min, variable.max))
  # # Create boxplot
  # boxplot <- raster::boxplot(i, main = i,
  #                            ylim=c(variable.min, variable.max))
  
  # Add CONUS medians
  abline(h=CONUS.median, col="blue", lwd=2, lty=2)
  dev.off()

}

print("Complete")