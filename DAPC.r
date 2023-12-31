#
# Description:
#
# Perform a DAPC analysis using SNP data (Genepop format)
# Based on https://github.com/Tom-Jenkins/utility_scripts/blob/master/repeat_dapc_using_Thia2022_nPC_method.R
#

rm(list=ls())
graphics.off()
setwd("Where_is_your_genepop")

#Input: Genepop file with extension ".gen". Example: "mydatasnp.gen"

library("adegenet")

datos<-read.genepop("your_genepop.gen",ncode = 3,quiet=FALSE)

grup_datos <- find.clusters(datos, max.n.clust=30) # Run a DAPC using a specific k number
dapcdatos = dapc(datos, grup_referenciayambos$grp)

table(pop(datos),dapcdatos$assign)

ind_coords = as.data.frame(dapcdatos$ind.coord) # Create a data.frame containing individual coordinates
colnames(ind_coords) = c("Axis1","Axis2","Axis3") # Rename columns of dataframe
ind_coords$Ind = indNames(datos) # Add a column containing individuals
ind_coords$Site = datos$pop # Add a column with the site IDs
centroid = aggregate(cbind(Axis1, Axis2, Axis3) ~ Site, data = ind_coords, FUN = mean) # Calculate centroid (average) position for each population
ind_coords = left_join(ind_coords, centroid, by = "Site", suffix = c("",".cen")) # Add centroid coordinates to ind_coords dataframe

# Color by group

cols = c("darkolivegreen4","dodgerblue3","goldenrod1","grey60","indianred1","plum",colorRampPalette(c("#E9CE53","#38845C"))(9))

# Custom x and y labels
xlab = paste("Axis 1 (", format(round(percent[1], 1), nsmall=1)," %)", sep="")
ylab = paste("Axis 2 (", format(round(percent[2], 1), nsmall=1)," %)", sep="")

# Scatter plot axis 1 vs. 2
ggplot(data = ind_coords, aes(x = Axis1, y = Axis2))+
  geom_hline(yintercept = 0)+
  geom_vline(xintercept = 0)+
  # spider segments
  geom_segment(aes(xend = Axis1.cen, yend = Axis2.cen, colour = Site), show.legend = FALSE)+
  # points
  geom_point(aes(color = Site), shape = c(rep(15,30),rep(16,26),rep(17,29),rep(18,19),rep(19,29),rep(20,35),
                                         rep(6,19),rep(7,18),rep(8,18),rep(9,19),rep(10,19),rep(11,18),rep(12,17),
                                         rep(13,16),rep(14,16)),
                                         size = 3, show.legend = FALSE)+
  # centroids con etiquetas separadas
  geom_label_repel(data = centroid, aes(label = Site, fill = Site), size = 4, show.legend = FALSE,max.overlaps = 30)+
  # colouring
  scale_fill_manual(values = cols)+
  scale_colour_manual(values = cols)+
  # custom labels
  labs(x = xlab, y = ylab)+
  ggtitle("")+
  #coord_fixed()+
  theme(axis.text.y = element_text(colour="black", size=12),
        axis.text.x = element_text(colour="black", size=12),
        axis.title = element_text(colour="black", size=12),
        panel.border = element_rect(colour="black", fill=NA),
        panel.background = element_blank(),
        plot.title = element_text(hjust=0.5, size=15)
  )

#Posterior probabilities for plotting and individual asignation.

posteriori<-dapambos$posterior
write.table(posteriori,file = "posteriori.csv")
