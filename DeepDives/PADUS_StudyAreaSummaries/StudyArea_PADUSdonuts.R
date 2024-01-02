## Script has been adapted from Chris Tracey's original script
## Creates a series of donut charts representing how much of each study area is protected and at what status
## Also creates a series of donut charts representing the management status within each study area

library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/GAP_Analysis.gdb/TabArea_GAP_xStudyAreasV2"
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

# inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/AviKwaAmeDeepDive.gdb/TabArea_akaGAPsts_wNatMon"
# inputTabAreaGAP <- arc.open(inputTabAreaGAP)
# inputTabAreaGAP <- arc.select(inputTabAreaGAP)
# inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

inputTabAreaGAP$OBJECTID <- NULL

## replace NA for GAPstatus where the lands are unprotected
inputTabAreaGAP$GAPstatus <- sub("*", "", inputTabAreaGAP$GAP_Sts)  
inputTabAreaGAP$GAPstatus <- paste0("GAP",inputTabAreaGAP$GAPstatus)
inputTabAreaGAP$GAPstatus[which(inputTabAreaGAP$GAPstatus=="GAPNA")] <- "Unprotected"

lstStudyAreas <- unique(inputTabAreaGAP$NAME)

for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaGAP[which(inputTabAreaGAP$NAME==lstStudyAreas[i]),] #makes it so you can loop through the study areas
  
  StudyArea_subset1 <- StudyArea_subset %>% #groups by study area and calculates the total area
    group_by( NAME, GAPstatus) %>%
    summarise(Area = sum(Area)) %>% 
    ungroup()
  
  StudyArea_subset2 <- StudyArea_subset1 %>% #calculates the percentages
    group_by(NAME) %>%
    mutate(PercentArea =   (Area / sum(Area)*100) )
  
  StudyArea_subset2$GAPstatus <- factor(StudyArea_subset2$GAPstatus, levels = c("Unprotected","GAP4","GAP3","GAP2","GAP1"))
  StudyArea_subset2$ymax = cumsum(StudyArea_subset2$PercentArea) #sets top of rectangle for ggplot
  StudyArea_subset2$ymin = c(0, head(StudyArea_subset2$ymax, n=-1)) #sets bottom of rectange for ggplot
  
  StudyArea_subset2 %>%
    ggplot (aes(x=2, ymax=ymax,ymin=ymin, xmax=4, xmin=3, fill = GAPstatus))+
    geom_rect()+
    ggtitle(paste(lstStudyAreas[i],"Study Area")) +
    coord_polar(theta = "y")+ #makes plot circular
    scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"))+
    theme_void()+ #punches hole in donut
    theme(legend.position = "bottom", legend.title = element_blank(),plot.title.position = "plot")+
    xlim(1,4) #sets width of donut
  #facet_wrap(vars(), ncol=8) 
}
ggsave(paste0("StudyArea_GAPsts_GAriver.png"), plot = p, bg = "transparent",dpi = 300)
write.csv(StudyArea_subset2, "S:/Projects/NPCA/MapExports/Draft/AAGpublication/GAPsts_SouthernApp.csv")
##----------------------------------------------------------------------------------------------------------------------
## Donut charts based on PADUS Management fields - simplified 


inputTabAreaManaged <- "S:/Projects/NPCA/Data/Intermediate/GAP_Analysis.gdb/TabArea_MangNS_xStudyAreasV2"
inputTabAreaManaged <- arc.open(inputTabAreaManaged)
inputTabAreaManaged <- arc.select(inputTabAreaManaged)
inputTabAreaManaged <- as.data.frame(inputTabAreaManaged)

inputTabAreaManaged$OBJECTID <- NULL

## Sets the manager information
inputTabAreaManaged$Manager <- paste(inputTabAreaManaged$Mang_NS) 

lstStudyAreas <- unique(inputTabAreaManaged$NAME)
lstManagers <- unique(inputTabAreaManaged$Mang_NS)

for(i in 1:length(lstStudyAreas)){
  print(paste("working on ", lstStudyAreas[i], sep=""))
  StudyArea_subset <- inputTabAreaManaged[which(inputTabAreaManaged$NAME==lstStudyAreas[i]),] #makes it so you can loop through the study areas
  
  StudyArea_subset1 <- StudyArea_subset %>% #groups by study area and calculates the total area
    group_by( NAME, Mang_NS) %>%
    summarise(Area = sum(Area)) %>% 
    ungroup()
  
  StudyArea_subset2 <- StudyArea_subset1 %>% #calculates the percentages
    group_by(NAME) %>%
    mutate(PercentArea =   (Area / sum(Area)*100) )
  
  StudyArea_subset2$Mang_NS <- factor(StudyArea_subset2$Mang_NS, levels = c(lstManagers))
  StudyArea_subset2$Mang_NS <- factor(StudyArea_subset2$Mang_NS, levels =c('Unmanaged','UNK','PVT','TRIB','STAT','LOC','FED','DOE','DOD','NGO','BLM','FWS','USFS','NPS'))
  StudyArea_subset2 <- plyr::ddply(StudyArea_subset2, c('Mang_NS')) #sorts the dataframe to match the way the factors are sorted
  StudyArea_subset2$Mang_NS <- fct_rev(StudyArea_subset2$Mang_NS)
  StudyArea_subset2$ymax = cumsum(StudyArea_subset2$PercentArea) #sets top of rectangle for ggplot
  StudyArea_subset2$ymin = c(0, head(StudyArea_subset2$ymax, n=-1)) #sets bottom of rectange for ggplot
  
  StudyArea_subset2 %>%
    ggplot (aes(x=2, ymax=ymax,ymin=ymin, xmax=4, xmin=3, fill = Mang_NS))+
    geom_rect()+
    ggtitle(paste(lstStudyAreas[i],"Study Area")) +
    coord_polar(theta = "y")+ #makes plot circular
    scale_y_reverse()+
    scale_fill_manual(values=c("Unmanaged" = "#B1B1B1",
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
                               "NPS" = "#3BB432"))+
    theme_void()+ #punches hole in donut
    theme(legend.position = "bottom", legend.title = element_blank(),plot.title.position = "plot")+
    xlim(1,4) #sets width of donut
}
ggsave(paste0("StudyArea_Mangsts.png"), plot = p, bg = "transparent",dpi = 300)
write.csv(StudyArea_subset2, "S:/Projects/NPCA/MapExports/Draft/AAGpublication/Managersts_SouthernApp.csv")
