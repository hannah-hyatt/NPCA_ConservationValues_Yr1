## Script that is in the process of being adapted from Chris Tracey's original script
## Original script calculated the area of IUCN red listed ecosystems that fall inside and outside of the study areas and 
## summarized the level of protection (Gap status) that each ecosystem had within and outside of the study area into a bar chart
## Goal: to do the same thing using PADUS's latest version which flattens the PADUS data by gap status as well as managed lands

library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/GAP_Analysis.gdb/TabArea_IUCN_GAPstatus_CONUS" # UPDATE Input Tabulate Area table - Managed Lands or GAP status focused
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

inputTabAreaManaged <- "S:/Projects/NPCA/Data/Intermediate/GAP_Analysis.gdb/TabArea_IUCN_ManagedLands_CONUS"
inputTabAreaManaged <- arc.open(inputTabAreaManaged)
inputTabAreaManaged <- arc.select(inputTabAreaManaged)
inputTabAreaManaged <- as.data.frame(inputTabAreaManaged)

inputRaster <- "S:/Projects/NPCA/Data/Intermediate/NationalAnalysis.gdb/IUCNecosystems_CONUS_tbl" #
inputRaster <- arc.open(inputRaster)
inputRaster <- arc.select(inputRaster)
inputRaster <- as.data.frame(inputRaster)

inputTabAreaGAP$OBJECTID <- NULL
inputTabAreaManaged$OBJECTID <- NULL


## split out study area
inputTabAreaGAP$StudyArea <- "NA"
inputTabAreaGAP$StudyArea <- gsub("\\(([^()]+)\\)", "\\1",str_extract(inputTabAreaGAP$NPCA_Status_GAP_StudyArea, "\\(([^()]+)\\)"))

## split out protected unprotected
inputTabAreaGAP$Protected <- "NA"
inputTabAreaGAP$Protected <- gsub("^(.*?),.*", "\\1", inputTabAreaGAP$NPCA_Status_GAP_StudyArea)

## split out GAP status
inputTabAreaGAP$GAPstatus <- "NA"
inputTabAreaGAP$GAPstatus <- sub(".*GAP ", "", inputTabAreaGAP$NPCA_Status_GAP_StudyArea)    
inputTabAreaGAP$GAPstatus <- as.integer(substring(inputTabAreaGAP$GAPstatus, 1, 1))

# this enables verification of Naturalness in a later step
inputTabAreaGAP <- merge(inputTabAreaGAP, inputRaster[c("NatureServ","RLE_FINAL", "Naturalnes")], by.x="NatureServ", by.y="NatureServ") 

# subset by RLE status
inputTabAreaGAP$RLE_FINAL1 <- substr(inputTabAreaGAP$RLE_FINAL, 1, 2)
inputTabAreaGAP <- inputTabAreaGAP[which(inputTabAreaGAP$RLE_FINAL1 %in% c("CR", "EN", "VU")), ]


lstStudyAreas <- unique(inputTabAreaGAP$StudyArea)


