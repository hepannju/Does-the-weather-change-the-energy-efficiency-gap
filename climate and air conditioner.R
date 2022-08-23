
library(GSODR)
library(foreign)
library(haven)
library(plyr)
library(ggplot2)
library(ncdf4)
library(lubridate)
library(raster)
library(xlsx)
library(tidyverse)
library(raster)

rm(list=ls())
cat("\014")


###########################retrieve GSOD data
setwd("G:/climate and air conditioner/GSOD")

rm(list=ls())
cat("\014")

US_climate<- get_GSOD(years = 2013:2019, country = "United States")

write_dta(US_climate, "US climate 2013 to 2019.dta")

US_climate<- get_GSOD(years = 2006:2012, country = "United States")

write_dta(US_climate, "US climate 2006 to 2012.dta")

US_climate<- get_GSOD(years = 2000:2005, country = "United States")

write_dta(US_climate, "US climate 2000 to 2005.dta")

US_climate<- get_GSOD(years = 1996:1999, country = "United States")

write_dta(US_climate, "US climate 1996 to 1999.dta")



###########################figures
#######main
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R main.dta")

interval<-data.frame(id=c(1:19),
                     range=c("<=0","0-2","2-4","4-6","6-8","8-10","10-12","12-14","14-16","16-18","18-20", 
                                 "20-22","22-24","24-26","26-28","28-30","30-32","32-34",">34"))

dataset<-merge(dataset, interval, by="id")

dataset$range<-factor(dataset$range, 
                       levels=c("<=0","0-2","2-4","4-6","6-8","8-10","10-12","12-14","14-16","16-18","18-20", 
                                "20-22","22-24","24-26","26-28","28-30","30-32","32-34",">34"), order=T) 

dataset$variable<-factor(dataset$variable, 
                     levels=c("Main","Price Outlier"), order=T) 

coefficient<-ggplot()
coefficient<-coefficient+geom_point(data=dataset[which(dataset$coef=="c"),], aes(x=range, y=est_*100, group=variable), size=2)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef=="c"),], aes(x=range, y=est_*100, group=interaction(coef, variable)), size=1)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef!="c"),], aes(x=range, y=est_*100, group=interaction(variable, id)), size=1)
coefficient<-coefficient+facet_wrap(~variable)
coefficient<-coefficient+theme_bw()+theme(axis.text.x = element_text(angle = 90, lineheight=0.5, hjust = 1, vjust=0.5),
                                          text = element_text(size=25),
                                          legend.text=element_text(size=25),
                                          panel.grid.major = element_blank(),
                                          panel.grid.minor = element_blank(),
                                          strip.background = element_blank(),
                                          strip.placement = "outside",
                                          legend.position="bottom")
coefficient<-coefficient+labs(x="Temperature",y ="Probability of being Energy Star Model, %", colour=NULL)
#coefficient<-coefficient+ guides(color=FALSE)
coefficient<-coefficient+ geom_hline(data=dataset, aes(yintercept=0),  col="grey", linetype="dashed", size=1)
coefficient


#######lag
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R lag.dta")

dataset$variable<-factor(dataset$variable, 
                         levels=c("Main","Price Outlier"), order=T) 

dataset$setting<-factor(dataset$setting, 
                         levels=c("Major analysis",
                                  "Current weather controlled",
                                  "Lagged weather separated",
                                  "Lagged weather summed"), order=T) 

coefficient<-ggplot()
coefficient<-coefficient+geom_point(data=dataset[which(dataset$coef=="c"),], aes(x=indicator, y=estimate*100, color=color), position = position_dodge(width = 0.5), size=2)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef!="c"),], aes(x=indicator, y=estimate*100, group=interaction(indicator), color=color), position = position_dodge(width = 0.5), size=1)
coefficient<-coefficient+facet_grid(variable~setting, scales = "free_x", space = "free_x", labeller = label_wrap_gen(20))
coefficient<-coefficient+theme_bw()+theme(axis.text.x = element_text(),
                                          text = element_text(size=25),
                                          legend.text=element_text(size=25),
                                          panel.grid.major = element_blank(),
                                          panel.grid.minor = element_blank(),
                                          strip.background = element_blank(),
                                          strip.placement = "outside",
                                          legend.position="bottom")
coefficient<-coefficient+labs(x=NULL,y ="Probability of being Energy Star Model, %", colour=NULL)
#coefficient<-coefficient+ guides(color=FALSE)
coefficient<-coefficient+ geom_hline(data=dataset, aes(yintercept=0),  col="grey", linetype="dashed", size=1)
coefficient


#######heterogeneous
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R heterogenous.dta")

dataset$group_c<-""
dataset$group_c[dataset$group==1]<-"Low"
dataset$group_c[dataset$group==2]<-"Medium"
dataset$group_c[dataset$group==3]<-"High"

dataset$group_c<-factor(dataset$group_c, 
                      levels=c("Low","Medium","High"), order=T) 

