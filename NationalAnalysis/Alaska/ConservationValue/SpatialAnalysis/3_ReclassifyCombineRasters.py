# This script:
# 1) Reclassifies the 3 input raster (Resilience, Connectivity/Flow, RSR) by the quantile breaks calcualted in R
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
inWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\ConservationValue\1_DecileCalculations"
outWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\ConservationValue\3_Reclassified"
outWS_combine = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\ConservationValue\4_Combined"

### Import 30m Rasters ###
ConnectivityClimateFlow = inWS + "\\ConnectivityClimateFlow_30m.tif"
ResilientSites = inWS + "\\ResilientSites_null.tif"

### Set Quantile Breaks ###
RSR_remap = "0 0.000178 1;0.000178 0.000262 2;0.000262 0.000357 3;0.000357 0.000517 4;0.000517 0.344155"
ConnectivityClimateFlow_remap = "-3500 155 1;155 571 2;571 958 3;958 1552 4;1552 3504 5"
ResilientSites_remap = "-3503 -740 1;-740 68 2;68 767 3;767 1277 4;1277 3500 5"

print("Variables/environments set.")

##########################
### Reclassify Rasters ###
##########################

### RSR ###
##RSR_outRaster = outWS + "\\RSR_reclass.tif"
##RSR_reclass = arcpy.sa.Reclassify(RSR, "Value", RSR_remap, "DATA");
##RSR_reclass.save(RSR_outRaster)
RSR_outRaster = outWS + "\\RSR_reclass.tif"
print("RSR reclassified.")

### Connectivity & Flow ###
ConnectivityClimateFlow_outRaster = outWS + "\\ConnectivityClimateFlow_reclass.tif"
ConnectivityClimateFlow_reclass = arcpy.sa.Reclassify(ConnectivityClimateFlow, "Value", ConnectivityClimateFlow_remap, "DATA");
ConnectivityClimateFlow_reclass.save(ConnectivityClimateFlow_outRaster)
print("Connectivity Climate Flow reclassified.")

### Resilient Sites ###
ResilientSites_outRaster = outWS + "\\ResilientSites_reclass.tif"
ResilientSites_reclass = arcpy.sa.Reclassify(ResilientSites, "Value", ResilientSites_remap, "DATA");
ResilientSites_reclass.save(ResilientSites_outRaster)
print("Resilience reclassified.")

####################################
### Combine Reclassified Rasters ###
####################################

### Combine Rasters ###
Combine_outRaster = outWS_combine + "\\ConservationValues_AK.tif"
outCombine = Combine([RSR_outRaster, ConnectivityClimateFlow_outRaster, ResilientSites_outRaster])
outCombine.save(Combine_outRaster)
print("Rasters combined.")

### Sum Fields to Calculate "Conservation Value" ###
arcpy.management.AddField(in_table=Combine_outRaster, field_name="ConVal", field_type="LONG", field_precision=None, field_scale=None, field_length=None, field_alias="", field_is_nullable="NULLABLE", field_is_required="NON_REQUIRED", field_domain="")
arcpy.management.CalculateField(in_table=Combine_outRaster, field="ConVal", expression="!RSR_reclas! + !Connectivi! + !ResilientS!", expression_type="PYTHON3")
print("Conservation Value calculated.")

################################################################################
### Convert "Conservation Value" field to "VALUE" for Percentile Calculation ###
################################################################################
ConservationValues_lookup = outWS_combine + "\\ConservationValues_AKlookup.tif"
lookupField = "ConVal"
outRaster_lookup = Lookup(Combine_outRaster, lookupField)
outRaster_lookup.save(ConservationValues_lookup)
print("ResilientSites Value field set to Resilience")

print("Complete")
