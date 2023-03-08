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
CONUS.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/DensityPlotPrep/2_FloatingPoint/"
FocalArea.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/DensityPlotPrep/3_Rasters_extracted_by_FocalAreas/"
outWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/Boxplots/Boxplots_20230123/"

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

### Check CONUS rasters ###
# plot(CONUS.raster.list$Richness_float.tif$Richness_float)
# summary(CONUS.raster.list$Richness_float.tif$Richness_float)
# 
# plot(CONUS.raster.list$ConnectivityClimateFlow_float.tif$ConnectivityClimateFlow_float)
# summary(CONUS.raster.list$ConnectivityClimateFlow_float.tif$ConnectivityClimateFlow_float)
# 
# plot(CONUS.raster.list$ConservationValues_float.tif$ConservationValues_float)
# summary(CONUS.raster.list$ConservationValues_float.tif$ConservationValues_float)
# 
# plot(CONUS.raster.list$Resilience_float.tif$Resilience_float)
# summary(CONUS.raster.list$Resilience_float.tif$Resilience_float)

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
CONUS.Richness.median <- raster::boxplot(CONUS.raster.list$Richness_float.tif$Richness_float)$stats[3,]
CONUS.Resilience.median <- raster::boxplot(CONUS.raster.list$Resilience_float.tif$Resilience_float)$stats[3,]
CONUS.ConnectivityClimateFlow.median <- raster::boxplot(CONUS.raster.list$ConnectivityClimateFlow_float.tif$ConnectivityClimateFlow_float)$stats[3,]
CONUS.ConservationValues.median <- raster::boxplot(CONUS.raster.list$ConservationValues_float.tif$ConservationValues_float)$stats[3,]

# ----------------------- #
# --- Variable Ranges --- #
# ----------------------- #

### Min ###
Richness.Min <- min(summary(FocalArea.raster.list$AlabamaRiver_Richness.tif$AlabamaRiver_Richness)[[1]],
                    summary(FocalArea.raster.list$AviKwaAme_Richness.tif$AviKwaAme_Richness)[[1]],
                    summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[1]],
                    summary(FocalArea.raster.list$Calumet_Richness.tif$Calumet_Richness)[[1]],
                    summary(FocalArea.raster.list$CrownOfTheContinent_Richness.tif$CrownOfTheContinent_Richness)[[1]],
                    summary(FocalArea.raster.list$DelawareRiverBasin_Richness.tif$DelawareRiverBasin_Richness)[[1]],
                    summary(FocalArea.raster.list$Dinosaur_Richness.tif$Dinosaur_Richness)[[1]],
                    summary(FocalArea.raster.list$GeorgiaRiverSystem_Richness.tif$GeorgiaRiverSystem_Richness)[[1]],
                    summary(FocalArea.raster.list$GrandCanyonLandscape_Richness.tif$GrandCanyonLandscape_Richness)[[1]],
                    summary(FocalArea.raster.list$GreaterEverglades_Richness.tif$GreaterEverglades_Richness)[[1]],
                    summary(FocalArea.raster.list$GreaterYellowstone_Richness.tif$GreaterYellowstone_Richness)[[1]],
                    summary(FocalArea.raster.list$Maines100MileWilderness_Richness.tif$Maines100MileWilderness_Richness)[[1]],
                    summary(FocalArea.raster.list$NorthCascades_Richness.tif$NorthCascades_Richness)[[1]],
                    summary(FocalArea.raster.list$RimOfTheValley_Richness.tif$RimOfTheValley_Richness)[[1]],
                    summary(FocalArea.raster.list$SouthernAppalachian_Richness.tif$SouthernAppalachian_Richness)[[1]],
                    summary(FocalArea.raster.list$TheLandsBetween_Richness.tif$TheLandsBetween_Richness)[[1]])

