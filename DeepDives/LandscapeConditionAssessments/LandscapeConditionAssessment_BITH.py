## Landscape Condition Assessment: to understand the condition of IVC groups, examining the Landscape Condition Model
## and the invasive score of a spatial defined area. Also returns the fire departure mean score as additional information, this
## variable however is not used in calculating the Mean Condition.
##
## Before running this script:
## 1. Clipped NVC raster to the extent of interest with a pairwise buffer of 10km
## 2. Added BITH_flg (0/1 field) to return only IVC groups of interest
## 3. Created text field listing IVC_ELCODE values for each IVC group of interest. This code list was edited to
##    only be values (ex. G009 becomes 9)
##
## Original script written by Chris Tracey can be found here: S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\condition - Backup.py
## Script edited for NPCA project by Hannah Ceasar 4/24

import arcpy, os, re
from arcpy.sa import *

# Check out any necessary licenses.
arcpy.CheckOutExtension("spatial")

scratchWorkspace = r"bigthicket_ScratchWorkspace.gdb"

# set up environments
arcpy.env.workspace = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition"
arcpy.env.scratchWorkspace = os.path.join(arcpy.env.workspace,scratchWorkspace)
# check if the scratch geodatabase exists
if arcpy.Exists(arcpy.env.scratchWorkspace):
    # if it exists, delete it
    arcpy.Delete_management(arcpy.env.scratchWorkspace)
    print("Geodatabase deleted.")
else:
    # if it doesn't exist, print a message
    print("Geodatabase does not exist.")

arcpy.management.CreateFileGDB(arcpy.env.workspace, scratchWorkspace)

HabitatCondition_gdb = r"BigThicket_Condition.gdb"
arcpy.env.overwriteOutput =  True

# Input Variables
hexgrid = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BigThicket_Condition.gdb\GenerateTessellation"
combined_EVT_tif = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BigThicket_Condition.gdb\NVCgroups"
hexclip = r"S:\Projects\USFWS\SE_FWS_Habitat_2022\FWS_HabConScriptTesting\FWS_HabConScriptTesting.gdb\hexclip"                             
dataLCM = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BigThicket_Condition.gdb\LCM_clip_resample" #this version of the LCM has been clipped to BITH buffered boundary and resampled to 30m
dataRuderal = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BigThicket_Condition.gdb\Ruderal5cell"
dataFireDep = r"S:\Data\External\LANDFIRE_Fire_Departure\LF2020_VDep_220_CONUS\LF2020_VDep_220_CONUS\Tif\LC20_VDep_220.tif"

##------------------Prepare IVC raster input-----------------------
#outExtractByMask = ExtractByMask(combined_EVT_tif, hexclip)  # THIS WILL LIKELY HAVE TO BE MODIFED FOR THE FULL SCRIPT!!!!
outExtractByMask1 = ExtractByAttributes(combined_EVT_tif, '"BITH_flg" <> 0') 
outExtractByMask1.save("BITH_IVC_clip.tif")

#Reclassify the different pine IVC groups
##in_raster = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_clip.tif"
##BITH_IVC_Reclass = arcpy.sa.Reclassify(in_raster, "IVC_ELCODE", "G009 9;G013 13;G190 190;G130 130", "DATA");
##BITH_IVC_Reclass.save(r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_Reclass.tif")
##print("IVC raster ready for analysis")

