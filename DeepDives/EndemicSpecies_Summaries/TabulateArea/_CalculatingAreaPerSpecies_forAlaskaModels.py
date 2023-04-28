# ---------------------------------------------------------------------------------------------------- #
# * NOTE: Please make a copy of this script before editing and/or running. 
# * This script calculates the total area of each species' binary habitat within a boundary.
# * The default is to loop through all MoBI species to clip the habitat.
#   This can be narrowed down to a specific list of species by changing the text file containing a list of the desired cutecodes under "Create Species List" section
# * 4 variables need to be updated by the user:
#   1) Boundary: Specified boundary to clip the rasters
#   2) outWS: output workpace folder for tables
#   3) outTable: output dbf file
#   4) Boundary_field: field of boundary to summarize data
# * Script written by Ellie Linden with help from Tandena Wagner in the summer of 2020
# * Edited by Hannah Ceasar 4/26 for NPCA Analysis in Alaska
# ---------------------------------------------------------------------------------------------------- #

# Import Modules
import os
import arcpy
from arcpy import env
from arcpy.sa import *
from datetime import datetime
# Print start time
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print("Start Time:", timestamp)

# Set Environments
inWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\StackingModels\1_TifTransfer" # Folder containing all species' folders/models
env.workspace = inWS
arcpy.env.overwriteOutput = True

# Set Variables
Boundary = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\PADUS_AK_StudyAreas_union_AnalysisLayer" # UPDATE
outWS = r"S:\Projects\NPCA\Workspace\Hannah_Hyatt\SpeciesSummaries\IntModelTbls_BearCoast" # UPDATE
outTable = r"AKGAPshms_TabAreaMerge_AK" # UPDATE
Boundary_field = "NPCA_Status_GAP_StudyArea" # UPDATE

# Create Species List
Spslist = []
Sps_file = open(r'S:\Projects\NPCA\Workspace\Hannah_Hyatt\NationalAnalysis\Alaska\NPCA_AlaskaSGCN_withtif.txt', 'r') # UPDATE IF NEEDED
for word in Sps_file:
    word = word.rstrip("\n") # this removes the spaces after each word
    Spslist.append(word)
print("Spslist created")

# Create a raster list
arcpy.env.workspace = inWS
RasterList = arcpy.ListRasters("*","TIF")
print("Raster list created")

# Loop through cutecodes to get rasters and calculate area
for raster in RasterList:
    if raster in Spslist:
        print("working on "+raster)
        species = raster.rstrip(".tif")
        SpeciesRaster = inWS + "\\" + raster

        # Calculate area in meters squared
        print("Calculating area for "+species)
        area_dbf = outWS + "\\" + species + "_areatable.dbf"
        TabulateArea(SpeciesRaster, "Value", Boundary, Boundary_field, area_dbf, 60,"CLASSES_AS_ROWS")
       
        # Add/calculate cutecode field in dbf output
        field = "model_name"
        expression = str(species)
        print(species+" complete")
        arcpy.AddField_management(area_dbf, field, "TEXT")
        arcpy.CalculateField_management(area_dbf, field, '"'+expression+'"',"PYTHON")
        
# Merge all output dbfs
env.workspace = outWS
listTable = arcpy.ListTables()
Areas_merged = outTable
arcpy.Merge_management(listTable, Areas_merged)
print("merge complete")

# join species information
species_crosswalk = r"S:\Projects\NPCA\Data\Intermediate\AK_GAPmodels_Species_Crosswalk.csv"
arcpy.management.JoinField(Areas_merged, "model_name", species_crosswalk, "model_name", "Scientific_Name;Common_Name;Grank;AK_Srank")

# Print end time
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print("End Time:", timestamp)

print("Script complete")