Resilience.Min <- min(summary(FocalArea.raster.list$AlabamaRiver_Resilience.tif$AlabamaRiver_Resilience)[[1]],
                      summary(FocalArea.raster.list$AviKwaAme_Resilience.tif$AviKwaAme_Resilience)[[1]],
                      summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[1]],
                      summary(FocalArea.raster.list$Calumet_Resilience.tif$Calumet_Resilience)[[1]],
                      summary(FocalArea.raster.list$CrownOfTheContinent_Resilience.tif$CrownOfTheContinent_Resilience)[[1]],
                      summary(FocalArea.raster.list$DelawareRiverBasin_Resilience.tif$DelawareRiverBasin_Resilience)[[1]],
                      summary(FocalArea.raster.list$Dinosaur_Resilience.tif$Dinosaur_Resilience)[[1]],
                      summary(FocalArea.raster.list$GeorgiaRiverSystem_Resilience.tif$GeorgiaRiverSystem_Resilience)[[1]],
                      summary(FocalArea.raster.list$GrandCanyonLandscape_Resilience.tif$GrandCanyonLandscape_Resilience)[[1]],
                      summary(FocalArea.raster.list$GreaterEverglades_Resilience.tif$GreaterEverglades_Resilience)[[1]],
                      summary(FocalArea.raster.list$GreaterYellowstone_Resilience.tif$GreaterYellowstone_Resilience)[[1]],
                      summary(FocalArea.raster.list$Maines100MileWilderness_Resilience.tif$Maines100MileWilderness_Resilience)[[1]],
                      summary(FocalArea.raster.list$NorthCascades_Resilience.tif$NorthCascades_Resilience)[[1]],
                      summary(FocalArea.raster.list$RimOfTheValley_Resilience.tif$RimOfTheValley_Resilience)[[1]],
                      summary(FocalArea.raster.list$SouthernAppalachian_Resilience.tif$SouthernAppalachian_Resilience)[[1]],
                      summary(FocalArea.raster.list$TheLandsBetween_Resilience.tif$TheLandsBetween_Resilience)[[1]])


ConnectivityClimateFlow.Min <- min(summary(FocalArea.raster.list$AlabamaRiver_ConnectivityClimateFlow.tif$AlabamaRiver_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$AviKwaAme_ConnectivityClimateFlow.tif$AviKwaAme_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[1]],
                                   summary(FocalArea.raster.list$Calumet_ConnectivityClimateFlow.tif$Calumet_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$CrownOfTheContinent_ConnectivityClimateFlow.tif$CrownOfTheContinent_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$DelawareRiverBasin_ConnectivityClimateFlow.tif$DelawareRiverBasin_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$Dinosaur_ConnectivityClimateFlow.tif$Dinosaur_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$GeorgiaRiverSystem_ConnectivityClimateFlow.tif$GeorgiaRiverSystem_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$GrandCanyonLandscape_ConnectivityClimateFlow.tif$GrandCanyonLandscape_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$GreaterEverglades_ConnectivityClimateFlow.tif$GreaterEverglades_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$GreaterYellowstone_ConnectivityClimateFlow.tif$GreaterYellowstone_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$Maines100MileWilderness_ConnectivityClimateFlow.tif$Maines100MileWilderness_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$NorthCascades_ConnectivityClimateFlow.tif$NorthCascades_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$RimOfTheValley_ConnectivityClimateFlow.tif$RimOfTheValley_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$SouthernAppalachian_ConnectivityClimateFlow.tif$SouthernAppalachian_ConnectivityClimateFlow)[[1]],
                                   summary(FocalArea.raster.list$TheLandsBetween_ConnectivityClimateFlow.tif$TheLandsBetween_ConnectivityClimateFlow)[[1]])

ConservationValues.Min <- min(summary(FocalArea.raster.list$AlabamaRiver_ConservationValues.tif$AlabamaRiver_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$AviKwaAme_ConservationValues.tif$AviKwaAme_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[1]],
                              summary(FocalArea.raster.list$Calumet_ConservationValues.tif$Calumet_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$CrownOfTheContinent_ConservationValues.tif$CrownOfTheContinent_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$DelawareRiverBasin_ConservationValues.tif$DelawareRiverBasin_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$Dinosaur_ConservationValues.tif$Dinosaur_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$GeorgiaRiverSystem_ConservationValues.tif$GeorgiaRiverSystem_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$GrandCanyonLandscape_ConservationValues.tif$GrandCanyonLandscape_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$GreaterEverglades_ConservationValues.tif$GreaterEverglades_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$GreaterYellowstone_ConservationValues.tif$GreaterYellowstone_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$Maines100MileWilderness_ConservationValues.tif$Maines100MileWilderness_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$NorthCascades_ConservationValues.tif$NorthCascades_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$RimOfTheValley_ConservationValues.tif$RimOfTheValley_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$SouthernAppalachian_ConservationValues.tif$SouthernAppalachian_ConservationValues)[[1]],
                              summary(FocalArea.raster.list$TheLandsBetween_ConservationValues.tif$TheLandsBetween_ConservationValues)[[1]])


