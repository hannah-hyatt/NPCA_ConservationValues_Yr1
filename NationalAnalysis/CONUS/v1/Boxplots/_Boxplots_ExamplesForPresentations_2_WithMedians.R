# rm(list = ls())

library(raster)
library(tidyverse)

######################
### Set Workspaces ###
######################
CONUS.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/DensityPlotPrep/2_FloatingPoint/"
GreaterEverglades.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/_ExampleFocalAreasForPresentation/GreaterEverglades/"
SouthernAppalachian.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/_ExampleFocalAreasForPresentation/SouthernAppalachian/"
Dinosaur.inWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/_ExampleFocalAreasForPresentation/Dinosaur/"
outWS <- "S:/Projects/NPCA/Workspace/Ellie_Linden/Boxplots/_ExampleFocalAreas/20230120/"

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

# -------------------------- #
# --- Greater Everglades --- #
# -------------------------- #

### Import Rasters ###
GreaterEverglades.Richness <- raster(str_c(GreaterEverglades.inWS, "Richness_clip_GreaterEverglades.tif"))
GreaterEverglades.ConnectivityClimateFlow <- raster(str_c(GreaterEverglades.inWS, "ConnectivityClimateFlow_clip_GreaterEverglades.tif"))
GreaterEverglades.ResilientSites <- raster(str_c(GreaterEverglades.inWS, "ResilientSites_clip_GreaterEverglades.tif"))
GreaterEverglades.ConservationValues <- raster(str_c(GreaterEverglades.inWS, "ConservationValues_clip_GreaterEvergladeds_lookup.tif"))

### Convert 120 value to NA in Richness Raster ###
GreaterEverglades.Richness[GreaterEverglades.Richness==128] <- NA

# ----------------------------- #
# --- Southern Appalachian  --- #
# ----------------------------- #

### Import Rasters ###
SouthernAppalachian.Richness <- raster(str_c(SouthernAppalachian.inWS, "Richness_clip_SouthernAppalachian.tif"))
SouthernAppalachian.ConnectivityClimateFlow <- raster(str_c(SouthernAppalachian.inWS, "ConnectivityClimateFlow_clip_SouthernAppalachian.tif"))
SouthernAppalachian.ResilientSites <- raster(str_c(SouthernAppalachian.inWS, "ResilientSites_clip_SouthernAppalachian.tif"))
SouthernAppalachian.ConservationValues <- raster(str_c(SouthernAppalachian.inWS, "ConservationValues_clip_SouthernAppalachian_lookup.tif"))

### Convert 120 value to NA in Richness Raster ###
SouthernAppalachian.Richness[SouthernAppalachian.Richness==128] <- NA

# ----------------- #
# --- Dinosaur  --- #
# ----------------- #

### Import Rasters ###
Dinosaur.Richness <- raster(str_c(Dinosaur.inWS, "Richness_clip_Dinosaur.tif"))
Dinosaur.ConnectivityClimateFlow <- raster(str_c(Dinosaur.inWS, "ConnectivityClimateFlow_clip_Dinosaur.tif"))
Dinosaur.ResilientSites <- raster(str_c(Dinosaur.inWS, "ResilientSites_clip_Dinosaur.tif"))
Dinosaur.ConservationValues <- raster(str_c(Dinosaur.inWS, "ConservationValues_clip_Dinosaur_lookup.tif"))

### Convert 120 value to NA in Richness Raster ###
Dinosaur.Richness[Dinosaur.Richness==128] <- NA

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

# --- Richness --- #
# Min #
GreaterEverglades.Richness.min <- summary(GreaterEverglades.Richness$layer)[[1]]
SouthernAppalachian.Richness.min <- summary(SouthernAppalachian.Richness$layer)[[1]]
Dinosaur.Richness.min <- summary(Dinosaur.Richness$Richness_clip_Dinosaur)[[1]]

Richness.min <- min(GreaterEverglades.Richness.min, SouthernAppalachian.Richness.min, Dinosaur.Richness.min)

# Max #
GreaterEverglades.Richness.max <- summary(GreaterEverglades.Richness$layer)[[5]]
SouthernAppalachian.Richness.max <- summary(SouthernAppalachian.Richness$layer)[[5]]
Dinosaur.Richness.max <- summary(Dinosaur.Richness$Richness_clip_Dinosaur)[[5]]

Richness.max <- max(GreaterEverglades.Richness.max, SouthernAppalachian.Richness.max, Dinosaur.Richness.max)

# --- ConnectivityClimateFlow --- #
# Min #
GreaterEverglades.ConnectivityClimateFlow.min <- summary(GreaterEverglades.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_GreaterEverglades)[[1]]
SouthernAppalachian.ConnectivityClimateFlow.min <- summary(SouthernAppalachian.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_SouthernAppalachian)[[1]]
Dinosaur.ConnectivityClimateFlow.min <- summary(Dinosaur.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_Dinosaur)[[1]]

