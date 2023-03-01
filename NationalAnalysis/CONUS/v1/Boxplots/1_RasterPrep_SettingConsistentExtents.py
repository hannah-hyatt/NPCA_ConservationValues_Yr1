# The purpose of this script is to set all rasters required for box plots to the same extents.
# Ellie briefly tried to do this in a loop, but it would've taken too long to figure out how to deal with setting the variable name, so did it individually.

# Import system modules
import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')

# Set Input Variables/Workspaces
ConservationValues = r"S:\Projects\NPCA\Workspace\Ellie_Linden\4_Combined\ConservationValues_lookup.tif"
ResilientSites = r"S:\Projects\NPCA\Workspace\Ellie_Linden\1_DecileCalculationInputs\ResilientSites_null.tif"
ConnectivityClimateFlow = r"S:\Projects\NPCA\Workspace\Ellie_Linden\1_DecileCalculationInputs\ConnectivityClimateFlow_30m.tif"
Richness = r"S:\Projects\NPCA\Workspace\Ellie_Linden\1_DecileCalculationInputs\Richness_30m.tif"
outWS_extracted = r"S:\Projects\NPCA\Workspace\Ellie_Linden\DensityPlotPrep\1_MaskingForConsistentExtents"
outWS_float = r"S:\Projects\NPCA\Workspace\Ellie_Linden\DensityPlotPrep\2_FloatingPoint"

### Set Environments ###
arcpy.env.overwriteOutput = True
arcpy.env.snapRaster = ConservationValues
arcpy.env.extent = ConservationValues

##########################################
### Extract rasters to the same extent ###
##########################################

### Extract Resilience ###
Resilience_extracted = outWS_extracted + "\\Resilience_masked.tif"
outExtractByMask_resilience = ExtractByMask(ResilientSites, ConservationValues)
outExtractByMask_resilience.save(Resilience_extracted)
print("Resilience extracted")

### Extract Connectivity Climate Flow ###
ConnectivityClimateFlow_extracted = outWS_extracted + "\\ConnectivityClimateFlow_masked.tif"
outExtractByMask_ConnectivityClimateFlow = ExtractByMask(ConnectivityClimateFlow, ConservationValues)
outExtractByMask_ConnectivityClimateFlow.save(ConnectivityClimateFlow_extracted)
print("Connectivity Climate Flow extracted")

### Extract Richness ###
Richness_extracted = outWS_extracted + "\\Richness_masked.tif"
outExtractByMask_Richness = ExtractByMask(Richness, ConservationValues)
outExtractByMask_Richness.save(Richness_extracted)
print("Richness extracted")

#########################################
### Convert rasters to floating point ###
#########################################

### Convert Resilience to Float ###
Resilience_float = outWS_float + "\\Resilience_float.tif"
arcpy.management.CopyRaster(Resilience_extracted, Resilience_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
print("Resilience converted to float")

### Convert Connectivity Climate Flow to Float ###
ConnectivityClimateFlow_float = outWS_float + "\\ConnectivityClimateFlow_float.tif"
arcpy.management.CopyRaster(ConnectivityClimateFlow_extracted, ConnectivityClimateFlow_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
print("Connectivity Climate Flow converted to float")

### Convert Richness to Float ###
Richness_float = outWS_float + "\\Richness_float.tif"
arcpy.management.CopyRaster(Richness_extracted, Richness_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
print("Richness converted to float")

### Convert Conservation Values to Float ###
ConservationValues_float = outWS_float + "\\ConservationValues_float.tif"
arcpy.management.CopyRaster(ConservationValues, ConservationValues_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
print("ConservationValues converted to float")

print ("Script Finished")
