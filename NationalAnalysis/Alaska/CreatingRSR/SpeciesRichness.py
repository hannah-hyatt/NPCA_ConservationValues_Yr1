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
TifWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\1_TifTransfer"
SpsRich = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\SpsRich"
env.workspace = SpsRich
arcpy.env.overwriteOutput = True
print("environments set")

# Use the following section when you want to limit the species richness layer to specific species lists
Spslist = []
Sps_file = open(r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\NPCA_AlaskaSGCNlist_20230330.txt") #list of SGCNs
for word in Sps_file:
    word = word.rstrip("\n") # this removes the spaces after each word
    word = word + ".tif"
    Spslist.append(word)
print("Species list created")

# Create raster list
arcpy.env.workspace = TifWS
RasterList = arcpy.ListRasters(Spslist,"TIF") #update first variable with Spslist if limiting results, for all sps it should read "*"
print("raster list created")

# Mosaic to new Raster
MosaicOut = "Alaska_SpsRich_SGCN_20230330.tif"
arcpy.management.MosaicToNewRaster(Spslist, SpsRich, MosaicOut, 'PROJCS["NAD_1983_Albers",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",-154.0],PARAMETER["Standard_Parallel_1",55.0],PARAMETER["Standard_Parallel_2",65.0],PARAMETER["Latitude_Of_Origin",50.0],UNIT["Meter",1.0]]', "32_BIT_FLOAT", 60, 1, "SUM", "FIRST")
print("Species Richness Created")

# Print time at the start of the script
now = datetime.now().time()  # time object
print(now)