# The below block of code takes all pine habitat present in BITH and combines it to get a pine landscape condition assessment
in_raster = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_clip.tif"
BITH_IVC_Reclass = arcpy.sa.Reclassify(in_raster, "IVC_ELCODE", "G009 1;G013 1;G190 1;G130 1", "DATA");
BITH_IVC_Reclass.save(r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_ReclassBinary.tif")
print("IVC raster ready for analysis")

# Create a list of NVC groups to perform analysis on
value_list = [] 
value_file = open(r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\Hannah\merged.txt") #list of values - EVT codes of NVC groups of interest
for word in value_file:
    word = word.rstrip("\n") # this removes the spaces after each word
    value_list.append(word)
print("NVC list created")

## -----------------Perform Landscape Condition Assessment ----------------------  
print("Creating condition datasets for " + str(len(value_list)) + " ecological systems.")
print("===============================================================================")

for value in value_list:        
    # Process: Extract by Attributes - extract individual IVC groups 
    print("- working on extracting the IVC groups")
    nameIVC = "tmp_Extract_" + str(value) + ".tif"
    w_clause = "Value = " + value
    tmp_Extract_Value_tif = ExtractByAttributes(BITH_IVC_Reclass, where_clause=w_clause)
    tmp_Extract_Value_tif.save(os.path.join(arcpy.env.workspace, nameIVC))

    # Select out the hexagons that overlap the EVT cells
    print("- intersecting the IVC layer with the hex grid")
    tmp_Value_raster2pt = fr"tmp_{value}_raster2pt"
    arcpy.conversion.RasterToPoint(in_raster=tmp_Extract_Value_tif, out_point_features=tmp_Value_raster2pt, raster_field="VALUE")    
    hexgridselection = arcpy.management.SelectLayerByLocation(in_layer=[hexgrid], overlap_type="INTERSECT", select_features=tmp_Value_raster2pt, search_distance="", selection_type="NEW_SELECTION", invert_spatial_relationship="NOT_INVERT")
    hexgridselection = arcpy.conversion.FeatureClassToFeatureClass(in_features=hexgridselection, out_path=os.path.join(arcpy.env.workspace,HabitatCondition_gdb), out_name=f"hex100ac_{value}", where_clause="")

    arcpy.management.CalculateField(in_table=hexgridselection, field="IVCcode", expression=value, field_type="TEXT")

    # Work on Zonal Statistics for LCM
    print("- calculating and summarizing the LCM values")
    tmp_Value_LCM_tif = fr"tmp_{value}_LCM.tif"
    tmp_Value_LCM_tif = arcpy.sa.ExtractByMask(in_raster=dataLCM, in_mask_data=nameIVC)
    ZonalSt_Value_LCM = fr"ZonalSt_{value}_LCM"
    arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hexgridselection, zone_field="GRID_ID", in_value_raster=tmp_Value_LCM_tif,
                                    out_table=ZonalSt_Value_LCM, ignore_nodata="DATA", statistics_type="MEAN")
    arcpy.management.JoinField(in_data=hexgridselection, in_field="GRID_ID", join_table=ZonalSt_Value_LCM, join_field="GRID_ID", fields=["MEAN"])[0]
    arcpy.management.CalculateField(in_table=hexgridselection, field="scoreLCM", expression="round(!MEAN!,1)", field_type="DOUBLE")
    arcpy.management.DeleteField(hexgridselection, "MEAN")
    arcpy.management.AlterField(hexgridselection, "scoreLCM", "scoreLCM", "LCM Score")
    # The below code was added as a bandaid to fix an issue where pixels falling on the edge of hexes in the resampled LCM raster are populating the hex
    # as null. The following code changes those hexes from null to zero - not entirely accurate since the LCM value is not zero
    with arcpy.da.UpdateCursor(hexgridselection, "scoreLCM") as cursor:
        for row in cursor:
            for  i in range(len(row)):
                if row[i] is None:
                    row[i] = 0
            cursor.updateRow(row)
            
    # Work on Invasive Risk score
    print("- calculating the invasive risk score")
    tmp_InvRisk_tif = fr"tmp_{value}_Inv.tif"
    tmp_InvRisk_tif = arcpy.sa.ExtractByMask(in_raster=dataRuderal, in_mask_data=nameIVC)
    ZonalSt_Value_InvRisk = fr"ZonalSt_{value}_InvRisk"
    arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hexgridselection, zone_field="GRID_ID", in_value_raster=tmp_InvRisk_tif,
                                    out_table=ZonalSt_Value_InvRisk, ignore_nodata="DATA", statistics_type="MEAN")
    arcpy.management.JoinField(in_data=hexgridselection, in_field="GRID_ID", join_table=ZonalSt_Value_InvRisk, join_field="GRID_ID", fields=["MEAN"])[0]
    arcpy.management.CalculateField(in_table=hexgridselection, field="scoreInv", expression="round(!MEAN!,1)", field_type="DOUBLE")
    arcpy.management.DeleteField(hexgridselection, "MEAN")
    arcpy.management.AlterField(hexgridselection, "scoreInv", "scoreInv", "Invasive Score") 

    # calculating the mean condition/quality score
    arcpy.management.CalculateField(in_table=hexgridselection, field="scoreInvR", expression="Abs($feature.scoreInv-100)", expression_type="ARCADE", code_block="", field_type="DOUBLE", enforce_domains="NO_ENFORCE_DOMAINS")
    arcpy.management.CalculateField(in_table=hexgridselection, field="meanCond", expression="(!scoreLCM!+!scoreInvR!)/2", expression_type="PYTHON3", code_block="", field_type="DOUBLE", enforce_domains="NO_ENFORCE_DOMAINS")
    arcpy.management.AlterField(hexgridselection, "meanCond", "meanCond", "Mean Condition")
    
    # Work on fire departure score
    print("- calculating the fire departure score")
    tmp_FireDep_tif = fr"tmp_{value}_Inv.tif"
    tmp_FireDep_tif = arcpy.sa.ExtractByMask(in_raster=dataFireDep, in_mask_data=nameIVC)
    ZonalSt_Value_FireDep = fr"ZonalSt_{value}_InvRisk"
    arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hexgridselection, zone_field="GRID_ID", in_value_raster=tmp_FireDep_tif,
                                    out_table=ZonalSt_Value_FireDep, ignore_nodata="DATA", statistics_type="MEAN")
    arcpy.management.JoinField(in_data=hexgridselection, in_field="GRID_ID", join_table=ZonalSt_Value_FireDep, join_field="GRID_ID", fields=["MEAN"])[0]
    arcpy.management.CalculateField(in_table=hexgridselection, field="scoreFire", expression="round(!MEAN!,1)", field_type="DOUBLE")
    arcpy.management.DeleteField(hexgridselection, "MEAN")
    arcpy.management.AlterField(hexgridselection, "scoreFire", "scoreFire", "Fire Departure Score")

    # clean up
    print("- Cleaning up the crumbs")
    arcpy.management.Delete(in_data=[tmp_Value_raster2pt])

