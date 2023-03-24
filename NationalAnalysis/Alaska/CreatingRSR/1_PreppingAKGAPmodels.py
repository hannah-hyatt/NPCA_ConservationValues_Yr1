# ---------------------------------------------------------------------------------------------------- #
# This script prepares AK GAP models provided by Tracey Gothardt for the NPCA National Analysis.
# The goal is to create an RSR version of these models by doing the following:
#   1.) copy Esri GRID rasters to .tifs and clean up model data - this script
#   2.) calculate the area of the species habitat model, the inverse of the area, and create lookup raster
#       for each model
#   3.) mosaic all the inverse rasters together
#
# This script also fixes an issue with the deductive models: OG ded model extents are equal to the full extent of AK.
# This script fixes the raster so that the extent matches the distribution of the data.
#
# Developed by Hannah Ceasar on 3/24/23
# ---------------------------------------------------------------------------------------------------- #

# Import Modules
import os
import arcpy
from arcpy import env
from arcpy.sa import *
from datetime import datetime

# Set Environments
#inWS = r"S:\Projects\NPCA\Data\GAP_AK\Final_Selected_Models_Rasters" # Folder containing all species' folders/models
inWS = r"S:\Projects\NPCA\Data\GAP_AK\Test_Models" # Folder containing test group of models
TifWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\1_TifTransfer"
RastertoPoly = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\2_FixingModelExtents\RastertoPoly.gdb"
scratchWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\scratch"
env.workspace = TifWS
arcpy.env.overwriteOutput = True
print("environments set")


# create SGCN list
SGCNlist = []
SGCN_file = open(r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\NPCA_AlaskaSGCNlist_20230322.txt") #this list of species can be updated to select a subset of all SHMs provided by AK
for word in SGCN_file:
    word = word.rstrip("\n") # this removes the spaces after each word
    SGCNlist.append(word)
print("SGCN list created")

# Create a raster list
arcpy.env.workspace = inWS
raster_list = arcpy.ListRasters("*","GRID")

# Loop through the list of SGCN rasters to clean the data
for raster in raster_list:
    if raster in SGCNlist:
        print(raster)
        if (raster.endswith(('ind','com'))):
            # Reclassify inductive and combined rasters to be binary tiffs
            inRaster = inWS +"\\"+ raster
            out_raster = arcpy.sa.Reclassify(inRaster, "VALUE", "0 NODATA;1 1", "NODATA")
            out_raster.save(TifWS + "\\" + raster + ".tif")
            rastername = raster
            print("ind, com exported")
        elif (raster.endswith(('ded'))):
            ded_out = TifWS + "\\" + raster + ".tif"
            
            # Loop through deductive models to re-focus the raster extent to just where the data are present
            # Convert raster to points
            inRaster = inWS +"\\"+ raster + ".tif"
            outSHP = RastertoPoly + "\\" + raster
            arcpy.conversion.RasterToPolygon(raster, outSHP)
            print("raster to poly complete")

            # Clip raster to poly extent
            inRaster = inWS +"\\"+ raster
            outRaster = TifWS + "\\" + raster + ".tif"
            with arcpy.EnvManager(extent= outSHP):
                arcpy.management.Clip(inRaster, '', outRaster)
                print("clip complete")
            
print("Script complete")
