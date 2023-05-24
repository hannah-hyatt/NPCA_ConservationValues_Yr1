## Landscape Condition Assessment: to understand the condition of IVC groups, examining the Landscape Condition Model
## and the invasive score of a spatial defined area. Also returns the fire departure mean score as additional information, this
## variable however is not used in calculating the Mean Condition.
##
## New Methods for River landscapes:
##  * Clipped HUC12 polygons to the river landscape
## LANDSCAPE CONDITION MODEL RASTER PREP:
## 1.) Extract by mask to get LCM in the hucgrid
## 2.) Resampled extracted LCM to 30m
## RUDERAL RASTER PREP:
## 1.) Extract by mask: NVC raster to hexgrid/study area
## 2.) Extract by attribute: IVC_NAME LIKE %Ruderal%
## 3.) Reclassify: IVC_ELCODE = 1, everything else nodata
## 4.) Focal Stats: neighborhood = Circle 5 CELL, stat type = mean, ignore nodata checked
## 5.) Times: Multiply focal stats raster by 100
##
## Adding in Land Cover Vulnerability Change
## 1.) Mask LCVC layer to study area
## 2.) Multiply Vulnerability score by 100
## Note: Ruderal raster will be inverted during this script to match the same concept as LCM mean
##
## Original script written by Chris Tracey can be found here: S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\condition - Backup.py
## Script edited for NPCA project by Hannah Ceasar 4/24

import arcpy, os, re
from arcpy.sa import *
import datetime

# Check out any necessary licenses.
arcpy.CheckOutExtension("spatial")

scratchWorkspace = r"landscapecondition_ScratchWorkspace.gdb"

#print start time
now = datetime.datetime.now()
print("Start time: ", now.time())

# set up environments
arcpy.env.workspace = r"S:\Projects\NPCA\Data\Intermediate"
arcpy.env.scratchWorkspace = os.path.join(arcpy.env.workspace,scratchWorkspace)

HabitatCondition_gdb = r"LandscapeConditionAssessment.gdb"
arcpy.env.overwriteOutput =  True

# Input Variables
hucgrid = r"S:\Projects\NPCA\Data\Intermediate\DelawareRiverLandscapeDeepDive.gdb\HUC12_DEriver"
#combined_EVT_tif = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BigThicket_Condition.gdb\NVCgroups"
#hexclip = r"S:\Projects\USFWS\SE_FWS_Habitat_2022\FWS_HabConScriptTesting\FWS_HabConScriptTesting.gdb\hexclip"                             
dataLCM = r"S:\Projects\NPCA\Data\Intermediate\DelawareRiverLandscapeDeepDive.gdb\LCM_maskDEriver_resample" #this version of the LCM has been clipped to BITH buffered boundary and resampled to 30m
dataRuderal = r"S:\Projects\NPCA\Data\Intermediate\DelawareRiverLandscapeDeepDive.gdb\DEriver_Ruderal5Cell" # UPDATE
dataFireDep = r"S:\Data\External\LANDFIRE_Fire_Departure\LF2020_VDep_220_CONUS\LF2020_VDep_220_CONUS\Tif\LC20_VDep_220.tif"
dataLCVC = r"S:\Projects\NPCA\Data\Intermediate\DelawareRiverLandscapeDeepDive.gdb\LCVC_lookup"

##------------------Prepare IVC raster input-----------------------
#outExtractByMask = ExtractByMask(combined_EVT_tif, hexclip)  # THIS WILL LIKELY HAVE TO BE MODIFED FOR THE FULL SCRIPT!!!!
##outExtractByMask1 = ExtractByAttributes(combined_EVT_tif, '"BITH_flg" <> 0') 
##outExtractByMask1.save("BITH_IVC_clip.tif")

#Reclassify the different pine IVC groups
##in_raster = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_clip.tif"
##BITH_IVC_Reclass = arcpy.sa.Reclassify(in_raster, "IVC_ELCODE", "G009 9;G013 13;G190 190;G130 130", "DATA");
##BITH_IVC_Reclass.save(r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_Reclass.tif")
##print("IVC raster ready for analysis")

