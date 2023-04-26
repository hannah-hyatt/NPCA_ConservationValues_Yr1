# ---------------------------------------------------------------------------------------------------- #
# This script prepares AK GAP models provided by Tracey Gothardt for the NPCA National Analysis.
# The goal is to create an RSR version of these models by doing the following:
#   1.) copy Esri GRID rasters to .tifs
#   2.) calculate the area of the species habitat model, the inverse of the area, and create lookup raster
#       for each model
#   3.) mosaic all the inverse rasters together - This script
#
# Developed by Hannah Ceasar on 3/24/23
# ---------------------------------------------------------------------------------------------------- #

# Import Modules
import os
import arcpy
from arcpy import env
from arcpy.sa import *
from datetime import datetime

# Print time at the start of the script
now = datetime.now().time()  # time object
print(now)

# Set Environments
rsrWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\2_indvRSRs"
MosaicWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\3_MosaicRSR"
env.workspace = MosaicWS
arcpy.env.overwriteOutput = True
print("environments set")

# Use the following section when you want to limit the RSR layer to specific species lists
Spslist = []
Sps_file = open(r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\NPCA_AlaskaSGCN_Red.txt") #list of SGCNs
for word in Sps_file:
    word = word.rstrip("\n") # this removes the spaces after each word
    word = word + ".tif"
    Spslist.append(word)
print("Species list created")

# Create raster list
arcpy.env.workspace = rsrWS
RasterList = arcpy.ListRasters(Spslist,"TIF")
print("raster list created")

# Mosaic to new Raster
MosaicOut = "Alaska_RSR_SGCN_R.tif"
arcpy.management.MosaicToNewRaster(Spslist, MosaicWS, MosaicOut, 'PROJCS["NAD_1983_Albers",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",-154.0],PARAMETER["Standard_Parallel_1",55.0],PARAMETER["Standard_Parallel_2",65.0],PARAMETER["Latitude_Of_Origin",50.0],UNIT["Meter",1.0]]', "32_BIT_FLOAT", 60, 1, "SUM", "FIRST")
print("Mosaic Created")

# Print time at the start of the script
now = datetime.now().time()  # time object
print(now)