for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaGAP[which(inputTabAreaGAP$StudyArea==lstStudyAreas[i]),]
  
  lstEcosystems_subset <- unique(StudyArea_subset[which(StudyArea_subset$Naturalnes=="Natural"),"NatureServ"] )
  
  # create an empty data frame
  StudyAreaEcosystem_subsetComb <- inputTabAreaGAP[0,]
  
  for(j in 1:length(lstEcosystems_subset)){  #
    print(paste("working on ", lstEcosystems_subset[j], sep=""))
    StudyAreaEcosystem_subset <- inputTabAreaGAP[which(inputTabAreaGAP$NatureServ==lstEcosystems_subset[j]),]
    StudyAreaEcosystem_subset[which(StudyAreaEcosystem_subset$StudyArea!=lstStudyAreas[i]),"StudyArea"] <- NA
    
    StudyAreaEcosystem_subsetComb <- rbind(StudyAreaEcosystem_subsetComb, StudyAreaEcosystem_subset)
    
    StudyAreaEcosystem_subset1 <- StudyAreaEcosystem_subsetComb %>%
      group_by( StudyArea, Protected, GAPstatus, NatureServ, RLE_FINAL1) %>% #NPCA_status_GAP_StudyArea,
      summarise(TotalArea = sum(Area)) %>% 
      ungroup()
    
    StudyAreaEcosystem_subset2 <- StudyAreaEcosystem_subset1 %>%
      group_by(NatureServ) %>%
      mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
      mutate(TotalArea2 = if_else(is.na(StudyArea), -TotalArea, TotalArea)) %>%
      mutate(PercentArea2 = if_else(is.na(StudyArea), -PercentArea, PercentArea))
    
    StudyAreaEcosystem_subset3 <- StudyAreaEcosystem_subset2 %>%
      group_by(NatureServ) %>%
      mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>0]))
    
    StudyAreaEcosystem_subset3 <- StudyAreaEcosystem_subset3[which(StudyAreaEcosystem_subset3$TotalPosPercent>1),]
    
    StudyAreaEcosystem_subset3$axislable <- paste0(StudyAreaEcosystem_subset3$NatureServ, " (", StudyAreaEcosystem_subset3$RLE_FINAL1, ")") 
    StudyAreaEcosystem_subset3$GAPstatus <- paste0("GAP",StudyAreaEcosystem_subset3$GAPstatus)
    StudyAreaEcosystem_subset3$GAPstatus[which(StudyAreaEcosystem_subset3$GAPstatus=="GAPNA")] <- "Unprotected"
    StudyAreaEcosystem_subset3$GAPstatus <- factor(StudyAreaEcosystem_subset3$GAPstatus, levels = c("Unprotected","GAP4","GAP3","GAP2","GAP1"))
    
    
    StudyAreaEcosystem_subset3 %>%
      ggplot(aes(x = reorder(axislable, TotalPosPercent),
                 y = PercentArea2,
                 fill = GAPstatus)) +
      geom_col() +
      coord_flip() +
      geom_abline(slope=0, intercept=0.0,  col = "white") +
      ggtitle(paste(lstStudyAreas[i],"Study Area")) +
      ylab("Outside Study Area                                                             Inside Study Area") +
      scale_y_continuous(limits = c(-100, 100), breaks=c(-100,-75,-50,-25, 0, 25,50,75,100), labels=c("100%","75%","50%","25%", "0%", "25%","50%","75%","100%")) +
      scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"), guide = guide_legend(reverse = TRUE)) +
      theme_minimal() +
      theme(panel.grid = element_blank())
  }
}


#-----------------------------------------------------------------------
### Repeat the above steps for results summarized by Manager Name

## split out study area
inputTabAreaManaged$StudyArea <- "NA"
inputTabAreaManaged$StudyArea <- gsub("\\(([^()]+)\\)", "\\1",str_extract(inputTabAreaManaged$NPCA_Status_Mang_StudyArea, "\\(([^()]+)\\)"))

## split out managed unmanaged
inputTabAreaManaged$Managed <- "NA"
inputTabAreaManaged$Managed <- gsub("^(.*?),.*", "\\1", inputTabAreaManaged$NPCA_Status_Mang_StudyArea)

## split out Manager Name
inputTabAreaManaged$Mang_Name <- "NA"
inputTabAreaManaged$Mang_Name <- sub(".*-(.*)-.*", "\\1",inputTabAreaManaged$NPCA_Status_Mang_StudyArea)

# this enables verification of Naturalness in a later step
inputTabAreaManaged <- merge(inputTabAreaManaged, inputRaster[c("NatureServ","RLE_FINAL", "Naturalnes")], by.x="NatureServ", by.y="NatureServ") 

# subset by RLE status
inputTabAreaManaged$RLE_FINAL1 <- substr(inputTabAreaManaged$RLE_FINAL, 1, 2)
inputTabAreaManaged <- inputTabAreaManaged[which(inputTabAreaManaged$RLE_FINAL1 %in% c("CR", "EN", "VU")), ]

lstStudyAreas <- unique(inputTabAreaManaged$StudyArea)
lstManagers <- unique(inputTabAreaManaged$Mang_Name)

