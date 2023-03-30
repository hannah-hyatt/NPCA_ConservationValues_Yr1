# ---------------------------------------------------------------------------------------------------- #
# This script prepares AK GAP models provided by Tracey Gothardt for the NPCA National Analysis.
# The goal is to create an RSR version of these models by doing the following:
#   1.) copy Esri GRID rasters to .tifs
#   2.) calculate the area of the species habitat model, the inverse of the area, and create lookup raster
#       for each model - This script
#   3.) mosaic all the inverse rasters together
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
inWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\1_TifTransfer"
rsrWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\2_indvRSRs"
scratchWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\scratch"
arcpy.env.overwriteOutput = True
print("environments set")

# create list to focus the following analysis on
Spslist = []
#Sps_file = open(r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\NPCA_AlaskaSGCNlist_fix_20230326.txt") #list of SGCNs
Sps_file = open(r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\NPCA_AlaskaNOTsgcn_20230327.txt") #list of models that aren't SGCNs
for word in Sps_file:
    word = word.rstrip("\n")# this removes the spaces after each word
    word = word + ".tif"
    Spslist.append(word)
print("Species list created")

# Create raster list
arcpy.env.workspace = inWS
RasterList = arcpy.ListRasters("*","TIF")
print("raster list created")

# Loop through rasters to calculate area ratio and inverse area and create individual rsr outputs
for raster in RasterList:
    if raster in Spslist:
        print ("working on " + raster)
        inRaster = inWS + "\\" + raster
        outRaster = rsrWS + "\\" + raster
        
        # Divide pixel count by 1000
        area = "area"
        expression = "(!COUNT!/1000)"
        arcpy.management.CalculateField(inRaster, area, expression, "PYTHON3", '', "DOUBLE", "NO_ENFORCE_DOMAINS")
        print("area calculated")

        # Add/calculate inverse of area
        inverse = "inverse"
        expression = "(1/!area!)"
        arcpy.management.CalculateField(inRaster, inverse, expression, "PYTHON3", '', "DOUBLE", "NO_ENFORCE_DOMAINS")
        print("inverse calculated")
        
        # Create a lookup raster pointing to inverse value
        rsr_raster = Lookup(inRaster, inverse)
        rsr_raster.save(outRaster)
        print("rsr raster created - " + raster + " complete")

print("Script complete")

