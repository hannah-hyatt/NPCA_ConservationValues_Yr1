## Script has been adapted from Chris Tracey's original script
## Creates a series of donut charts representing how much of each study area is protected and at what status
## Also creates a series of donut charts representing the management status within each study area

library(tidyverse)
library(arcgisbinding)

arc.check_product()
options(scipen=999) # don't use scientific notation

inputTabAreaGAP <- "S:/Projects/NPCA/Data/Intermediate/AviKwaAmeDeepDive.gdb/TabArea_atriskNVCgroups_insideAKA_GAPsts"
inputTabAreaGAP <- arc.open(inputTabAreaGAP)
inputTabAreaGAP <- arc.select(inputTabAreaGAP)
inputTabAreaGAP <- as.data.frame(inputTabAreaGAP)

inputTabAreaGAP$OBJECTID <- NULL

## replace NA for GAPstatus where the lands are unprotected
inputTabAreaGAP$GAPstatus <- sub("*", "", inputTabAreaGAP$GAP_Sts)  
inputTabAreaGAP$GAPstatus <- paste0("GAP",inputTabAreaGAP$GAPstatus)
inputTabAreaGAP$GAPstatus[which(inputTabAreaGAP$GAPstatus=="GAPU")] <- "Unprotected"

## Create donut chart
StudyArea_subset1 <- inputTabAreaGAP %>% #groups by study area and calculates the total area
  group_by( ROUNDED_G_, GAPstatus) %>%
  summarise(Area = sum(Area)) %>% 
  ungroup()

StudyArea_subset2 <- StudyArea_subset1 %>% #calculates the percentages
  group_by(ROUNDED_G_) %>%
  mutate(PercentArea =   (Area / sum(Area)*100) )

StudyArea_subset2$GAPstatus <- factor(StudyArea_subset2$GAPstatus, levels = c("Unprotected","GAP4","GAP3","GAP2","GAP1"))
StudyArea_subset2$ymax = cumsum(StudyArea_subset2$PercentArea) #sets top of rectangle for ggplot
StudyArea_subset2$ymin = c(0, head(StudyArea_subset2$ymax, n=-1)) #sets bottom of rectange for ggplot

p <- StudyArea_subset2 %>%
  ggplot (aes(x=2, ymax=ymax,ymin=ymin, xmax=4, xmin=3, fill = GAPstatus))+
  geom_rect()+
  ggtitle("Vulnerable NVC Groups") +
  coord_polar(theta = "y")+ #makes plot circular
  scale_fill_manual(values=c("#b1b1b1","#bed5cf","#659fb5","#869447","#27613b"))+
  theme_void()+ #punches hole in donut
  theme(legend.position = "bottom", legend.title = element_blank(),plot.title.position = "plot")+
  xlim(1,4) #sets width of donut

ggsave(paste0("StudyArea_Mangsts.png"), plot = p, bg = "transparent",dpi = 300)
