library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/AviKwaAmeDeepDive.gdb/MoBIshms_TabAreaMerge_AKAcorridor" # UPDATE Input Tabulate Area table - Managed Lands or GAP status focused
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

StudyAreasFC <- "S:/Projects/NPCA/Data/Final/StudyAreas_fin.gdb/NPCA_StudyAreas_CONUS"
StudyAreasFC <- arc.open(StudyAreasFC)
StudyAreasFC <- arc.select(StudyAreasFC)
StudyAreasFC <- as.data.frame(StudyAreasFC)

cutecodes <- read.csv("S:/Projects/_Workspaces/Hannah_Hyatt/MoBI_Gov_Relations/SpeciesLists/CuteCodeCrosswalk.csv")
cutecodes$cutecode <- paste0(cutecodes$ï..cutecode)

inputTabAreaGAP$OBJECTID <- NULL

## split out study area
inputTabAreaGAP$Corridor <- "NA"
inputTabAreaGAP$Corridor <- gsub('.*,\\s*', '', inputTabAreaGAP$CORRIDOR_A)
inputTabAreaGAP$Corridor <- gsub("(^[^-]+)-.*", "\\1", inputTabAreaGAP$Corridor)

## split out protected unprotected
inputTabAreaGAP$Protected <- "NA"
inputTabAreaGAP$Protected <- gsub("^(.*?),.*", "\\1", inputTabAreaGAP$CORRIDOR_A)

## split out GAP status
inputTabAreaGAP$GAPstatus <- "NA"
inputTabAreaGAP$GAPstatus <- sub("\\(.*", "", inputTabAreaGAP$CORRIDOR_A)
inputTabAreaGAP$GAPstatus_fin <- sub(".*GAP", "", inputTabAreaGAP$GAPstatus)
inputTabAreaGAP$GAPstatus_fin <- gsub("(.*),.*", "\\1",inputTabAreaGAP$GAPstatus_fin)

## load in unique lists
lstSpecies <- unique(inputTabAreaGAP$Scientific)

Species_subset1 <- inputTabAreaGAP %>%
  group_by( GAPstatus_fin, Scientific,Rounded_GR,CORRIDOR) %>% #NPCA_status_GAP_StudyArea,
  summarise(TotalArea = sum(VALUE_1)) %>% 
  ungroup()

Species_subset2 <- Species_subset1 %>%
  group_by(Scientific) %>%
  mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
  mutate(TotalArea2 = if_else(is.na(CORRIDOR), -TotalArea, TotalArea)) %>%
  mutate(PercentArea2 = if_else(is.na(CORRIDOR), -PercentArea, PercentArea))

Species_subset3 <- Species_subset2 %>%
  group_by(Scientific) %>%
  mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>1]))

Species_subset3 <- Species_subset3[which(Species_subset3$TotalPosPercent>40),]

Species_subset3$axislable <- paste0(Species_subset3$Scientific, " (", Species_subset3$Rounded_GR, ")") 
Species_subset3$GAPstatus_fin <- paste0("GAP",Species_subset3$GAPstatus_fin)
Species_subset3$GAPstatus_fin <- trimws(Species_subset3$GAPstatus_fin)
Species_subset3$GAPstatus_fin <- factor(Species_subset3$GAPstatus_fin, levels = c("GAPUnprotected","GAP 4","GAP 3","GAP 2","GAP 1"))

Species_subset3 %>%
  ggplot(aes(x = reorder(axislable, TotalPosPercent),
             y = PercentArea2,
             fill = GAPstatus_fin)) +
  geom_col() +
  coord_flip() +
  geom_abline(slope=0, intercept=0.0,  col = "white") +
  #ggtitle(paste(lstStudyAreas[i],"Study Area")) +
  ylab("Outside Protected Corridor                                                       Inside Protected Corridor") +
  scale_y_continuous(limits = c(-100, 100), breaks=c(-100,-75,-50,-25, 0, 25,50,75,100), labels=c("100%","75%","50%","25%", "0%", "25%","50%","75%","100%")) +
  scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"), guide = guide_legend(reverse = TRUE)) +
  theme_minimal() +
  theme(panel.grid = element_blank(),legend.position = "none")
