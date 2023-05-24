## This is the second step in the process of getting a summary chart showing endemic species 
## for a study area of interest. 
## PRE PROCESSING: export the dbf output from python script as a csv to be an input here (inputTabAreaGAP/inputTabAreaMang)

library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/Species_Summaries.gdb/MoBIshms_TabAreaMerge_GAriverV2" # UPDATE Input Tabulate Area table - Managed Lands or GAP status focused
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

StudyAreasFC <- "S:/Projects/NPCA/Data/Final/StudyAreas_fin.gdb/NPCA_StudyAreas_V2"
StudyAreasFC <- arc.open(StudyAreasFC)
StudyAreasFC <- arc.select(StudyAreasFC)
StudyAreasFC <- as.data.frame(StudyAreasFC)

CutecodeCrosswalk <- read.csv("S:/Projects/_Workspaces/Hannah_Hyatt/MoBI_Gov_Relations/SpeciesLists/CuteCodeCrosswalk.csv")
CutecodeCrosswalk <- as.data.frame(CutecodeCrosswalk)
CutecodeCrosswalk$cutecode <- paste(CutecodeCrosswalk$ï..cutecode)

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

## Join species information
inputTabAreaGAP <- merge(inputTabAreaGAP, CutecodeCrosswalk, by="cutecode")

## load in unique lists
lstSpecies <- unique(inputTabAreaGAP$Scientific_Name)
#lstSpecies <- unique(inputTabAreaGAP[which(inputTabAreaGAP$Highlight_sps=="TRUE"),"Scientific_Name"])
lstStudyAreas <- unique(inputTabAreaGAP$StudyArea)

## loop through species list and study areas
for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaGAP[which(inputTabAreaGAP$StudyArea==lstStudyAreas[i]),]
  
  ## Select all imperiled species
  #lstSpecies_subset <- unique(StudyArea_subset[which(StudyArea_subset$Imperiled=="Imperiled"),"Scientific"] )
  
  ## Select all species in study area if not a lot of imperiled endemics present
  lstSpecies_subset <- unique(StudyArea_subset$Scientific_Name)
  
  ## Select a subset of the species - simplifies the bar chart output for presentation 
  #lstSpecies_subset <- unique(StudyArea_subset[which(StudyArea_subset$Highlight_sps=="TRUE"),"Scientific"] )
  
  # create an empty data frame
  StudyAreaSpecies_subsetComb <- inputTabAreaGAP[0,]
  
  for(j in 1:length(lstSpecies_subset)){  #
    print(paste("working on ", lstSpecies[j], sep=""))
    StudyAreaSpecies_subset <- inputTabAreaGAP[which(inputTabAreaGAP$Scientific_Name==lstSpecies_subset[j]),]
    StudyAreaSpecies_subset[which(StudyAreaSpecies_subset$StudyArea!=lstStudyAreas[i]),"StudyArea"] <- NA
    
    StudyAreaSpecies_subsetComb <- rbind(StudyAreaSpecies_subsetComb, StudyAreaSpecies_subset)
    
    StudyAreaSpecies_subset1 <- StudyAreaSpecies_subsetComb %>%
      group_by( StudyArea, GAPstatus_fin, Scientific_Name,Rounded_GRank) %>% #NPCA_status_GAP_StudyArea,
      summarise(TotalArea = sum(VALUE_1)) %>% 
      ungroup()
    
    StudyAreaSpecies_subset2 <- StudyAreaSpecies_subset1 %>%
      group_by(Scientific_Name) %>%
      mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
      mutate(TotalArea2 = if_else(is.na(StudyArea), -TotalArea, TotalArea)) %>%
      mutate(PercentArea2 = if_else(is.na(StudyArea), -PercentArea, PercentArea))
    
    StudyAreaSpecies_subset3 <- StudyAreaSpecies_subset2 %>%
      group_by(Scientific_Name) %>%
      mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>10]))
    
    StudyAreaSpecies_subset3 <- StudyAreaSpecies_subset3[which(StudyAreaSpecies_subset3$TotalPosPercent>0),]

    StudyAreaSpecies_subset3$axislable <- paste0(StudyAreaSpecies_subset3$Scientific_Name, " (", StudyAreaSpecies_subset3$Rounded_GRank, ")") 
    StudyAreaSpecies_subset3$GAPstatus_fin <- paste0("GAP",StudyAreaSpecies_subset3$GAPstatus_fin)
    StudyAreaSpecies_subset3$GAPstatus_fin <- trimws(StudyAreaSpecies_subset3$GAPstatus_fin)
    StudyAreaSpecies_subset3$GAPstatus_fin <- factor(StudyAreaSpecies_subset3$GAPstatus_fin, levels = c("GAPUnprotected","GAP4","GAP3","GAP2","GAP1"))
    
    StudyAreaSpecies_subset3 %>%
      ggplot(aes(x = reorder(axislable, TotalPosPercent),
                 y = PercentArea2,
                 fill = GAPstatus_fin)) +
      geom_col() +
      coord_flip() +
      geom_abline(slope=0, intercept=0.0,  col = "white") +
      ggtitle(paste(lstStudyAreas[i],"Study Area")) +
      ylab("Outside Study Area                                                             Inside Study Area") +
      scale_y_continuous(limits = c(-100, 100), breaks=c(-100,-75,-50,-25, 0, 25,50,75,100), labels=c("100%","75%","50%","25%", "0%", "25%","50%","75%","100%")) +
      scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"), guide = guide_legend(reverse = TRUE)) +
      theme_minimal() +
      theme(panel.grid = element_blank(),legend.position = "bottom")
  }
  }