ConnectivityClimateFlow.min <- min(GreaterEverglades.ConnectivityClimateFlow.min, SouthernAppalachian.ConnectivityClimateFlow.min, Dinosaur.ConnectivityClimateFlow.min)

# Max #
GreaterEverglades.ConnectivityClimateFlow.max <- summary(GreaterEverglades.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_GreaterEverglades)[[5]]
SouthernAppalachian.ConnectivityClimateFlow.max <- summary(SouthernAppalachian.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_SouthernAppalachian)[[5]]
Dinosaur.ConnectivityClimateFlow.max <- summary(Dinosaur.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_Dinosaur)[[5]]

ConnectivityClimateFlow.max <- max(GreaterEverglades.ConnectivityClimateFlow.max, SouthernAppalachian.ConnectivityClimateFlow.max, Dinosaur.ConnectivityClimateFlow.max)

# --- ResilientSites --- #
# Min #
GreaterEverglades.ResilientSites.min <- summary(GreaterEverglades.ResilientSites$ResilientSites_clip_GreaterEverglades)[[1]]
SouthernAppalachian.ResilientSites.min <- summary(SouthernAppalachian.ResilientSites$ResilientSites_clip_SouthernAppalachian)[[1]]
Dinosaur.ResilientSites.min <- summary(Dinosaur.ResilientSites$ResilientSites_clip_Dinosaur)[[1]]

ResilientSites.min <- min(GreaterEverglades.ResilientSites.min, SouthernAppalachian.ResilientSites.min, Dinosaur.ResilientSites.min)

# Max #
GreaterEverglades.ResilientSites.max <- summary(GreaterEverglades.ResilientSites$ResilientSites_clip_GreaterEverglades)[[5]]
SouthernAppalachian.ResilientSites.max <- summary(SouthernAppalachian.ResilientSites$ResilientSites_clip_SouthernAppalachian)[[5]]
Dinosaur.ResilientSites.max <- summary(Dinosaur.ResilientSites$ResilientSites_clip_Dinosaur)[[5]]

ResilientSites.max <- max(GreaterEverglades.ResilientSites.max, SouthernAppalachian.ResilientSites.max, Dinosaur.ResilientSites.max)

# --- ConservationValues --- #
# Min #
GreaterEverglades.ConservationValues.min <- summary(GreaterEverglades.ConservationValues$ConservationValues_clip_GreaterEvergladeds_lookup)[[1]]
SouthernAppalachian.ConservationValues.min <- summary(SouthernAppalachian.ConservationValues$ConservationValues_clip_SouthernAppalachian_lookup)[[1]]
Dinosaur.ConservationValues.min <- summary(Dinosaur.ConservationValues$ConservationValues_clip_Dinosaur_lookup)[[1]]

ConservationValues.min <- min(GreaterEverglades.ConservationValues.min, SouthernAppalachian.ConservationValues.min, Dinosaur.ConservationValues.min)

# Max #
GreaterEverglades.ConservationValues.max <- summary(GreaterEverglades.ConservationValues$ConservationValues_clip_GreaterEvergladeds_lookup)[[5]]
SouthernAppalachian.ConservationValues.max <- summary(SouthernAppalachian.ConservationValues$ConservationValues_clip_SouthernAppalachian_lookup)[[5]]
Dinosaur.ConservationValues.max <- summary(Dinosaur.ConservationValues$ConservationValues_clip_Dinosaur_lookup)[[5]]

ConservationValues.max <- max(GreaterEverglades.ConservationValues.max, SouthernAppalachian.ConservationValues.max, Dinosaur.ConservationValues.max)

#######################
### Create Boxplots ###
#######################

# -------------------------- #
# --- Greater Everglades --- #
# -------------------------- #

