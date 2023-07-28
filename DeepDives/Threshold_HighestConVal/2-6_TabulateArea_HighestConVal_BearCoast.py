# Before this script:
# flattened PADUS layer was unioned to Study Areas which were unioned to CONUS (CONUS_AnalysisLayer below)
# Flags for inside/outside of study areas (field = "StudyArea"), managed/unmanaged lands (field = "managed"), protected/unprotected lands(field = "prot")
# merged flags with GAP status or Manager Name and name of study areas in format fitting for R code (location of R code here)

# Before this script pt 2:
# calculated the top 10% quantile of the conservation value in DE River System study area (conservation value = 13)
# created a binary raster of that value inside GA River System study area

# Details on script below:
# Tabulate area for the field which outlines if the lands are protected, what status of protection they hold, and if it falls inside or outside of study areas.
# Tabulate area for the field which outlinse if the lands are managed, who is the land manager (Manager Name), and if it falls inside or outisde of study areas.

# Outputs:
# to be used in R code which creates donut charts showing the protection status managers of the areas of highest conservation value inside of DE River System Study area

import arcpy, os
from arcpy import env
from arcpy.sa import *
from datetime import datetime
arcpy.CheckOutExtension('Spatial')
arcpy.env.overwriteOutput = True

#set variables
SA_AnalysisLayer = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\PADUS_AK_StudyAreas_union_AnalysisLayer"
SA_ConVal = r"S:\Projects\NPCA\Data\Intermediate\ConservationValue\ConVal_BearCoast.tif"
IUCN_CONUS = r"S:\Projects\_Workspaces\Hannah_Hyatt\ForestEndowment\Data\Intermediate.gdb\IUCNecosystems_CONUS"
TabAreaGAP_out = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\TabArea_SAconval_GAPstatus"
TabAreaMang_out = r"S:\Projects\NPCA\Data\Intermediate\BearCoastDeepDive.gdb\TabArea_SAconval_ManagedLands"
print ("variables set")

## Tabulate Area of PADUS managers within all study areas
arcpy.sa.TabulateArea(SA_AnalysisLayer, "Mang_NS", SA_ConVal, "StudyArea", TabAreaMang_out, IUCN_CONUS, "CLASSES_AS_ROWS")
print ("tabulate area managed lands inside areas of highest conservation value in DE River System complete")

## Tabulate Area of PADUS GAP lands within all study areas
arcpy.sa.TabulateArea(SA_AnalysisLayer, "GAP_Sts", SA_ConVal, "StudyArea", TabAreaGAP_out, IUCN_CONUS, "CLASSES_AS_ROWS")
print ("tabulate area GAP status inside areas of highest conservation value in DE River System complete")

print ("Complete")
