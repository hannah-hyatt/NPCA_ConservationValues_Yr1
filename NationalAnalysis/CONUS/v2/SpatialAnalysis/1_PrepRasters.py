# This script: Second iteration of the national analysis performed on CONUS
# 1) Resamples the Connectivity/Climate Flow and Range Size Rarity Datasets to 30m to match the Resilient Sites Raster
# 2) Processes the Resilient Sites to be in the correct format to import to R for the quantile calculations.

# Import system modules
import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')

# Print time at the start of the script
now = datetime.now().time()  # time object
print(now)

####################################
### Set Variables & Environments ###
####################################

### Set Variables ###
ResilientSites = arcpy.Raster(r"S:\Data\External\Evaluation\TNC_ResilientConnectedLandscapes\y2023_triballands\resilience_internal_2021_11\resilience_internal\Resilience_Internal.gdb\resilience_score")
ConnectivityClimateFlow = arcpy.Raster(r"S:\Projects\NPCA\Data\Source\Unzipped\TNC\Connectivity_and_Climate_Flow_Raw\Connectivity_and_Climate_Flow_Raw.gdb\Climate_Flow_W2W") # UPDATE - in Data/external path Climateflow w2w layer c_flow_w2w
RSR = arcpy.Raster(r"S:\Data\NatureServe\Species_Distributions\MoBI_HabitatModels\April2021\RSR_All.tif") # UPDATE to new MOBI
outWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\CONUS\1_DecileCalculationInputs" #UPDATE to new location

### Set Environments ###
arcpy.env.overwriteOutput = True
arcpy.env.snapRaster = ResilientSites
print("Variables & Environments Set. Resampling rasters...")

###############################
### Resample Rasters to 30m ###
###############################

#### Connectivity and Climate Flow ###
ConnectivityClimateFlow_30m = outWS + "\\ConnectivityClimateFlow_30m.tif"
arcpy.management.Resample(ConnectivityClimateFlow, ConnectivityClimateFlow_30m, 30)
print("Connectivity and Climate Flow raster resampled.")

#### MoBI Species Richness ###
RSR_30m = outWS + "\\RSR_30m.tif"
arcpy.management.Resample(RSR, RSR_30m, 30)
print("RSR raster resampled.")

############################################
### Process the "Resilient Sites" raster ###
############################################

### This is needed to import as TIF to R (to avoid using R-ArcGIS Bridge)
arcpy.RasterToOtherFormat_conversion(ResilientSites, outWS, "TIFF")

# Execute Lookup
ResilientSites_lookup = outWS + "\\ResilientSites_lookup.tif"
lookupField = "Value"
outRaster_lookup = Lookup(ResilientSites, lookupField)
outRaster_lookup.save(ResilientSites_lookup)
print("ResilientSites Value field set to Resilience")

### Set Value of 9999 to NA ###
SetNullRaster = outWS + "\\ResilientSites_null.tif"
where_clause="Value = 9999"
outSetNull = SetNull(ResilientSites_lookup, ResilientSites_lookup, where_clause)
outSetNull.save(SetNullRaster)
print("Value of 9999 set to NA")

print("Script complete")

# Print time at the start of the script
now = datetime.now().time()  # time object
print(now)
