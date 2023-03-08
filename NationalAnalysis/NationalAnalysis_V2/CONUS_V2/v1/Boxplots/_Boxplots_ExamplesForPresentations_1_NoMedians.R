library(raster)
library(tidyverse)

##########################
### Greater Everglades ###
##########################

### Set Workspaces ###
GreaterEverglades.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/_ExampleFocalAreasForPresentation/GreaterEverglades/"
GreaterEverglades.outWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/NationalAnalysis_FocalAreaClips/GreaterEverglades/Boxplots/"

### Import Rasters ###
GreaterEverglades.Richness <- raster(str_c(GreaterEverglades.inWS, "Richness_clip_GreaterEverglades.tif"))
GreaterEverglades.ConnectivityClimateFlow <- raster(str_c(GreaterEverglades.inWS, "ConnectivityClimateFlow_clip_GreaterEverglades.tif"))
GreaterEverglades.ResilientSites <- raster(str_c(GreaterEverglades.inWS, "ResilientSites_clip_GreaterEverglades.tif"))
GreaterEverglades.ConservationValues <- raster(str_c(GreaterEverglades.inWS, "ConservationValues_clip_GreaterEvergladeds_lookup.tif"))

### Convert 120 value to NA in Richness Raster ###
summary(GreaterEverglades.Richness$Richness_clip_GreaterEverglades)
GreaterEverglades.Richness[GreaterEverglades.Richness==128] <- NA
summary(GreaterEverglades.Richness$layer)
plot(GreaterEverglades.Richness$layer)

### Create Boxplots ###

