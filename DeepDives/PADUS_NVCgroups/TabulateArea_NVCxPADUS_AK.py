# IUCN analysis for study areas
# Before this script:
# flattened PADUS layer was unioned to Study Areas which were unioned to CONUS (CONUS_AnalysisLayer below)
# Flags for inside/outside of study areas (field = "StudyArea"), managed/unmanaged lands (field = "managed"), protected/unprotected lands(field = "prot")
# merged flags with GAP status or Manager Name and name of study areas in format fitting for R code (location of R code here)

# Details on script below:
# Tabulate area for the field which outlines if the lands are protected, what status of protection they hold, and if it falls inside or outside of study areas.
# Tabulate area for the field which outlinse if the lands are managed, who is the land manager (Manager Name), and if it falls inside or outisde of study areas.

# Outputs:
# to be used in R code which creates bar chart visual of the above.

import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')
arcpy.env.overwriteOutput = True

##set variables
AK_AnalysisLayer = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\PADUS_AK_StudyAreas_union_AnalysisLayer"
NVCgroups_AK = r"S:\Data\NatureServe\Ecosystem_Terrestrial\LANDFIRE\Alaska\LF2020_EVT_220_AK\Tif\LA20_EVT_220_IVC_join_Jan2023.tif"
TabAreaGAP_out = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\TabArea_NVCgrps_GAPsts_AK"
TabAreaMang_out = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\TabArea_NVCgrps_Mangsts_AK"
print ("variables set")

## Tabulate area of NVC groups found within and outside of protected lands within and outside of study areas
print("1 - Working on Tabulate area for Protected Areas")
arcpy.sa.TabulateArea(AK_AnalysisLayer, "NPCA_Status_GAP_StudyArea", NVCgroups_AK, "IVC_NAME", TabAreaGAP_out, NVCgroups_AK, "CLASSES_AS_ROWS")

## Tabulate Area of NVC groups found within/outside managed lands and within/outside of study areas
print("1 - Working on Tabulate area for management status")
arcpy.sa.TabulateArea(AK_AnalysisLayer, "NPCA_Status_Mang_StudyArea", NVCgroups_AK, "IVC_NAME", TabAreaMang_out, NVCgroups_AK, "CLASSES_AS_ROWS")

print ("Complete")
