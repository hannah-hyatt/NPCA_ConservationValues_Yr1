## Landscape Condition Assessment: to understand the condition of IVC groups, examining the Landscape Condition Model
## and the invasive score of a spatial defined area. Also returns the fire departure mean score as additional information, this
## variable however is not used in calculating the Mean Condition.
##
## Before running this script:
##  * Created an area of interest Tesselation (100acre hexagons) based on the Mojave Mid-Elevation NVC group
##    clipped to include the AviKwaAme protected corridor polygon, and then some (to include more habitat).
##  * Extract by mask: NVC raster to the tesselation
##  * Extract by Attribute: tesssalated NVC raster to return Mojave mid-elevation group
##  * Raster to point: Mojave Mid El NVC raster
##  * Select by location: Tesselation selected where Mojave Mid El point layer present, saved this as tesselation used for analysis
##    Will be referred to as "hexgrid"
##  LANDSCAPE CONDITION MODEL RASTER PREP
##  1.) Extract by mask to get LCM in the hexgrid
##  2.) Resampled extracted LCM to 30m
##  RUDERAL RASTER PREP
##  1.) Extract by mask: NVC raster to hexgrid
##  2.) Extract by attribute: IVC_NAME LIKE %Ruderal%
##  3.) Reclassify: IVC_ELCODE = 1, everything else nodata
##  4.) Focal Stats: neighborhood = Circle 5 CELL, stat type = mean, ignore nodata checked
##  5.) Times: multiply focal stats raster by 100
##  NOTE: Ruderal raster will be inverted during this script to match the same concept as LCM mean
##  
## 2. Added BITH_flg (0/1 field) to return only IVC groups of interest
## 3. Created text field listing IVC_ELCODE values for each IVC group of interest. This code list was edited to
##    only be values (ex. G009 becomes 9)
##
## Original script written by Chris Tracey can be found here: S:\Projects\NPCA\Pro\Draft\BigThicket_Condition\condition - Backup.py
## Script edited for NPCA project by Hannah Ceasar 4/26

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
hexgrid = r"S:\Projects\NPCA\Data\Intermediate\LandscapeConditionAssessment.gdb\MojaveMidEl_Tesselation_1"
MojaveDesert = r"S:\Projects\NPCA\Data\Intermediate\AviKwaAme\LandscapeAssessment\INT_mojavemidel_forTessellation_v2.tif"
dataLCM = r"S:\Projects\NPCA\Data\Intermediate\LandscapeConditionAssessment.gdb\LCM_MojaveMidEl_resample" #this version of the LCM has been masked to hexgrid boundary and resampled to 30m
dataRuderal = r"S:\Projects\NPCA\Data\Intermediate\LandscapeConditionAssessment.gdb\Ruderal_MojaveMidEl_5cell" #this layer was created in pro before running script: extracted all IVC groups with "Ruderal" in the name within hexgrid, then made a binary raster on IVC_ELCODE
dataFireDep = r"S:\Data\External\LANDFIRE_Fire_Departure\LF2020_VDep_220_CONUS\LF2020_VDep_220_CONUS\Tif\LC20_VDep_220.tif"
dataNVC = r"S:\Data\NatureServe\Ecosystem_Terrestrial\LANDFIRE\CONUS_EVT_NVC_2020\EVT\Landfire_EVT_2020_IVC_join_2023.tif"

## -----------------Perform Landscape Condition Assessment ----------------------  
print("Creating condition datasets for Mojave Mid-Elevation NVC group.")
print("===============================================================================")

# Work on Zonal Statistics for LCM
print("1 - calculating and summarizing the LCM values")
ZonalSt_Value_LCM = fr"ZonalSt_MojaveDesert_LCM"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hexgrid, zone_field="GRID_ID", in_value_raster=dataLCM,
                                out_table=ZonalSt_Value_LCM, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hexgrid, in_field="GRID_ID", join_table=ZonalSt_Value_LCM, join_field="GRID_ID", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hexgrid, field="scoreLCM", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hexgrid, "MEAN")
arcpy.management.AlterField(hexgrid, "scoreLCM", "scoreLCM", "LCM Score")
# The below code was added as a bandaid to fix an issue where pixels falling on the edge of hexes in the resampled LCM raster are populating the hex
# as null. The following code changes those hexes from null to zero - not entirely accurate since the LCM value is not zero
with arcpy.da.UpdateCursor(hexgrid, "scoreLCM") as cursor:
    for row in cursor:
        for  i in range(len(row)):
            if row[i] is None:
                row[i] = 0
        cursor.updateRow(row)
        
# Work on Invasive Risk score
# Likely will need to reclass the extracted output to be binary for this next step to work...
print("2 - calculating the invasive risk score")
ZonalSt_Value_InvRisk = fr"ZonalSt_MojaveDesert_InvRisk"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hexgrid, zone_field="GRID_ID", in_value_raster=dataRuderal,
                                out_table=ZonalSt_Value_InvRisk, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hexgrid, in_field="GRID_ID", join_table=ZonalSt_Value_InvRisk, join_field="GRID_ID", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hexgrid, field="scoreInv", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hexgrid, "MEAN")
arcpy.management.AlterField(hexgrid, "scoreInv", "scoreInv", "Invasive Score") 

# calculating the mean condition/quality score
arcpy.management.CalculateField(in_table=hexgrid, field="scoreInvR", expression="Abs($feature.scoreInv-100)", expression_type="ARCADE", code_block="", field_type="DOUBLE", enforce_domains="NO_ENFORCE_DOMAINS")
arcpy.management.CalculateField(in_table=hexgrid, field="meanCond", expression="(!scoreLCM!+!scoreInvR!)/2", expression_type="PYTHON3", code_block="", field_type="DOUBLE", enforce_domains="NO_ENFORCE_DOMAINS")
arcpy.management.AlterField(hexgrid, "meanCond", "meanCond", "Mean Condition")

# Work on fire departure score
print("3 - calculating the fire departure score")
tmp_FireDep_tif = fr"tmp_MojaveDesert_Inv.tif"
tmp_FireDep_tif = arcpy.sa.ExtractByMask(in_raster=dataFireDep, in_mask_data=hexgrid)
ZonalSt_Value_FireDep = fr"ZonalSt_MojaveDesert_InvRisk"
arcpy.sa.ZonalStatisticsAsTable(in_zone_data=hexgrid, zone_field="GRID_ID", in_value_raster=tmp_FireDep_tif,
                                out_table=ZonalSt_Value_FireDep, ignore_nodata="DATA", statistics_type="MEAN")
arcpy.management.JoinField(in_data=hexgrid, in_field="GRID_ID", join_table=ZonalSt_Value_FireDep, join_field="GRID_ID", fields=["MEAN"])[0]
arcpy.management.CalculateField(in_table=hexgrid, field="scoreFire", expression="round(!MEAN!,1)", field_type="DOUBLE")
arcpy.management.DeleteField(hexgrid, "MEAN")
arcpy.management.AlterField(hexgrid, "scoreFire", "scoreFire", "Fire Departure Score")

print("End time: ", now.time())
