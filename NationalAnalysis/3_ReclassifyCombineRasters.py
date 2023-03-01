# This script:
# 1) Reclassifies the 3 input raster (Resilience, Connectivity/Flow, Richnessnes) by the quantile breaks calcualted in R
# 2) Combines the 3 reclassified input datasets into a single raster and sum the values to get the "Conservation Value"
# 3) Use the lookup tool to create a raster with the official "Value" field as the summed  "Conservation Value"
#    This step is needed to import to R/calculate CONUS-scale quantiles for the box plots.    

# Import system modules
import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')
arcpy.env.overwriteOutput = True

# Print time at the start of the script
now = datetime.now().time()  # time object
print(now)

#####################
### Set Variables ###
#####################

### Set Workspaces ###
inWS = r"S:\Projects\NPCA\Workspace\Ellie_Linden\1_DecileCalculationInputs"
outWS = r"S:\Projects\NPCA\Workspace\Ellie_Linden\3_Reclassified"
outWS_combine = r"S:\Projects\NPCA\Workspace\Ellie_Linden\4_Combined"

### Import 30m Rasters ###
Richness = inWS + "\\Richness_30m.tif"
ConnectivityClimateFlow = inWS + "\\ConnectivityClimateFlow_30m.tif"
ResilientSites = inWS + "\\ResilientSites_null.tif"

### Set Quantile Breaks ###
Richness_remap = "0 0 1;1 1 2;2 2 3;3 3 4;4 32 5"
ConnectivityClimateFlow_remap = "-3500 -906 1;-906 103 2;103 692 3;692 1226 4;1226 3500 5"
ResilientSites_remap = "-4000 -913 1;-913 -178 2;-178 520 3;520 1199 4;1199 3500 5"

print("Variables/environments set.")

##########################
### Reclassify Rasters ###
##########################

### Richness ###
Richness_outRaster = outWS + "\\Richness_reclass.tif"
Richness_reclass = arcpy.sa.Reclassify(Richness, "Value", Richness_remap, "DATA");
Richness_reclass.save(Richness_outRaster)
print("Richness reclassified.")

### Connectivity & Flow ###
ConnectivityClimateFlow_outRaster = outWS + "\\ConnectivityClimateFlow_reclass.tif"
ConnectivityClimateFlow_reclass = arcpy.sa.Reclassify(ConnectivityClimateFlow, "Value", ConnectivityClimateFlow_remap, "DATA");
ConnectivityClimateFlow_reclass.save(ConnectivityClimateFlow_outRaster)
print("Connectivity Climate Flow reclassified.")

### Resilient Sites ###
ResilientSites_outRaster = outWS + "\\ResilientSites_reclass.tif"
ResilientSites_reclass = arcpy.sa.Reclassify(ResilientSites, "Value", ResilientSites_remap, "DATA");
ResilientSites_reclass.save(ResilientSites_outRaster)
print("Richness reclassified.")

####################################
### Combine Reclassified Rasters ###
####################################

### Combine Rasters ###
Combine_outRaster = outWS_combine + "\\ConservationValues.tif"
outCombine = Combine([Richness_outRaster, ConnectivityClimateFlow_outRaster, ResilientSites_outRaster])
outCombine.save(Combine_outRaster)
print("Rasters combined.")

### Sum Fields to Calculate "Conservation Value" ###
arcpy.management.AddField(in_table=Combine_outRaster, field_name="ConVal", field_type="LONG", field_precision=None, field_scale=None, field_length=None, field_alias="", field_is_nullable="NULLABLE", field_is_required="NON_REQUIRED", field_domain="")
arcpy.management.CalculateField(in_table=Combine_outRaster, field="ConVal", expression="!Richness_r! + !Connectivi! + !ResilientS!", expression_type="PYTHON3")
print("Conservation Value calculated.")

################################################################################
### Convert "Conservation Value" field to "VALUE" for Percentile Calculation ###
################################################################################
ConservationValues_lookup = outWS_combine + "\\ConservationValues_lookup.tif"
lookupField = "ConVal"
outRaster_lookup = Lookup(Combine_outRaster, lookupField)
outRaster_lookup.save(ConservationValues_lookup)
print("ResilientSites Value field set to Resilience")

print("Complete")
