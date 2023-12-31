#
# Description:
#
# Script that use probabilites of assignation from different methods to plot them as a STRUCTURE plot.
#

rm(list=ls())
graphics.off()
setwd("Where_you_have_your_input_data") # Plots also are going to be save here

library("stringr")
library("reshape")
library("ggplot2")
library("forcats")

#### Input data

The data must be in the following format (Example for k=2), without header:

ID Score1 Score2

#ID: code of 4 letters for sampling locations, plus individual number. Example: WXYZ01
#Score: Value between 0 to 1.

#### Plot

tbl=read.table("structure2.txt",sep = " ",dec = ",")

#exploracion data inicial
barplot(t(as.matrix(tbl[,2:3])), col=c("indianred1","plum"), legend=T,xaxt="n",
        xlab="Populations/Individual", ylab="Q-mean", xlim = c(0,400),
        border=NA)

#manipulacion
q_mean_ind <- tbl[,1:3]
q_mean_ind$Num<-c(1:224)
colnames(q_mean_ind)=c("IND","1", "2","NUM") # Give name in q_mean column

#Extraer nombre de las poblaciones comando depende del c?digo usado
POP<- str_c(str_sub(q_mean_ind$IND,1,4))
q_mean_ind$POP<-POP

q_mean_ind=melt(q_mean_ind, id=c("IND","NUM","POP"))
colnames(q_mean_ind)=c("IND", "NUM", "POP", "K", "PERC")

#tabla de datos melt
write.table(q_mean_ind,"q_mean_ind2.txt",quote=F,sep="\t",row.name=F)
q_mean_ind$POP[q_mean_ind$POP == "CHCL"] <- "M. chilensis"
q_mean_ind$POP[q_mean_ind$POP == "CRAR"] <- "M. platensis"

#plot
x_title="Populations/Individuals"
y_title="Q-mean"
graph_1<-ggplot(q_mean_ind,aes(x=NUM,y=PERC,fill=K));graph_1
graph_1+geom_bar(stat="identity",position="fill",width=1.1)+
  scale_fill_manual(values=c("indianred","plum"))+
  facet_grid(~fct_inorder(POP), scales = "free", switch = "x", space = "free")+
  theme(panel.spacing.x=unit(0.1, "lines"),panel.spacing.y=unit(1, "lines"))+
  theme(strip.text.x = element_text(angle=0,size=15,face = c(rep("italic",2),rep("plain",9))))+
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1))+
  theme(axis.ticks = element_blank(), 
        axis.text.x = element_blank(),
        axis.text.y = element_text(colour="black",size=15))+
  scale_y_continuous(expand = c(0, 0))+ #in order for the line not to expand beyond the graph!
  labs(y=y_title)+
  labs(x=x_title)+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor=element_blank())+
  theme(axis.title.x=element_text(colour=NULL, size=20),
        axis.title.y=element_text(colour=NULL, size=20))+
  theme(plot.background=element_blank())+
  theme(panel.background=element_blank())+
  theme(plot.margin=unit(c(2,2,1,1),"cm"))+
  theme(legend.position='none')

ggsave("yourplot.tiff", plot = last_plot(),scale = 2, width = 21.94, height = 10.59,units = "cm", dpi = 300)
dev.off()
