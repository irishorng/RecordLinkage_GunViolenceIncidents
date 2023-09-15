
# installing the required libraries 
install.packages("plyr")
library(readxl)
library(tidyverse)
library(plyr)
library(dplyr)


################################################################################
########## put in file paths for all the csv files that you want to use
########## from the online GVA records
################################################################################
data1<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/childrenkilled.csv",header=TRUE,sep=",",fill=TRUE)
data2<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/officerinvolvedshooting.csv",header=TRUE,sep=",",fill=TRUE)
data3<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/school shootings.csv",header=TRUE,sep=",",fill=TRUE)
data4<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/teenskilled.csv",header=TRUE,sep=",",fill=TRUE)
data5<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/mass_shootings_2014.csv",header=TRUE,sep=",",fill=TRUE)
data6<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/mass_shootings_2015.csv",header=TRUE,sep=",",fill=TRUE)
data7<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/mass_shootings_2016.csv",header=TRUE,sep=",",fill=TRUE)
data8<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/mass_shootings_2017.csv",header=TRUE,sep=",",fill=TRUE)
data9<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/mass_shootings_2018.csv",header=TRUE,sep=",",fill=TRUE)
data10<-read.csv("C:/Users/chiufang/Documents/URPS/GVA_records/massshooting_allyears.csv",header=TRUE,sep=",",fill=TRUE)

## merging all the data together into one file
data_merged<-bind_rows(data1,data2)
data_merged2<-bind_rows(data_merged,data3)
data_merged3<-bind_rows(data_merged2,data4)
data_merged4<-bind_rows(data_merged3,data5)
data_merged5<-bind_rows(data_merged4,data6)
data_merged6<-bind_rows(data_merged5,data7)
data_merged7<-bind_rows(data_merged6,data8)
data_merged8<-bind_rows(data_merged7,data9)
data_merged9<-bind_rows(data_merged8,data10)

## save the merged file
saveRDS(data_merged, "GVA_online_combined.RDS")
