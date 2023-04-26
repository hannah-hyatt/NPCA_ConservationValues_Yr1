## Script that is in the process of being adapted from Chris Tracey's original script
## Goal is to get the NVC groups that are at risk and overlap at least 1% with each study area
## These NVC groups have their protection status and management status represented in bar charts both inside and outside of the study areas

library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/AviKwaAmeDeepDive.gdb/TabArea_NVCgrps_GAPstatus_AKAcorridor" # UPDATE Input Tabulate Area table - Managed Lands or GAP status focused
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

# inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/AviKwaAmeDeepDive.gdb/TabArea_NVCgrps_GAPstatus_V2" # UPDATE Input Tabulate Area table - Managed Lands or GAP status focused
# inputTabAreaGAP <- arc.open(inputTabAreaGAP)
# inputTabAreaGAP <- arc.select(inputTabAreaGAP)
# inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

inputTabAreaManaged <- "S:/Projects/NPCA/Data/Intermediate/AviKwaAmeDeepDive.gdb/TabArea_NVCgrps_Mangstatus_AKAcorridor"
inputTabAreaManaged <- arc.open(inputTabAreaManaged)
inputTabAreaManaged <- arc.select(inputTabAreaManaged)
inputTabAreaManaged <- as.data.frame(inputTabAreaManaged)

inputRaster <- "S:/Projects/NPCA/Data/Intermediate/NationalAnalysis.gdb/Landfire_EVT_2020_IVC_join_2023" #
inputRaster <- arc.open(inputRaster)
inputRaster <- arc.select(inputRaster)
inputRaster <- as.data.frame(inputRaster)

inputTabAreaGAP$OBJECTID <- NULL
inputTabAreaManaged$OBJECTID <- NULL

## split out protected unprotected
inputTabAreaGAP$Protected <- "NA"
inputTabAreaGAP$Protected <- gsub("^(.*?),.*", "\\1", inputTabAreaGAP$Corridor_Analysis)

## split out by corridor presence
# inputTabAreaGAP$Corridor <- "NA"
# inputTabAreaGAP$Corridor <- gsub(".*,", "",inputTabAreaGAP$Corridor_Analysis) #takes text after the comma
# inputTabAreaGAP$Corridor <- gsub("-.*", "",inputTabAreaGAP$Corridor)#takes text before hyphen
# inputTabAreaGAP$Corridor <- trimws(inputTabAreaGAP$Corridor, which = c("both", "left", "right"), whitespace = "[ \t\r\n]")#removes whitespace before and after text

## split out GAP status
inputTabAreaGAP$GAPstatus <- "NA"
inputTabAreaGAP$GAPstatus <- sub(".*GAP ", "", inputTabAreaGAP$Corridor_Analysis)    
inputTabAreaGAP$GAPstatus <- as.integer(substring(inputTabAreaGAP$GAPstatus, 1, 1))

# this enables verification of Naturalness in a later step
inputTabAreaGAP <- merge(inputTabAreaGAP, inputRaster[c("IVC_NAME","ROUNDED_G_RANK", "Naturalnes")], by.x="IVC_NAME", by.y="IVC_NAME") 

# subset by G Rank
inputTabAreaGAP$G_RANK <- substr(inputTabAreaGAP$ROUNDED_G_RANK, 1, 2)
inputTabAreaGAP <- inputTabAreaGAP[which(inputTabAreaGAP$G_RANK %in% c("G1", "G2", "G3")), ]

# list NVC groups that overlap with the AKA corridor
NVC_inCorridor <-unique(inputTabAreaGAP$IVC_NAME[which(inputTabAreaGAP$Corridor=="Inside Corridor")])

NVC_subset1 <- inputTabAreaGAP %>%
  group_by( Corridor, Protected, GAPstatus, IVC_NAME, G_RANK) %>% #NPCA_status_GAP_StudyArea,
  summarise(TotalArea = sum(Area)) %>% 
  ungroup()

NVC_subset2 <- NVC_subset1 %>%
  group_by(IVC_NAME) %>%
  mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
  mutate(TotalArea2 = if_else(is.na(Corridor), -TotalArea, TotalArea)) %>%
  mutate(PercentArea2 = if_else(is.na(Corridor), -PercentArea, PercentArea))

NVC_subset3 <- NVC_subset2 %>%
  group_by(IVC_NAME) %>%
  mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>0]))

NVC_subset3 <- NVC_subset3[which(NVC_subset3$TotalPosPercent>0),]

NVC_subset3$axislable <- paste0(NVC_subset3$IVC_NAME, " (", NVC_subset3$G_RANK, ")") 
NVC_subset3$GAPstatus <- paste0("GAP",NVC_subset3$GAPstatus)
NVC_subset3$GAPstatus[which(NVC_subset3$GAPstatus=="GAPNA")] <- "Unprotected"
NVC_subset3$GAPstatus <- factor(NVC_subset3$GAPstatus, levels = c("Unprotected","GAP4","GAP3","GAP2","GAP1"))


