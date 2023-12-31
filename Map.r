#
# Description:
#
# Script to plot a map with sampling locations. Include the option to add landform names, colors by country or zone delimitation.
#

rm(list=ls())
graphics.off()
setwd("Where_you_want_save_your_plot")

library(ggplot2) 
library(rgeos)
library(rgdal)  
library(raster)  
library(ggsn) 
library(rworldmap)
library(rworldxtra)
library(scatterpie)
library(ggrepel)

# Input data

myti_pop <-data.frame(pop=c("your_pop_names"),
                      Lat=c("your latitudes",
                      Lon=c("your longitudes"),
                      #pais=c("if you want to add the country where is the population: add your country names by each pop"),
                      #zone=c("if you want to add zones by each pop")) 

#### Map

# Get world map
world <- getMap(resolution = "high")

# Preliminary plot
ggplot(myti_pop, mapping = aes(x = Lon, y = Lat)) + 
  geom_point(alpha = 0.5)

# Get map data
#extent
clipper_chile <- as(extent(-74, -57, -56, -51), "SpatialPolygons")
proj4string(clipper_chile) <- CRS(proj4string(world))
world_clip <- raster::intersect(world, clipper_chile)
world_clip_f <- fortify(world_clip)

# Plot Map

ggplot() + 
  geom_polygon(data = world_clip_f,aes(x = long, y = lat, group = group),fill = "#E5E5E5", colour = "black") +
  geom_label_repel(data = myti_pop[1:9,],aes(label=pop, x = Lon, y = Lat),
                   fill = "white",
                   alpha = 1, size = 4, fontface=2, #alpha manipula la transparencia, 1 es sin 
                   nudge_x = c(-1,1,1.5,-1,0.4,-0.2,-0.6,0.4,1), 
                   nudge_y = c(-0.7,0.5,0,0.3,0.3,0.3,0.2,0.2,0.2),
  ) +
  # Use only if you added to your input coordinates for geographical accidents and want it plotted in it
  geom_text_repel(data = myti_pop[10:19,],aes(label=pop, x = Lon, y = Lat),
                   alpha = 1, size = 4, fontface=2,segment.color = c(NA,rep("black",9)), #alpha manipula la transparencia, 1 es sin 
                   nudge_x = c(0.5,4,0.4,-2.5,-3,-1,rep(0,2),0.5,1.5), 
                   nudge_y = c(0.7,0.6,-0.3,-1.2,-1,-1,rep(0,2),-0.8,-0.5),
  ) +
  theme_bw() +
  theme(text = element_text(size = 20)) +
  labs(x="longitud",y="Latitude",color="Zone") +
  xlab("Longitude") +
  ylab("Latitude") +
  ggtitle("Sampling locations by zone")+
  theme(plot.title = element_text(hjust = 0.5,lineheight=.8, face="bold")) +
  coord_quickmap() +
  geom_point(aes(x = Lon, y = Lat, shape = factor(zone)),size=c(rep(4,9),rep(0,2),rep(0.5,4),rep(0,2),0.5,0.5),
             data = myti_pop,color=c("#54C5D9","#54C5D9","#54C5D9","#3797A9","#3797A9","#3797A9",
                                     "#225B68","#225B68","#225B68","white","#E5E5E5",rep("black",4),rep("white",2),"black","black")) + 
  guides(color = guide_legend(override.aes = list(linetype = 0, size=3))) +
  theme(legend.position = "none")

### Save map as tiff file

ggsave(path = getwd(), filename = "sampling_locations.tiff", width = 16, height = 8.3, device='tiff', dpi=300)