## currently not summarizing endemic species by management status - might consider doing this at a later date
#------------------------------------------------------------------------------------------------------------------------
# repeat above analysis for management type

inputTabAreaManaged <- "S:/Projects/NPCA/Data/Intermediate/GAP_Analysis_Species.gdb/TabArea_SpsInsideSAs_Mang"
inputTabAreaManaged <- arc.open(inputTabAreaManaged)
inputTabAreaManaged <- arc.select(inputTabAreaManaged)
inputTabAreaManaged <- as.data.frame(inputTabAreaManaged)

StudyAreasFC <- "S:/Projects/NPCA/Data/Final/StudyAreas_fin.gdb/NPCA_StudyAreas_CONUS"
StudyAreasFC <- arc.open(StudyAreasFC)
StudyAreasFC <- arc.select(StudyAreasFC)
StudyAreasFC <- as.data.frame(StudyAreasFC)

inputTabAreaManaged$OBJECTID <- NULL

## split out study area
inputTabAreaManaged$StudyArea <- "NA"
inputTabAreaManaged$StudyArea <- gsub("\\(([^()]+)\\)", "\\1",str_extract(inputTabAreaManaged$MANG_StudyArea, "\\(([^()]+)\\)"))

## split out Manager
inputTabAreaManaged$Manager <- "NA"
inputTabAreaManaged$Manager <- sub("\\(.*", "", inputTabAreaManaged$MANG_StudyArea)
inputTabAreaManaged$Manager <- sub(".*GAP", "", inputTabAreaManaged$Manager)    

## load in unique lists
lstSpecies <- unique(inputTabAreaManaged$Scientific_Name)
lstStudyAreas <- unique(inputTabAreaManaged$StudyArea)
lstManagers <- unique(inputTabAreaManaged$Manager)

## join the area of each study area to the tab area input
#inputTabAreaManaged <- inner_join(inputTabAreaManaged, StudyAreasFC, by=c("StudyArea" = "NAME"))


