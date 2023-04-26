library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- read.csv("S:/Projects/NPCA/Workspace/Hannah_Hyatt/SpeciesSummaries/Int_ModelsTbls_AviKwaAme/MoBIshms_TabAreaMerge_AviKwaAme.csv") # UPDATE Input Tabulate Area table - Managed Lands or GAP status focused
#inputTabAreaGAP <- arc.open(inputTabAreaGAP)
#inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

StudyAreasFC <- "S:/Projects/NPCA/Data/Final/StudyAreas_fin.gdb/NPCA_StudyAreas_CONUS"
StudyAreasFC <- arc.open(StudyAreasFC)
StudyAreasFC <- arc.select(StudyAreasFC)
StudyAreasFC <- as.data.frame(StudyAreasFC)

cutecodes <- read.csv("S:/Projects/_Workspaces/Hannah_Hyatt/MoBI_Gov_Relations/SpeciesLists/CuteCodeCrosswalk.csv")
cutecodes$cutecode <- paste0(cutecodes$ï..cutecode)

inputTabAreaGAP$OBJECTID <- NULL

## split out study area
inputTabAreaGAP$StudyArea <- "NA"
inputTabAreaGAP$StudyArea <- gsub("\\(([^()]+)\\)", "\\1",str_extract(inputTabAreaGAP$NPCA_STATU, "\\(([^()]+)\\)"))

## split out protected unprotected
inputTabAreaGAP$Protected <- "NA"
inputTabAreaGAP$Protected <- gsub("^(.*?),.*", "\\1", inputTabAreaGAP$NPCA_STATU)

## split out GAP status
inputTabAreaGAP$GAPstatus <- "NA"
inputTabAreaGAP$GAPstatus <- sub("\\(.*", "", inputTabAreaGAP$NPCA_STATU)
inputTabAreaGAP$GAPstatus_fin <- sub(".*GAP", "", inputTabAreaGAP$GAPstatus)
inputTabAreaGAP$GAPstatus_fin <- gsub("(.*),.*", "\\1",inputTabAreaGAP$GAPstatus_fin)

## load in unique lists
#lstSpecies <- unique(inputTabAreaGAP$Scientific)
lstSpecies <- unique(inputTabAreaGAP[which(inputTabAreaGAP$Highlight=="Yes"),"Scientific"])
lstStudyAreas <- unique(inputTabAreaGAP$StudyArea)

## loop through species list and study areas
for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaGAP[which(inputTabAreaGAP$StudyArea==lstStudyAreas[i]),]
  
  ## Select all imperiled species
  #lstSpecies_subset <- unique(StudyArea_subset[which(StudyArea_subset$Imperiled=="Imperiled"),"Scientific"] )
  
  ## Select all species
  #lstSpecies_subset <- unique(StudyArea_subset$Scientific)
  
  ## Select a subset of the species - simplifies the bar chart output for presentation 
  lstSpecies_subset <- unique(StudyArea_subset[which(StudyArea_subset$Highlight=="Yes"),"Scientific"] )
  
  # create an empty data frame
  StudyAreaSpecies_subsetComb <- inputTabAreaGAP[0,]
  
  for(j in 1:length(lstSpecies_subset)){  #
    print(paste("working on ", lstSpecies[j], sep=""))
    StudyAreaSpecies_subset <- inputTabAreaGAP[which(inputTabAreaGAP$Scientific==lstSpecies_subset[j]),]
    StudyAreaSpecies_subset[which(StudyAreaSpecies_subset$StudyArea!=lstStudyAreas[i]),"StudyArea"] <- NA
    
    StudyAreaSpecies_subsetComb <- rbind(StudyAreaSpecies_subsetComb, StudyAreaSpecies_subset)
    
    StudyAreaSpecies_subset1 <- StudyAreaSpecies_subsetComb %>%
      group_by( StudyArea, GAPstatus_fin, Scientific,Rounded_GR,NatMon) %>% #NPCA_status_GAP_StudyArea,
      summarise(TotalArea = sum(VALUE_1)) %>% 
      ungroup()
    
    StudyAreaSpecies_subset2 <- StudyAreaSpecies_subset1 %>%
      group_by(Scientific) %>%
      mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
      mutate(TotalArea2 = if_else(is.na(StudyArea), -TotalArea, TotalArea)) %>%
      mutate(PercentArea2 = if_else(is.na(StudyArea), -PercentArea, PercentArea))
    
    StudyAreaSpecies_subset3 <- StudyAreaSpecies_subset2 %>%
      group_by(Scientific) %>%
      mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>1]))
    
    StudyAreaSpecies_subset3 <- StudyAreaSpecies_subset3[which(StudyAreaSpecies_subset3$TotalPosPercent>0),]

    StudyAreaSpecies_subset3$axislable <- paste0(StudyAreaSpecies_subset3$Scientific, " (", StudyAreaSpecies_subset3$Rounded_GR, ")") 
    StudyAreaSpecies_subset3$GAPstatus_fin <- paste0("GAP",StudyAreaSpecies_subset3$GAPstatus_fin)
    StudyAreaSpecies_subset3$GAPstatus_fin <- trimws(StudyAreaSpecies_subset3$GAPstatus_fin)
    StudyAreaSpecies_subset3$GAPstatus_fin <- factor(StudyAreaSpecies_subset3$GAPstatus_fin, levels = c("GAPUnprotected","GAP 4","GAP 3","GAP 2","GAP 1"))

    StudyAreaSpecies_subset3 %>%
      ggplot(aes(x = reorder(axislable, TotalPosPercent),
                 y = PercentArea2,
                 fill = GAPstatus_fin)) +
      geom_col() +
      coord_flip() +
      geom_abline(slope=0, intercept=0.0,  col = "white") +
      #ggtitle(paste(lstStudyAreas[i],"Study Area")) +
      ylab("Outside Study Area                                                             Inside Study Area") +
      scale_y_continuous(limits = c(-100, 100), breaks=c(-100,-75,-50,-25, 0, 25,50,75,100), labels=c("100%","75%","50%","25%", "0%", "25%","50%","75%","100%")) +
      scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"), guide = guide_legend(reverse = TRUE)) +
      theme_minimal() +
      theme(panel.grid = element_blank(),legend.position = "none")
  }
}
# write out the dataframe behind this chart as a csv
write.csv(StudyAreaSpecies_subset3, "S:/Projects/NPCA/Workspace/Hannah_Hyatt/SpeciesSummaries/AKA_SpeciesDonutCharts/AKA_EndSps_CurrentProtection.csv")