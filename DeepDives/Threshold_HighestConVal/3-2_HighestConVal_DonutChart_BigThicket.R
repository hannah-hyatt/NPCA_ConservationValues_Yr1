## This sript is the final step in a series of process which creates donut charts 
## representing the GAP status and Managment status of areas of highest conservation 
## value within the study area of interest

library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/BigThicketDeepDive.gdb/TabArea_SAconval_v2_GAPstatus" ##UPDATE to deep dive study area of interest
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

inputTabAreaGAP$OBJECTID <- NULL

# Create Gap Status field
inputTabAreaGAP$GAPstatus <- paste0("GAP",inputTabAreaGAP$GAP_Sts)

# Create Study Area
inputTabAreaGAP$StudyArea <- paste0("Big Thicket")

# Create plot
StudyArea_subset1 <- inputTabAreaGAP %>% #groups by study area and calculates the total area
  group_by( StudyArea, GAPstatus) %>%
  summarise(Area = sum(Area)) %>% 
  ungroup()

StudyArea_subset2 <- StudyArea_subset1 %>% #calculates the percentages
  group_by(StudyArea) %>%
  mutate(PercentArea =   (Area / sum(Area)*100) )

StudyArea_subset2$GAPstatus <- factor(StudyArea_subset2$GAPstatus, levels = c("GAPNA","GAP4","GAP3","GAP2","GAP1"))
StudyArea_subset2$ymax = cumsum(StudyArea_subset2$PercentArea) #sets top of rectangle for ggplot
StudyArea_subset2$ymin = c(0, head(StudyArea_subset2$ymax, n=-1)) #sets bottom of rectange for ggplot

StudyArea_subset2 %>%
  ggplot (aes(x=2, ymax=ymax,ymin=ymin, xmax=4, xmin=3, fill = GAPstatus))+
  geom_rect()+
  ggtitle("Big Thicket") +
  coord_polar(theta = "y")+ #makes plot circular
  scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"))+
  theme_void()+ #punches hole in donut
  theme(legend.position = "none", legend.title = element_blank(),plot.title.position = "plot")+
  xlim(1,4) #sets width of donut
#facet_wrap(vars(), ncol=8) 



##----------------------------------------------------------------------------------------------------------------------#
## Donut charts based on PADUS Management fields - simplified 


inputTabAreaManaged <- "S:/Projects/NPCA/Data/Intermediate/BigThicketDeepDive.gdb/TabArea_SAconval_v2_ManagedLands" ##UPDATE to deep dive study area of interest
inputTabAreaManaged <- arc.open(inputTabAreaManaged)
inputTabAreaManaged <- arc.select(inputTabAreaManaged)
inputTabAreaManaged <- as.data.frame(inputTabAreaManaged)

inputTabAreaManaged$OBJECTID <- NULL

## Create manager field
inputTabAreaManaged$Manager <- paste(inputTabAreaManaged$Mang_NS) 

# Create Study Area
inputTabAreaManaged$StudyArea <- paste0("Big Thicket")

#create plot
StudyArea_subset1 <- inputTabAreaManaged %>% #groups by study area and calculates the total area
  group_by( StudyArea, Mang_NS) %>%
  summarise(Area = sum(Area)) %>% 
  ungroup()

StudyArea_subset2 <- StudyArea_subset1 %>% #calculates the percentages
  group_by(StudyArea) %>%
  mutate(PercentArea =   (Area / sum(Area)*100) )

StudyArea_subset2$Mang_NS <- factor(StudyArea_subset2$Mang_NS, levels =c('Unmanaged','UNK','PVT','TRIB','STAT','LOC','FED','DOE','DOD','NGO','BLM','FWS','USFS','NPS'))
StudyArea_subset2 <- plyr::ddply(StudyArea_subset2, c('Mang_NS')) # sorts data frame in the same order as the factor levels

StudyArea_subset2$ymax = cumsum(StudyArea_subset2$PercentArea) #sets top of rectangle for ggplot
StudyArea_subset2$ymin = c(0, head(StudyArea_subset2$ymax, n=-1)) #sets bottom of rectange for ggplot

StudyArea_subset2 %>%
  ggplot (aes(x=2, ymax=ymax,ymin=ymin, xmax=4, xmin=3, fill = Mang_NS))+
  geom_rect()+
  ggtitle("Big Thicket") +
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
  theme(legend.position = "none", legend.title = element_blank(),plot.title.position = "plot")+
  xlim(1,4) #sets width of donut
