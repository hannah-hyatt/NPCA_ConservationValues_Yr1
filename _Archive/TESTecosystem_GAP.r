library(tidyverse)
library(here)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabArea <- "S:/Projects/NPCA/Pro/Draft/PADUS_cleanup/PADUS_cleanup.gdb/Tabulat_IUCN"
inputTabArea <- arc.open(inputTabArea)
inputTabArea <- arc.select(inputTabArea)
inputTabArea <- as.data.frame(inputTabArea)


inputRaster <- "S:/Projects/NPCA/Pro/Draft/PADUS_cleanup/PADUS_cleanup.gdb/IUCNecosystemsTable"
inputRaster <- arc.open(inputRaster)
inputRaster <- arc.select(inputRaster)
inputRaster <- as.data.frame(inputRaster)

inputTabArea$OBJECTID <- NULL

# split out study area
inputTabArea$StudyArea <- "NA"
inputTabArea$StudyArea <- stringr::str_extract(string = inputTabArea$NPCA_status_GAP_StudyArea, pattern = "(?<=\\().*(?=\\))")

# split out protected unprotected
inputTabArea$Protected <- "NA"
inputTabArea$Protected <- gsub(",.*$", "", inputTabArea$NPCA_status_GAP_StudyArea)

# split out GAP status
inputTabArea$GAPstatus <- "NA"
inputTabArea$GAPstatus <- sub(".*GAP ", "", inputTabArea$NPCA_status_GAP_StudyArea) 
inputTabArea$GAPstatus <- as.integer(substring(inputTabArea$GAPstatus, 1, 1))

inputTabArea <- merge(inputTabArea, inputRaster[c("Value","NatureServ","RLE_FINAL", "Naturalnes")], by.x="Value", by.y="Value") 

# subset by RLE status
inputTabArea$RLE_FINAL1 <- substr(inputTabArea$RLE_FINAL, 1, 2)
inputTabArea <- inputTabArea[which(inputTabArea$RLE_FINAL1 %in% c("CR", "EN", "VU")), ]


lstStudyAreas <- unique(inputTabArea$StudyArea)


for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabArea[which(inputTabArea$StudyArea==lstStudyAreas[i]),]
  
  lstEcosystems_subset <- unique(StudyArea_subset[which(StudyArea_subset$Naturalnes=="Natural"),"NatureServ"] )

  # create an empty data frame
  StudyAreaEcosystem_subsetComb <- inputTabArea[0,]
  
  for(j in 1:length(lstEcosystems_subset)){  #
    print(paste("working on ", lstEcosystems_subset[j], sep=""))
    StudyAreaEcosystem_subset <- inputTabArea[which(inputTabArea$NatureServ==lstEcosystems_subset[j]),]
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
      theme(axis.title.y = element_blank(),
            panel.grid = element_blank(),
            legend.title=element_blank(),
            legend.position = "bottom",
            plot.title.position = "plot")

    }

}
  
  