# Richness #
jpeg(str_c(GreaterEverglades.outWS, "GreaterEverglades_Richness_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.Richness.boxplot <- raster::boxplot(GreaterEverglades.Richness$layer, ylab="Richness")
dev.off()

# ConnectivityClimateFlow #
jpeg(str_c(GreaterEverglades.outWS, "GreaterEverglades_ConnectivityClimateFlow_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.ConnectivityClimateFlow.boxplot <- raster::boxplot(GreaterEverglades.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_GreaterEverglades, ylab="Connectivity & Climate Flow")
dev.off()

# ResilientSites #
jpeg(str_c(GreaterEverglades.outWS, "GreaterEverglades_ResilientSites_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.Richness.boxplot <- raster::boxplot(GreaterEverglades.ResilientSites$ResilientSites_clip_GreaterEverglades, ylab="Resilience")
dev.off()

# ConservationValues #
jpeg(str_c(GreaterEverglades.outWS, "GreaterEverglades_ConservationValues_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.ConservationValues.boxplot <- raster::boxplot(GreaterEverglades.ConservationValues$ConservationValues_clip_GreaterEvergladeds_lookup, ylab="Conservation Values")
dev.off()

############################
### Southern Appalachian ###
############################

### Set Workspaces ###
SouthernAppalachian.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/NationalAnalysis_FocalAreaClips/SouthernAppalachian/"
SouthernAppalachian.outWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/NationalAnalysis_FocalAreaClips/SouthernAppalachian/Boxplots/"

### Import Rasters ###
SouthernAppalachian.Richness <- raster(str_c(SouthernAppalachian.inWS, "Richness_clip_SouthernAppalachian.tif"))
SouthernAppalachian.ConnectivityClimateFlow <- raster(str_c(SouthernAppalachian.inWS, "ConnectivityClimateFlow_clip_SouthernAppalachian.tif"))
SouthernAppalachian.ResilientSites <- raster(str_c(SouthernAppalachian.inWS, "ResilientSites_clip_SouthernAppalachian.tif"))
SouthernAppalachian.ConservationValues <- raster(str_c(SouthernAppalachian.inWS, "ConservationValues_clip_SouthernAppalachian_lookup.tif"))

### Convert 120 value to NA in Richness Raster ###
summary(SouthernAppalachian.Richness$Richness_clip_SouthernAppalachian)
SouthernAppalachian.Richness[SouthernAppalachian.Richness==128] <- NA
summary(SouthernAppalachian.Richness$layer)
plot(SouthernAppalachian.Richness$layer)

### Create Boxplots ###

# Richness #
jpeg(str_c(SouthernAppalachian.outWS, "SouthernAppalachian_Richness_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.Richness.boxplot <- raster::boxplot(SouthernAppalachian.Richness$layer, ylab="Richness")
dev.off()

# ConnectivityClimateFlow #
jpeg(str_c(SouthernAppalachian.outWS, "SouthernAppalachian_ConnectivityClimateFlow_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.ConnectivityClimateFlow.boxplot <- raster::boxplot(SouthernAppalachian.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_SouthernAppalachian, ylab="Connectivity & Climate Flow")
dev.off()

# ResilientSites #
jpeg(str_c(SouthernAppalachian.outWS, "SouthernAppalachian_ResilientSites_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.ResilientSites.boxplot <- raster::boxplot(SouthernAppalachian.ResilientSites$ResilientSites_clip_SouthernAppalachian, ylab="Resilience")
dev.off()

# ConservationValues #
jpeg(str_c(SouthernAppalachian.outWS, "SouthernAppalachian_ConservationValues_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.ConservationValues.boxplot <- raster::boxplot(SouthernAppalachian.ConservationValues$ConservationValues_clip_SouthernAppalachian_lookup, ylab="Conservation Values")
dev.off()

################
### Dinosaur ###
################

### Set Workspaces ###
Dinosaur.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/NationalAnalysis_FocalAreaClips/Dinosaur/"
Dinosaur.outWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/NationalAnalysis_FocalAreaClips/Dinosaur/Boxplots/"

### Import Rasters ###
Dinosaur.Richness <- raster(str_c(Dinosaur.inWS, "Richness_clip_Dinosaur.tif"))
Dinosaur.ConnectivityClimateFlow <- raster(str_c(Dinosaur.inWS, "ConnectivityClimateFlow_clip_Dinosaur.tif"))
Dinosaur.ResilientSites <- raster(str_c(Dinosaur.inWS, "ResilientSites_clip_Dinosaur.tif"))
Dinosaur.ConservationValues <- raster(str_c(Dinosaur.inWS, "ConservationValues_clip_Dinosaur_lookup.tif"))

### Convert 120 value to NA in Richness Raster ###
summary(Dinosaur.Richness$Richness_clip_Dinosaur)
Dinosaur.Richness[Dinosaur.Richness==128] <- NA
summary(Dinosaur.Richness$Richness_clip_Dinosaur)
plot(Dinosaur.Richness$Richness_clip_Dinosaur)

### Create Boxplots ###

# Richness #
jpeg(str_c(Dinosaur.outWS, "Dinosaur_Richness_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.Richness.boxplot <- raster::boxplot(Dinosaur.Richness$Richness_clip_Dinosaur, ylab="Richness")
dev.off()

# ConnectivityClimateFlow #
jpeg(str_c(Dinosaur.outWS, "Dinosaur_ConnectivityClimateFlow_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.ConnectivityClimateFlow.boxplot <- raster::boxplot(Dinosaur.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_Dinosaur, ylab="Connectivity & Climate Flow")
dev.off()

# ResilientSites #
jpeg(str_c(Dinosaur.outWS, "Dinosaur_ResilientSites_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.ResilientSites.boxplot <- raster::boxplot(Dinosaur.ResilientSites$ResilientSites_clip_Dinosaur, ylab="Resilience")
dev.off()

# ConservationValues #
jpeg(str_c(Dinosaur.outWS, "Dinosaur_ConservationValues_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.ConservationValues.boxplot <- raster::boxplot(Dinosaur.ConservationValues$ConservationValues_clip_Dinosaur_lookup, ylab="Conservation Values")
dev.off()

