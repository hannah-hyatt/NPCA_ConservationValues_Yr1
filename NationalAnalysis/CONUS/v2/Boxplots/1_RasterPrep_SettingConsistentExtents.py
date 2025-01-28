# The purpose of this script is to set all rasters required for box plots to the same extents.
# Ellie briefly tried to do this in a loop, but it would've taken too long to figure out how to deal with setting the variable name, so did it individually.

# Import system modules
import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')

# Set Input Variables/Workspaces
#ConservationValues = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\CONUS\4_Combined\ConservationValues_lookup.tif"
ConservationValues = r"S:\Projects\NPCA\_FY25\Data\Final\ConservationValue_v3.tif"
ResilientSites = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\CONUS\1_DecileCalculationInputs\ResilientSites_null.tif"
ConnectivityClimateFlow = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\CONUS\1_DecileCalculationInputs\ConnectivityClimateFlow_30m.tif"
RSR = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\CONUS\1_DecileCalculationInputs\RSR_30m.tif"
outWS_extracted = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\BoxPlots\1_MaskingForConsistentExtents"
outWS_float = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\BoxPlots\2_FloatingPoint"

### Set Environments ###
arcpy.env.overwriteOutput = True
arcpy.env.snapRaster = ConservationValues
arcpy.env.extent = ConservationValues

print("Variables and environments set")

##########################################
### Extract rasters to the same extent ###
##########################################

### Extract Resilience ###
Resilience_extracted = os.path.join(outWS_extracted, "Resilience_masked.tif")
if not os.path.exists(Resilience_extracted):
    outExtractByMask_resilience = ExtractByMask(ResilientSites, ConservationValues)
    outExtractByMask_resilience.save(Resilience_extracted)
    print("Resilience extracted")
else:
    print("Resilience already exists, skipping extraction")

### Extract Connectivity Climate Flow ###
ConnectivityClimateFlow_extracted = os.path.join(outWS_extracted, "ConnectivityClimateFlow_masked.tif")
if not os.path.exists(ConnectivityClimateFlow_extracted):
    outExtractByMask_ConnectivityClimateFlow = ExtractByMask(ConnectivityClimateFlow, ConservationValues)
    outExtractByMask_ConnectivityClimateFlow.save(ConnectivityClimateFlow_extracted)
    print("Connectivity Climate Flow extracted")
else:
    print("Connectivity Climate Flow already exists, skipping extraction")

### Extract RSR ###
RSR_extracted = os.path.join(outWS_extracted, "RSR2024_masked.tif")
if not os.path.exists(RSR_extracted):
    outExtractByMask_RSR = ExtractByMask(RSR, ConservationValues)
    outExtractByMask_RSR.save(RSR_extracted)
    print("RSR extracted")
else:
    print("RSR already exists, skipping extraction")

#########################################
### Convert rasters to floating point ###
#########################################

### Convert Resilience to Float ###
Resilience_float = os.path.join(outWS_float, "Resilience_float.tif")
if not os.path.exists(Resilience_float):
    arcpy.management.CopyRaster(Resilience_extracted, Resilience_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
    print("Resilience converted to float")
else:
    print("Resilience float already exists, skipping conversion")

### Convert Connectivity Climate Flow to Float ###
ConnectivityClimateFlow_float = os.path.join(outWS_float, "ConnectivityClimateFlow_float.tif")
if not os.path.exists(ConnectivityClimateFlow_float):
    arcpy.management.CopyRaster(ConnectivityClimateFlow_extracted, ConnectivityClimateFlow_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
    print("Connectivity Climate Flow converted to float")
else:
    print("Connectivity Climate Flow float already exists, skipping conversion")

### Convert RSR to Float ###
RSR_float = os.path.join(outWS_float, "RSR2024_float.tif")
if not os.path.exists(RSR_float):
    arcpy.management.CopyRaster(RSR_extracted, RSR_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
    print("RSR converted to float")
else:
    print("RSR float already exists, skipping conversion")

### Convert Conservation Values to Float ###
ConservationValues_float = os.path.join(outWS_float, "ConservationValues_float.tif")
if not os.path.exists(ConservationValues_float):
    arcpy.management.CopyRaster(ConservationValues, ConservationValues_float, '', None, "-3.4e+38", "NONE", "NONE", "32_BIT_FLOAT", "NONE", "NONE", "TIFF", "NONE", "CURRENT_SLICE", "NO_TRANSPOSE")
    print("Conservation Values converted to float")
else:
    print("Conservation Values float already exists, skipping conversion")

print("Script Finished")