NVC_subset3 %>%
  ggplot(aes(x = reorder(axislable, TotalPosPercent),
             y = PercentArea2,
             fill = GAPstatus)) +
  geom_col() +
  coord_flip() +
  geom_abline(slope=0, intercept=0.0,  col = "white") +
  ggtitle(paste("Avi Kwa Ame Corridor")) +
  ylab("Outside Corridor                                                            Inside Corridor") +
  scale_y_continuous(limits = c(-100, 100), breaks=c(-100,-75,-50,-25, 0, 25,50,75,100), labels=c("100%","75%","50%","25%", "0%", "25%","50%","75%","100%")) +
  scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"), guide = guide_legend(reverse = TRUE)) +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        legend.title=element_blank(),
        legend.position = "none",
        plot.title.position = "plot")

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
inputTabAreaManaged$Mang_Name <- trimws(inputTabAreaManaged$Mang_Name)

# this enables verification of Naturalness in a later step
inputTabAreaManaged <- merge(inputTabAreaManaged, inputRaster[c("IVC_NAME","ROUNDED_G_RANK", "Naturalnes")], by.x="IVC_NAME", by.y="IVC_NAME") 

# subset by G Rank
inputTabAreaManaged$G_RANK <- substr(inputTabAreaManaged$ROUNDED_G_RANK, 1, 2)
inputTabAreaManaged <- inputTabAreaManaged[which(inputTabAreaManaged$G_RANK %in% c("G1", "G2", "G3")), ]

lstStudyAreas <- unique(inputTabAreaManaged$StudyArea)
lstManagers <- unique(inputTabAreaManaged$Mang_Name)

for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaManaged[which(inputTabAreaManaged$StudyArea==lstStudyAreas[i]),]
  
  lstGroups_subset <- unique(StudyArea_subset[which(StudyArea_subset$Naturalnes=="Natural"),"IVC_NAME"] )
  
  
  # create an empty data frame
  StudyAreaGroup_subsetComb <- inputTabAreaManaged[0,]
  
  for(j in 1:length(lstGroups_subset)){  #
    print(paste("working on ", lstGroups_subset[j], sep=""))
    StudyAreaGroup_subset <- inputTabAreaManaged[which(inputTabAreaManaged$IVC_NAME==lstGroups_subset[j]),]
    StudyAreaGroup_subset[which(StudyAreaGroup_subset$StudyArea!=lstStudyAreas[i]),"StudyArea"] <- NA
    
    StudyAreaGroup_subsetComb <- rbind(StudyAreaGroup_subsetComb, StudyAreaGroup_subset)
    
    StudyAreaGroup_subset1 <- StudyAreaGroup_subsetComb %>%
      group_by( StudyArea, Managed, Mang_Name, IVC_NAME, G_RANK) %>% 
      summarise(TotalArea = sum(Area)) %>% 
      ungroup()
    
    StudyAreaGroup_subset2 <- StudyAreaGroup_subset1 %>%
      group_by(IVC_NAME) %>%
      mutate(PercentArea =   (TotalArea / sum(TotalArea)*100) ) %>%
      mutate(TotalArea2 = if_else(is.na(StudyArea), -TotalArea, TotalArea)) %>%
      mutate(PercentArea2 = if_else(is.na(StudyArea), -PercentArea, PercentArea))
    
    StudyAreaGroup_subset3 <- StudyAreaGroup_subset2 %>%
      group_by(IVC_NAME) %>%
      mutate(TotalPosPercent =sum(PercentArea2[PercentArea2>0]))
    
    StudyAreaGroup_subset3 <- StudyAreaGroup_subset3[which(StudyAreaGroup_subset3$TotalPosPercent>0),]
    
    StudyAreaGroup_subset3$axislable <- paste0(StudyAreaGroup_subset3$IVC_NAME, " (", StudyAreaGroup_subset3$G_RANK, ")") 
    StudyAreaGroup_subset3$Manager <- factor(StudyAreaGroup_subset3$Mang_Name, levels = c(lstManagers))
    StudyAreaGroup_subset3$Manager <- factor(StudyAreaGroup_subset3$Manager, levels =c('NA','UNK','PVT','TRIB','STAT','LOC','FED','DOE','DOD','NGO','BLM','FWS','USFS','NPS'))
    #StudyAreaEcosystem_subset3 <- StudyAreaEcosystem_subset3[order(levels(StudyAreaEcosystem_subset3$Manager)),]
    
    StudyAreaGroup_subset3 %>%
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
                                 "UNK" = "#7F7F7F", 
                                 "PVT" = "#6a3d9a",
                                 "TRIB" = "#b15928",
                                 "STAT" = "#ffff99", 
                                 "LOC" = "#e31a1c", 
                                 "FED" = "#fb9a99",
                                 "DOE" = "#b2df8a",
                                 "DOD" = "#1f78b4",
                                 "NGO" = "#ff7f00", 
                                 "BLM" = "#a6cee3",
                                 "FWS" = "#fdbf6f",
                                 "USFS" = "#1F601A", 
                                 "NPS" = "#3BB432"), guide = guide_legend(reverse = TRUE)) +
      theme_minimal() +
      theme(axis.title.y = element_blank(),
            panel.grid = element_blank(),
            legend.title=element_blank(),
            legend.position = "none",
            plot.title.position = "plot")
  }
}    
