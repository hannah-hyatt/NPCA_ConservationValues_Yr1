## Thresholding Conservation Value raster
## PRE PROCESSING: must have thresholded ConVal raster for study area of interest saved as a tif for input.

## This script is the first step in a process to summarize GAP status and Management status
## in areas of highest conservation value for the study areas included in the NPCA project.
## Use this script to get the threshold value which represents the top 10% of values within 
## the conservation value raster inside of each study area.
## Currently the raster is not exporting properly from this code, apply the threshold in ArcGIS Pro
## then use the Tabulate Area python code (step 2) to get the input for step 3

## step 2: S:\Projects\NPCA\Scripts_Analysis\PADUS_Summaries\HighestConVal_Summaries\2-*_TabulateArea_HighestConVal_*
## step 3: S:\Projects\NPCA\Scripts_Analysis\PADUS_Summaries\HighestConVal_Summaries\3-*HighestConVal_DonutChart_*

##define thresholds
thresholds<-c(0.75,0.90,0.95,0.99)

##define output workspace
outWS <- "S:/Projects/NPCA/Data/Intermediate/ConservationValue/ConValue_Thresholded/"

##install packages if you don't have them yet (only do this once per machine)
#install.packages("Rcpp")
#install.packages("sf")
#install.packages("raster")
#install.packages("rgdal")
#install.packages("stringr")

##load required pacakges
library(Rcpp)
library(sf)
library(raster)
library(rgdal)
library(stringr)

overwrite=TRUE

##Load conservation value raster layer
conservationvalue.raster<-raster::raster("S:/Projects/NPCA/Data/Intermediate/ConservationValue/ConVal_BigThicket_v2.tif")

##create a percentile raster for CONUS
conservationvalue.percentile<-quantile(conservationvalue.raster, probs=thresholds)
plot(conservationvalue.percentile)

##reclassify raster values based on percentile
reclass<-cbind(from=c(conservationvalue.percentile, 0), to=c(cellStats(conservationvalue.raster, stat='max'), conservationvalue.percentile), percentile=c(thresholds,NA))

## The following steps don't work properly, to come back and fix them if time permits
## in the meantime, get the top 10% value by viewing conservationvalue.percentile and reclassify the
## the raster to be binary in ArcGIS Pro, then procede to step 2 (tabulate area python script)

#conservationvalue.percentile.raster<-reclassify(x = conservationvalue.raster, rcl = reclass, include.lowest=T)
#plot(conservationvalue.percentile.raster)

##write out the resulting raster as tif
#writeRaster(conservationvalue.percentile.raster, str_c(outWS, "ConservationValueCONUS_thresholded.tif"), datatype='INT4U', format="GTiff", overwrite=T)