for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaManaged[which(inputTabAreaManaged$StudyArea==lstStudyAreas[i]),]
  
  lstEcosystems_subset <- unique(StudyArea_subset[which(StudyArea_subset$Naturalnes=="Natural"),"NatureServ"] )
  
  
  # create an empty data frame
  StudyAreaEcosystem_subsetComb <- inputTabAreaManaged[0,]
  
  for(j in 1:length(lstEcosystems_subset)){  #
    print(paste("working on ", lstEcosystems_subset[j], sep=""))
    StudyAreaEcosystem_subset <- inputTabAreaManaged[which(inputTabAreaManaged$NatureServ==lstEcosystems_subset[j]),]
    StudyAreaEcosystem_subset[which(StudyAreaEcosystem_subset$StudyArea!=lstStudyAreas[i]),"StudyArea"] <- NA
    
    StudyAreaEcosystem_subsetComb <- rbind(StudyAreaEcosystem_subsetComb, StudyAreaEcosystem_subset)
    
    StudyAreaEcosystem_subset1 <- StudyAreaEcosystem_subsetComb %>%
      group_by( StudyArea, Managed, Mang_Name, NatureServ, RLE_FINAL1) %>% 
      summarise(TotalArea = sum(Area)) %>% 
      ungroup()
    
    StudyAreaEcosystem_subset2 <- StudyAreaEcosystem_subset1 %>%
      group_by(NatureServ) %>%
      mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
      mutate(TotalArea2 = if_else(is.na(StudyArea), -TotalArea, TotalArea)) %>%
      mutate(PercentArea2 = if_else(is.na(StudyArea), -PercentArea, PercentArea))
    
    StudyAreaEcosystem_subset3 <- StudyAreaEcosystem_subset2 %>%
      group_by(NatureServ) %>%
      mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>0]))
    
    StudyAreaEcosystem_subset3 <- StudyAreaEcosystem_subset3[which(StudyAreaEcosystem_subset3$TotalPosPercent>1),]
    
    StudyAreaEcosystem_subset3$axislable <- paste0(StudyAreaEcosystem_subset3$NatureServ, " (", StudyAreaEcosystem_subset3$RLE_FINAL1, ")") 
    StudyAreaEcosystem_subset3$Manager <- factor(StudyAreaEcosystem_subset3$Mang_Name, levels = c(lstManagers))
    StudyAreaEcosystem_subset3$Manager <- factor(StudyAreaEcosystem_subset3$Manager, levels =c('NA',' UNK ',' PVT ',' TRIB ',' STAT ',' LOC ',' FED ',' DOE ',' DOD ',' NGO ',' BLM ',' FWS ',' USFS ',' NPS '))
    #StudyAreaEcosystem_subset3 <- StudyAreaEcosystem_subset3[order(levels(StudyAreaEcosystem_subset3$Manager)),]
    
    StudyAreaEcosystem_subset3 %>%
      ggplot(aes(x = reorder(axislable, TotalPosPercent),
                 y = PercentArea2,
                 fill = Manager)) +
      geom_col() +
      coord_flip() +
      geom_abline(slope=0, intercept=0.0,  col = "white") +
      ggtitle(paste(lstStudyAreas[i],"Study Area")) +
      ylab("Outside Study Area                                                             Inside Study Area") +
      scale_y_continuous(limits = c(-100, 100), breaks=c(-100,-75,-50,-25, 0, 25,50,75,100), labels=c("100%","75%","50%","25%", "0%", "25%","50%","75%","100%")) +
      scale_fill_manual(values=c("NA" = "#B1B1B1",
                                 " UNK " = "#7F7F7F", 
                                 " PVT " = "#6a3d9a",
                                 " TRIB " = "#b15928",
                                 " STAT " = "#ffff99", 
                                 " LOC " = "#e31a1c", 
                                 " FED " = "#fb9a99",
                                 " DOE " = "#b2df8a",
                                 " DOD " = "#1f78b4",
                                 " NGO " = "#ff7f00", 
                                 " BLM " = "#a6cee3",
                                 " FWS " = "#fdbf6f",
                                 " USFS " = "#1F601A", 
                                 " NPS " = "#3BB432"), guide = guide_legend(reverse = TRUE)) +
      theme_minimal() +
      theme(axis.title.y = element_blank(),
            panel.grid = element_blank(),
            legend.title=element_blank(),
            legend.position = "bottom",
            plot.title.position = "plot")
}
}    
