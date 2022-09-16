
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

dataset$variable[dataset$variable=="Main"] <- "(a) Main"
dataset$variable[dataset$variable=="Price Outlier"] <- "(b) Price Outlier"

dataset$variable<-factor(dataset$variable, 
                     levels=c("(a) Main","(b) Price Outlier"), order=T) 

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
coefficient<-coefficient+geom_hline(data=dataset, aes(yintercept=0),  col="grey", linetype="dashed", size=1)
coefficient

ggsave("figure_1.pdf",coefficient, width = 16.2, height=10, units="in", dpi=900)

write.csv(dataset,"figure_1.csv")


#######lag
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R lag.dta")

dataset$variable<-factor(dataset$variable, 
                         levels=c("Main","Price Outlier"), order=T) 

dataset$setting[dataset$setting=="Major analysis"] <- "(a) Major analysis"
dataset$setting[dataset$setting=="Current weather controlled"] <- "(b) Current weather controlled"
dataset$setting[dataset$setting=="Lagged weather separated"] <- "(c) Lagged weather separated"
dataset$setting[dataset$setting=="Lagged weather summed"] <- "(d) Lagged weather summed"

dataset$setting<-factor(dataset$setting, 
                         levels=c("(a) Major analysis",
                                  "(b) Current weather controlled",
                                  "(c) Lagged weather separated",
                                  "(d) Lagged weather summed"), order=T) 

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

ggsave("figure_2.pdf",coefficient, width = 16.2, height=10, units="in", dpi=900)

write.csv(dataset,"figure_2.csv")


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

dataset$variable[dataset$variable=="State-level electricity price"] <- "(a) State-level electricity price"
dataset$variable[dataset$variable=="Background climate - CDD"] <- "(b) Background climate - CDD"
dataset$variable[dataset$variable=="Background climate - HDD"] <- "(c) Background climate - HDD"
dataset$variable[dataset$variable=="Median income"] <- "(d) Median income"
dataset$variable[dataset$variable=="% of population > bachelor"] <- "(e) % of population > bachelor"
dataset$variable[dataset$variable=="% of White people"] <- "(f) % of White people"
dataset$variable[dataset$variable=="Median age"] <- "(g) Median age"
dataset$variable[dataset$variable=="Median number of rooms"] <- "(h) Median number of rooms"
dataset$variable[dataset$variable=="Owner:Renter"] <- "(i) Owner:Renter"
dataset$variable[dataset$variable=="% of electricity as heating fuel"] <- "(j) % of electricity as heating fuel"
dataset$variable[dataset$variable=="Believe climate change happening"] <- "(k) Believe climate change happening"
dataset$variable[dataset$variable=="Believe climate change harm US"] <- "(l) Believe climate change harm US"
dataset$variable[dataset$variable=="Worry about climate change"] <- "(m) Worry about climate change"
dataset$variable[dataset$variable=="Support renewable energy standards"] <- "(n) Support renewable energy standards"
dataset$variable[dataset$variable=="Support regulation of CO2"] <- "(o) Support regulation of CO2"
dataset$variable[dataset$variable=="Support Democratic Party"] <- "(p) Support Democratic Party"


dataset$variable<-factor(dataset$variable, 
                         levels=c("(a) State-level electricity price",
                                  "(b) Background climate - CDD",
                                  "(c) Background climate - HDD",
                                  "(d) Median income",
                                  "(e) % of population > bachelor",
                                  "(f) % of White people",
                                  "(g) Median age",
                                  "(h) Median number of rooms",
                                  "(i) Owner:Renter",
                                  "(j) % of electricity as heating fuel",
                                  "(k) Believe climate change happening",
                                  "(l) Believe climate change harm US",
                                  "(m) Worry about climate change",
                                  "(n) Support renewable energy standards",
                                  "(o) Support regulation of CO2",
                                  "(p) Support Democratic Party"
                                  ), order=T) 

coefficient<-ggplot()
coefficient<-coefficient+geom_point(data=dataset[which(dataset$coef=="c"),], aes(x=group_c, y=estimate*100, color=id), position = position_dodge(width = 0.5), size=2)
#coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef=="c"),], aes(x=group_c, y=estimate*100, group=interaction(coef, variable)), size=1)
coefficient<-coefficient+geom_line(data =dataset[which(dataset$coef!="c"),], aes(x=group_c, y=estimate*100, group=interaction(group, id), color=id), position = position_dodge(width = 0.5), size=1)
coefficient<-coefficient+facet_wrap(~variable, nrow=4)
coefficient<-coefficient+theme_bw()+theme(axis.text.x = element_text(),
                                          text = element_text(size=18),
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

ggsave("figure_3.pdf",coefficient, width = 16.2, height=10, units="in", dpi=900)

write.csv(dataset,"figure_3.csv")


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

dataset$variable[dataset$variable=="Main"] <- "(a) Main"
dataset$variable[dataset$variable=="Price Outlier"] <- "(b) Price Outlier"

dataset$variable<-factor(dataset$variable, 
                         levels=c("(a) Main","(b) Price Outlier"), order=T) 

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

write.csv(dataset,"figure_S2.csv")


#######lag telephone
setwd("C:/Users/sglph2/OneDrive - Cardiff University/Desktop/climate and air conditioner")

rm(list=ls())
cat("\014")

dataset<-read_dta("coefficient R lag telephone.dta")

dataset$variable<-factor(dataset$variable, 
                         levels=c("Main","Price Outlier"), order=T) 

dataset$setting[dataset$setting=="Major analysis"] <- "(a) Major analysis"
dataset$setting[dataset$setting=="Current weather controlled"] <- "(b) Current weather controlled"
dataset$setting[dataset$setting=="Lagged weather separated"] <- "(c) Lagged weather separated"
dataset$setting[dataset$setting=="Lagged weather summed"] <- "(d) Lagged weather summed"

dataset$setting<-factor(dataset$setting, 
                        levels=c("(a) Major analysis",
                                 "(b) Current weather controlled",
                                 "(c) Lagged weather separated",
                                 "(d) Lagged weather summed"), order=T) 

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

write.csv(dataset,"figure_S3.csv")