# Richness #
jpeg(str_c(outWS, "GreaterEverglades_Richness_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.Richness.boxplot <- raster::boxplot(GreaterEverglades.Richness$layer, 
                                                      ylab="Richness",
                                                      ylim=c(Richness.min, Richness.max))
abline(h=CONUS.Richness.median, col="blue", lwd=2, lty=2)
dev.off()

# ConnectivityClimateFlow #
jpeg(str_c(outWS, "GreaterEverglades_ConnectivityClimateFlow_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.ConnectivityClimateFlow.boxplot <- raster::boxplot(GreaterEverglades.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_GreaterEverglades, 
                                                                     ylab="Connectivity & Climate Flow",
                                                                     ylim=c(ConnectivityClimateFlow.min, ConnectivityClimateFlow.max))
abline(h=CONUS.ConnectivityClimateFlow.median, col="blue", lwd=2, lty=2)
dev.off()

# ResilientSites #
jpeg(str_c(outWS, "GreaterEverglades_ResilientSites_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.Richness.boxplot <- raster::boxplot(GreaterEverglades.ResilientSites$ResilientSites_clip_GreaterEverglades, 
                                                      ylab="Resilience",
                                                      ylim=c(ResilientSites.min, ResilientSites.max))
abline(h=CONUS.Resilience.median, col="blue", lwd=2, lty=2)
dev.off()

# ConservationValues #
jpeg(str_c(outWS, "GreaterEverglades_ConservationValues_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
GreaterEverglades.ConservationValues.boxplot <- raster::boxplot(GreaterEverglades.ConservationValues$ConservationValues_clip_GreaterEvergladeds_lookup, 
                                                                ylab="Conservation Values",
                                                                ylim=c(ConservationValues.min, ConservationValues.max))
abline(h=CONUS.ConservationValues.median, col="blue", lwd=2, lty=2)
dev.off()

# ---------------------------- #
# --- Southern Appalachian --- #
# ---------------------------- #

# Richness #
jpeg(str_c(outWS, "SouthernAppalachian_Richness_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.Richness.boxplot <- raster::boxplot(SouthernAppalachian.Richness$layer, 
                                                        ylab="Richness", 
                                                        ylim=c(Richness.min, Richness.max))
abline(h=CONUS.Richness.median, col="blue", lwd=2, lty=2)
dev.off()

# ConnectivityClimateFlow #
jpeg(str_c(outWS, "SouthernAppalachian_ConnectivityClimateFlow_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.ConnectivityClimateFlow.boxplot <- raster::boxplot(SouthernAppalachian.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_SouthernAppalachian, 
                                                                       ylab="Connectivity & Climate Flow",
                                                                       ylim=c(ConnectivityClimateFlow.min, ConnectivityClimateFlow.max))
abline(h=CONUS.ConnectivityClimateFlow.median, col="blue", lwd=2, lty=2)
dev.off()

# ResilientSites #
jpeg(str_c(outWS, "SouthernAppalachian_ResilientSites_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.ResilientSites.boxplot <- raster::boxplot(SouthernAppalachian.ResilientSites$ResilientSites_clip_SouthernAppalachian, 
                                                              ylab="Resilience",
                                                              ylim=c(ResilientSites.min, ResilientSites.max))
abline(h=CONUS.Resilience.median, col="blue", lwd=2, lty=2)
dev.off()

# ConservationValues #
jpeg(str_c(outWS, "SouthernAppalachian_ConservationValues_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
SouthernAppalachian.ConservationValues.boxplot <- raster::boxplot(SouthernAppalachian.ConservationValues$ConservationValues_clip_SouthernAppalachian_lookup, 
                                                                  ylab="Conservation Values",
                                                                  ylim=c(ConservationValues.min, ConservationValues.max))
abline(h=CONUS.ConservationValues.median, col="blue", lwd=2, lty=2)
dev.off()

# ---------------- #
# --- Dinosaur --- #
# ---------------- #

# Richness #
jpeg(str_c(outWS, "Dinosaur_Richness_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.Richness.boxplot <- raster::boxplot(Dinosaur.Richness$Richness_clip_Dinosaur, 
                                             ylab="Richness",
                                             ylim=c(Richness.min, Richness.max))
abline(h=CONUS.Richness.median, col="blue", lwd=2, lty=2)
dev.off()

# ConnectivityClimateFlow #
jpeg(str_c(outWS, "Dinosaur_ConnectivityClimateFlow_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.ConnectivityClimateFlow.boxplot <- raster::boxplot(Dinosaur.ConnectivityClimateFlow$ConnectivityClimateFlow_clip_Dinosaur, 
                                                            ylab="Connectivity & Climate Flow",
                                                            ylim=c(ConnectivityClimateFlow.min, ConnectivityClimateFlow.max))
abline(h=CONUS.ConnectivityClimateFlow.median, col="blue", lwd=2, lty=2)
dev.off()

# ResilientSites #
jpeg(str_c(outWS, "Dinosaur_ResilientSites_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.ResilientSites.boxplot <- raster::boxplot(Dinosaur.ResilientSites$ResilientSites_clip_Dinosaur, 
                                                   ylab="Resilience",
                                                   ylim=c(ResilientSites.min, ResilientSites.max))
abline(h=CONUS.Resilience.median, col="blue", lwd=2, lty=2)
dev.off()

# ConservationValues #
jpeg(str_c(outWS, "Dinosaur_ConservationValues_boxplot.jpg"), width = 1000, height = 2000, units = "px", res = 300)
Dinosaur.ConservationValues.boxplot <- raster::boxplot(Dinosaur.ConservationValues$ConservationValues_clip_Dinosaur_lookup, 
                                                       ylab="Conservation Values",
                                                       ylim=c(ConservationValues.min, ConservationValues.max))
abline(h=CONUS.ConservationValues.median, col="blue", lwd=2, lty=2)
dev.off()