dataset$variable<-factor(dataset$variable, 
                         levels=c("State-level electricity price",
                                  "Background climate - CDD",
                                  "Background climate - HDD",
                                  "Median income",
                                  "% of population > bachelor",
                                  "% of white people",
                                  "Median age",
                                  "Median number of rooms",
                                  "Owner:Renter",
                                  "% of electricity as heating fuel",
                                  "Believe climate change happening",
                                  "Believe climate change harm US",
                                  "Worry about climate change",
                                  "Support renewable energy standards",
                                  "Support regulation of CO2",
                                  "Support Democratic Party"
                                  ), order=T) 

coefficient<-ggplot()
coefficient<-coefficient+geom_point(data=dataset[which(dataset$coef=="c"),], aes(x=group_c, y=estimate*100, color=id), position = position_dodge(width = 0.5), size=2)
#coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef=="c"),], aes(x=group_c, y=estimate*100, group=interaction(coef, variable)), size=1)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef!="c"),], aes(x=group_c, y=estimate*100, group=interaction(group, id), color=id), position = position_dodge(width = 0.5), size=1)
coefficient<-coefficient+facet_wrap(~variable, nrow=4)
coefficient<-coefficient+theme_bw()+theme(axis.text.x = element_text(),
                                          text = element_text(size=25),
                                          legend.text=element_text(size=25),
                                          panel.grid.major = element_blank(),
                                          panel.grid.minor = element_blank(),
                                          strip.background = element_blank(),
                                          strip.placement = "outside",
                                          legend.position="bottom")
coefficient<-coefficient+labs(x="Group",y ="Probability of being Energy Star Model, %", colour=NULL)
#coefficient<-coefficient+ guides(color=FALSE)
coefficient<-coefficient+ geom_hline(data=dataset, aes(yintercept=0),  col="grey", linetype="dashed", size=1)
coefficient




#######main telephone
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R main telephone.dta")

interval<-data.frame(id=c(1:19),
                     range=c("<=0","0-2","2-4","4-6","6-8","8-10","10-12","12-14","14-16","16-18","18-20", 
                             "20-22","22-24","24-26","26-28","28-30","30-32","32-34",">34"))

dataset<-merge(dataset, interval, by="id")

dataset$range<-factor(dataset$range, 
                      levels=c("<=0","0-2","2-4","4-6","6-8","8-10","10-12","12-14","14-16","16-18","18-20", 
                               "20-22","22-24","24-26","26-28","28-30","30-32","32-34",">34"), order=T) 

dataset$variable<-factor(dataset$variable, 
                         levels=c("Main","Price Outlier"), order=T) 

coefficient<-ggplot()
coefficient<-coefficient+geom_point(data=dataset[which(dataset$coef=="c"),], aes(x=range, y=est_*100, group=variable), size=2)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef=="c"),], aes(x=range, y=est_*100, group=interaction(coef, variable)), size=1)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef!="c"),], aes(x=range, y=est_*100, group=interaction(variable, id)), size=1)
coefficient<-coefficient+facet_wrap(~variable)
coefficient<-coefficient+theme_bw()+theme(axis.text.x = element_text(angle = 90, lineheight=0.5, hjust = 1, vjust=0.5),
                                          text = element_text(size=25),
                                          legend.text=element_text(size=25),
                                          panel.grid.major = element_blank(),
                                          panel.grid.minor = element_blank(),
                                          strip.background = element_blank(),
                                          strip.placement = "outside",
                                          legend.position="bottom")
coefficient<-coefficient+labs(x="Temperature",y ="Probability of being Energy Star Model, %", colour=NULL)
#coefficient<-coefficient+ guides(color=FALSE)
coefficient<-coefficient+ geom_hline(data=dataset, aes(yintercept=0),  col="grey", linetype="dashed", size=1)
coefficient


#######lag telephone
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R lag telephone.dta")

dataset$variable<-factor(dataset$variable, 
                         levels=c("Main","Price Outlier"), order=T) 

dataset$setting<-factor(dataset$setting, 
                        levels=c("Major analysis",
                                 "Current weather controlled",
                                 "Lagged weather separated",
                                 "Lagged weather summed"), order=T) 

coefficient<-ggplot()
coefficient<-coefficient+geom_point(data=dataset[which(dataset$coef=="c"),], aes(x=indicator, y=estimate*100, color=color), position = position_dodge(width = 0.5), size=2)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef!="c"),], aes(x=indicator, y=estimate*100, group=interaction(indicator), color=color), position = position_dodge(width = 0.5), size=1)
coefficient<-coefficient+facet_grid(variable~setting, scales = "free_x", space = "free_x", labeller = label_wrap_gen(20))
coefficient<-coefficient+theme_bw()+theme(axis.text.x = element_text(),
                                          text = element_text(size=25),
                                          legend.text=element_text(size=25),
                                          panel.grid.major = element_blank(),
                                          panel.grid.minor = element_blank(),
                                          strip.background = element_blank(),
                                          strip.placement = "outside",
                                          legend.position="bottom")
coefficient<-coefficient+labs(x=NULL,y ="Probability of being Energy Star Model, %", colour=NULL)
#coefficient<-coefficient+ guides(color=FALSE)
coefficient<-coefficient+ geom_hline(data=dataset, aes(yintercept=0),  col="grey", linetype="dashed", size=1)
coefficient