### Max ###
Richness.Max <- max(summary(FocalArea.raster.list$AlabamaRiver_Richness.tif$AlabamaRiver_Richness)[[5]],
                    summary(FocalArea.raster.list$AviKwaAme_Richness.tif$AviKwaAme_Richness)[[5]],
                    summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[5]],
                    summary(FocalArea.raster.list$Calumet_Richness.tif$Calumet_Richness)[[5]],
                    summary(FocalArea.raster.list$CrownOfTheContinent_Richness.tif$CrownOfTheContinent_Richness)[[5]],
                    summary(FocalArea.raster.list$DelawareRiverBasin_Richness.tif$DelawareRiverBasin_Richness)[[5]],
                    summary(FocalArea.raster.list$Dinosaur_Richness.tif$Dinosaur_Richness)[[5]],
                    summary(FocalArea.raster.list$GeorgiaRiverSystem_Richness.tif$GeorgiaRiverSystem_Richness)[[5]],
                    summary(FocalArea.raster.list$GrandCanyonLandscape_Richness.tif$GrandCanyonLandscape_Richness)[[5]],
                    summary(FocalArea.raster.list$GreaterEverglades_Richness.tif$GreaterEverglades_Richness)[[5]],
                    summary(FocalArea.raster.list$GreaterYellowstone_Richness.tif$GreaterYellowstone_Richness)[[5]],
                    summary(FocalArea.raster.list$Maines100MileWilderness_Richness.tif$Maines100MileWilderness_Richness)[[5]],
                    summary(FocalArea.raster.list$NorthCascades_Richness.tif$NorthCascades_Richness)[[5]],
                    summary(FocalArea.raster.list$RimOfTheValley_Richness.tif$RimOfTheValley_Richness)[[5]],
                    summary(FocalArea.raster.list$SouthernAppalachian_Richness.tif$SouthernAppalachian_Richness)[[5]],
                    summary(FocalArea.raster.list$TheLandsBetween_Richness.tif$TheLandsBetween_Richness)[[5]])

Resilience.Max <- max(summary(FocalArea.raster.list$AlabamaRiver_Resilience.tif$AlabamaRiver_Resilience)[[5]],
                      summary(FocalArea.raster.list$AviKwaAme_Resilience.tif$AviKwaAme_Resilience)[[5]],
                      summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[5]],
                      summary(FocalArea.raster.list$Calumet_Resilience.tif$Calumet_Resilience)[[5]],
                      summary(FocalArea.raster.list$CrownOfTheContinent_Resilience.tif$CrownOfTheContinent_Resilience)[[5]],
                      summary(FocalArea.raster.list$DelawareRiverBasin_Resilience.tif$DelawareRiverBasin_Resilience)[[5]],
                      summary(FocalArea.raster.list$Dinosaur_Resilience.tif$Dinosaur_Resilience)[[5]],
                      summary(FocalArea.raster.list$GeorgiaRiverSystem_Resilience.tif$GeorgiaRiverSystem_Resilience)[[5]],
                      summary(FocalArea.raster.list$GrandCanyonLandscape_Resilience.tif$GrandCanyonLandscape_Resilience)[[5]],
                      summary(FocalArea.raster.list$GreaterEverglades_Resilience.tif$GreaterEverglades_Resilience)[[5]],
                      summary(FocalArea.raster.list$GreaterYellowstone_Resilience.tif$GreaterYellowstone_Resilience)[[5]],
                      summary(FocalArea.raster.list$Maines100MileWilderness_Resilience.tif$Maines100MileWilderness_Resilience)[[5]],
                      summary(FocalArea.raster.list$NorthCascades_Resilience.tif$NorthCascades_Resilience)[[5]],
                      summary(FocalArea.raster.list$RimOfTheValley_Resilience.tif$RimOfTheValley_Resilience)[[5]],
                      summary(FocalArea.raster.list$SouthernAppalachian_Resilience.tif$SouthernAppalachian_Resilience)[[5]],
                      summary(FocalArea.raster.list$TheLandsBetween_Resilience.tif$TheLandsBetween_Resilience)[[5]])