# The below block of code takes all pine habitat present in BITH and combines it to get a pine landscape condition assessment
##in_raster = r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_clip.tif"
##BITH_IVC_Reclass = arcpy.sa.Reclassify(in_raster, "IVC_ELCODE", "G009 1;G013 1;G190 1;G130 1", "DATA");
##BITH_IVC_Reclass.save(r"S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\BITH_IVC_ReclassBinary.tif")
##print("IVC raster ready for analysis")

 -----------------Perform Landscape Condition Assessment ----------------------  
print("Creating condition datasets for Mojave Mid-Elevation NVC group.")
print("===============================================================================")

# Work on Zonal Statistics for LCM
print("1 - calculating and summarizing the LCM values")
ZonalSt_Value_LCM = fr"ZonalSt_DEriver_LCM"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hucgrid, zone_field="HUC12", in_value_raster=dataLCM,
                                out_table=ZonalSt_Value_LCM, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hucgrid, in_field="HUC12", join_table=ZonalSt_Value_LCM, join_field="HUC12", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hucgrid, field="scoreLCM", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hucgrid, "MEAN")
arcpy.management.AlterField(hucgrid, "scoreLCM", "scoreLCM", "LCM Score")
# The below code was added as a bandaid to fix an issue where pixels falling on the edge of hexes in the resampled LCM raster are populating the hex
# as null. The following code changes those hexes from null to zero - not entirely accurate since the LCM value is not zero
with arcpy.da.UpdateCursor(hucgrid, "scoreLCM") as cursor:
    for row in cursor:
        for  i in range(len(row)):
            if row[i] is None:
                row[i] = 0
        cursor.updateRow(row)
        
# Work on Invasive Risk score
# Likely will need to reclass the extracted output to be binary for this next step to work...
print("2 - calculating the invasive risk score")
ZonalSt_Value_InvRisk = fr"ZonalSt_DEriver_InvRisk"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hucgrid, zone_field="HUC12", in_value_raster=dataRuderal,
                                out_table=ZonalSt_Value_InvRisk, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hucgrid, in_field="HUC12", join_table=ZonalSt_Value_InvRisk, join_field="HUC12", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hucgrid, field="scoreInv", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hucgrid, "MEAN")
arcpy.management.AlterField(hucgrid, "scoreInv", "scoreInv", "Invasive Score") 

# calculating the mean condition/quality score
arcpy.management.CalculateField(in_table=hucgrid, field="scoreInvR", expression="Abs($feature.scoreInv-100)", expression_type="ARCADE", code_block="", field_type="DOUBLE", enforce_domains="NO_ENFORCE_DOMAINS")
arcpy.management.CalculateField(in_table=hucgrid, field="meanCond", expression="(!scoreLCM!+!scoreInvR!)/2", expression_type="PYTHON3", code_block="", field_type="DOUBLE", enforce_domains="NO_ENFORCE_DOMAINS")
arcpy.management.AlterField(hucgrid, "meanCond", "meanCond", "Mean Condition")

# Work on fire departure score
print("3 - calculating the fire departure score")
tmp_FireDep_tif = fr"tmp_DEriver_Inv.tif"
tmp_FireDep_tif = arcpy.sa.ExtractByMask(in_raster=dataFireDep, in_mask_data=hucgrid)
ZonalSt_Value_FireDep = fr"ZonalSt_DEriver_InvRisk"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hucgrid, zone_field="HUC12", in_value_raster=tmp_FireDep_tif,
                                out_table=ZonalSt_Value_FireDep, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hucgrid, in_field="HUC12", join_table=ZonalSt_Value_FireDep, join_field="HUC12", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hucgrid, field="scoreFire", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hucgrid, "MEAN")
arcpy.management.AlterField(hucgrid, "scoreFire", "scoreFire", "Fire Departure Score")

# Add in LCVC
print("4 - Calculating the Land Cover Vulnerability Change")
ZonalSt_Value_LCVC = fr"ZonalSt_DEriver_LCVC"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hucgrid, zone_field="HUC12", in_value_raster=dataLCVC,
                                out_table=ZonalSt_Value_LCVC, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hucgrid, in_field="HUC12", join_table=ZonalSt_Value_LCVC, join_field="HUC12", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hucgrid, field="scoreLCVC", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hucgrid, "MEAN")
arcpy.management.AlterField(hucgrid, "scoreLCVC", "scoreLCVC", "LCVC Score")

print("End time: ", now.time())