for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaManaged[which(inputTabAreaManaged$StudyArea==lstStudyAreas[i]),]
  
  ## Select imperiled species
  #lstSpecies_subset <- unique(StudyArea_subset[which(StudyArea_subset$Imperiled=="Imperiled"),"Scientific_Name"] )
  
  ## Select all species in study area if not a lot of imperiled endemics present
  lstSpecies_subset <- unique(StudyArea_subset$Scientific)
  
  # create an empty data frame
  StudyAreaSpecies_subsetComb <- inputTabAreaManaged[0,]
  
  for(j in 1:length(lstSpecies_subset)){  #
    print(paste("working on ", lstSpecies_subset[j], sep=""))
    StudyAreaSpecies_subset <- inputTabAreaManaged[which(inputTabAreaManaged$Scientific_Name==lstSpecies_subset[j]),]
    StudyAreaSpecies_subset[which(StudyAreaSpecies_subset$StudyArea!=lstStudyAreas[i]),"StudyArea"] <- NA
    
    StudyAreaSpecies_subsetComb <- rbind(StudyAreaSpecies_subsetComb, StudyAreaSpecies_subset)
    
    StudyAreaSpecies_subset1 <- StudyArea_subset %>%
      group_by( StudyArea, Manager, Scientific_Name,Rounded_GRank) %>% #NPCA_status_GAP_StudyArea,
      summarise(TotalArea = sum(VALUE_1)) %>% 
      ungroup()
    StudyAreaSpecies_subset2 <- StudyAreaSpecies_subset1 %>%
      group_by(Scientific_Name) %>%
      mutate(PercentArea =   (TotalArea / SA_area_m *100) )
    
    StudyAreaSpecies_subset3 <- StudyAreaSpecies_subset2 
    StudyAreaSpecies_subset3 <- StudyAreaSpecies_subset3[which(StudyAreaSpecies_subset3$PercentArea>1),]
    
    StudyAreaSpecies_subset3$axislable <- paste0(StudyAreaSpecies_subset3$Scientific_Name, " (", StudyAreaSpecies_subset3$Rounded_GRank, ")") 
    StudyAreaSpecies_subset3$Manager <- factor(StudyAreaSpecies_subset3$Manager, levels = c(lstManagers))
    StudyAreaSpecies_subset3$Manager <- factor(StudyAreaSpecies_subset3$Manager, levels =c('Unmanaged ','UNK ','PVT ','TRIB ','STAT ','LOC ','FED ','DOE ','DOD ','NGO ','BLM ','FWS ','USFS ','NPS '))
    #StudyAreaSpecies_subset3$GAPstatus <- paste0("GAP",StudyAreaSpecies_subset3$GAPstatus_fin)
    #StudyAreaSpecies_subset3$GAPstatus[which(StudyAreaSpecies_subset3$GAPstatus=="GAPUnprotected")] <- sub(".*GAP", "", StudyAreaSpecies_subset3$GAPstatus)
    #StudyAreaSpecies_subset3$GAPstatus <- factor(StudyAreaSpecies_subset3$GAPstatus, levels = c("GAPUnprotected","GAP4","GAP3","GAP2","GAP1"))
    
    
    StudyAreaSpecies_subset3 %>% #can run from here to...
      ggplot(aes(x = reorder(axislable, PercentArea), 
                 y = PercentArea,
                 fill = Manager)) +
      #geom_bar(stat='identity') + # ...here to get a picture of whats going on before labels
      geom_col() +
      coord_flip() +
      ggtitle(paste(lstStudyAreas[i],"Study Area")) +
      ylab("Inside Study Area") +
      scale_y_continuous(limits = c(0,100), breaks=c(0, 25,50,75,100), labels=c("0%", "25%","50%","75%","100%")) +
      scale_fill_manual(values=c("Unmanaged " = "#B1B1B1",
                                 "UNK " = "#7F7F7F", 
                                 "PVT " = "#6a3d9a",
                                 "TRIB " = "#b15928",
                                 "STAT " = "#ffff99", 
                                 "LOC " = "#e31a1c", 
                                 "FED " = "#fb9a99",
                                 "DOE " = "#b2df8a",
                                 "DOD " = "#1f78b4",
                                 "NGO " = "#ff7f00", 
                                 "BLM " = "#a6cee3",
                                 "FWS " = "#fdbf6f",
                                 "USFS " = "#1F601A", 
                                 "NPS " = "#3BB432"), guide = guide_legend(reverse = TRUE)) +
      theme_minimal() +
      theme(axis.title.y = element_blank(),
            panel.grid = element_blank(),
            legend.title=element_blank(),
            legend.position = "bottom",
            plot.title.position = "plot")
    
    
    
  }
  
}