ConnectivityClimateFlow.Max <- max(summary(FocalArea.raster.list$AlabamaRiver_ConnectivityClimateFlow.tif$AlabamaRiver_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$AviKwaAme_ConnectivityClimateFlow.tif$AviKwaAme_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[5]],
                                   summary(FocalArea.raster.list$Calumet_ConnectivityClimateFlow.tif$Calumet_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$CrownOfTheContinent_ConnectivityClimateFlow.tif$CrownOfTheContinent_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$DelawareRiverBasin_ConnectivityClimateFlow.tif$DelawareRiverBasin_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$Dinosaur_ConnectivityClimateFlow.tif$Dinosaur_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$GeorgiaRiverSystem_ConnectivityClimateFlow.tif$GeorgiaRiverSystem_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$GrandCanyonLandscape_ConnectivityClimateFlow.tif$GrandCanyonLandscape_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$GreaterEverglades_ConnectivityClimateFlow.tif$GreaterEverglades_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$GreaterYellowstone_ConnectivityClimateFlow.tif$GreaterYellowstone_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$Maines100MileWilderness_ConnectivityClimateFlow.tif$Maines100MileWilderness_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$NorthCascades_ConnectivityClimateFlow.tif$NorthCascades_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$RimOfTheValley_ConnectivityClimateFlow.tif$RimOfTheValley_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$SouthernAppalachian_ConnectivityClimateFlow.tif$SouthernAppalachian_ConnectivityClimateFlow)[[5]],
                                   summary(FocalArea.raster.list$TheLandsBetween_ConnectivityClimateFlow.tif$TheLandsBetween_ConnectivityClimateFlow)[[5]])

ConservationValues.Max <- max(summary(FocalArea.raster.list$AlabamaRiver_ConservationValues.tif$AlabamaRiver_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$AviKwaAme_ConservationValues.tif$AviKwaAme_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$BigThicket_Richness.tif$BigThicket_Richness)[[5]],
                              summary(FocalArea.raster.list$Calumet_ConservationValues.tif$Calumet_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$CrownOfTheContinent_ConservationValues.tif$CrownOfTheContinent_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$DelawareRiverBasin_ConservationValues.tif$DelawareRiverBasin_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$Dinosaur_ConservationValues.tif$Dinosaur_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$GeorgiaRiverSystem_ConservationValues.tif$GeorgiaRiverSystem_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$GrandCanyonLandscape_ConservationValues.tif$GrandCanyonLandscape_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$GreaterEverglades_ConservationValues.tif$GreaterEverglades_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$GreaterYellowstone_ConservationValues.tif$GreaterYellowstone_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$Maines100MileWilderness_ConservationValues.tif$Maines100MileWilderness_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$NorthCascades_ConservationValues.tif$NorthCascades_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$RimOfTheValley_ConservationValues.tif$RimOfTheValley_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$SouthernAppalachian_ConservationValues.tif$SouthernAppalachian_ConservationValues)[[5]],
                              summary(FocalArea.raster.list$TheLandsBetween_ConservationValues.tif$TheLandsBetween_ConservationValues)[[5]])

# Check min/max objects created above
Richness.Min
Resilience.Min
ConnectivityClimateFlow.Min
ConservationValues.Min
Richness.Max
Resilience.Max
ConnectivityClimateFlow.Max
ConservationValues.Max

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
  
  # Set the min/max axis limts and CONUS median based on variables 
  if (variable.name == "Richness") {
    variable.min <- Richness.Min
    variable.max <- Richness.Max
    CONUS.median <- CONUS.Richness.median
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
  boxplot <- raster::boxplot(i,
                             ylim=c(variable.min, variable.max))
  # Add CONUS medians
  abline(h=CONUS.median, col="blue", lwd=2, lty=2)
  dev.off()

}

print("Complete")