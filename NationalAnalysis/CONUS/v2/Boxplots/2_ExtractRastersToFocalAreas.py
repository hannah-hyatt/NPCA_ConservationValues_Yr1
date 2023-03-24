# This script loops through the 16 CONUS focal areas as well as the 4 raster variables (Richness, Resilience, Connectivity/Flow, Conservation Values) and extracts each raster for each focal area.
# The output rasters will be used to create the boxplots in R.

# Written by Ellie Linden Jan 2023.

# Import system modules
import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')

### Set Workspaces ###
inWS_rasters = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\BoxPlots\2_FloatingPoint"
inWS_StudyAreas = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\StudyAreas_split"
outWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\BoxPlots\3_Rasters_extracted_by_FocalAreas"

### Set Environments ###
arcpy.env.overwriteOutput = True
arcpy.env.snapRaster = inWS_rasters + "\\ConservationValues_float.tif"
print ("Workspaces and Environments set")

### List shapefiles ###
arcpy.env.workspace = inWS_StudyAreas
StudyAreas = arcpy.ListFeatureClasses()

### Loop through Focal Area shapefiles to be used as mask ###
for StudyArea in StudyAreas:
    StudyArea_file = inWS_StudyAreas + "\\" + StudyArea
    StudyArea_name = str(StudyArea)[:-4]
    print(StudyArea_name)

    ### List rasters ###
    arcpy.env.workspace = inWS_rasters
    rasters = arcpy.ListRasters()

    ### Loop through raster variables
    for raster in rasters:
        raster_file = inWS_rasters + "\\" + raster
        raster_name = raster.split('_')[0]
        print(raster_name)

        # Extract raster variable to focal area
        outExtractByMask = ExtractByMask(raster_file, StudyArea_file)
        outRaster = outWS + "\\" + StudyArea_name + "_" + raster_name + ".tif"
        outExtractByMask.save(outRaster)

    # Reset workspace to focal area shapefiles
    arcpy.env.workspace = inWS_StudyAreas


print ("Script Finished")
