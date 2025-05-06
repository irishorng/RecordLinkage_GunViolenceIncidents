
# installing the required libraries 
install.packages("plyr")
library(readxl)
library(tidyverse)
library(plyr)
library(dplyr)

install.packages("stringr")               
library("stringr") 

################################################################################
########## put in file paths for all the csv files that you want to use
########## from the online GVA records
################################################################################
data1<-read.csv("childrenkilled.csv",header=TRUE,sep=",",fill=TRUE)
data2<-read.csv("officerinvolvedshooting.csv",header=TRUE,sep=",",fill=TRUE)
# data3<-read.csv("school shootings.csv",header=TRUE,sep=",",fill=TRUE) #data3 didn't have any observations in 2014-2018
# data4<-read.csv("teenskilled.csv",header=TRUE,sep=",",fill=TRUE) #data4 didn't have any observations in 2014-2018
data5<-read.csv("mass_shootings_2014.csv",header=TRUE,sep=",",fill=TRUE)
data6<-read.csv("mass_shootings_2015.csv",header=TRUE,sep=",",fill=TRUE)
data7<-read.csv("mass_shootings_2016.csv",header=TRUE,sep=",",fill=TRUE)
data8<-read.csv("mass_shootings_2017.csv",header=TRUE,sep=",",fill=TRUE)
data9<-read.csv("mass_shootings_2018.csv",header=TRUE,sep=",",fill=TRUE)
# data10<-read.csv("massshooting_allyears.csv",header=TRUE,sep=",",fill=TRUE) #data10 didn't have any observations in 2014-2018




################################################################################
########## cleaning the file paths to agree with our conditions
########## incidents occurred in select states in each year from 2014-2018
################################################################################
states_2014 <- c('Alaska', 'Colorado', 'Georgia', 'Kentucky', 'Maryland', 'Massachusetts', 'Michigan', 'New Jersey', 'New Mexico', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Virginia', 'Wisconsin')
states_2015 <- c('Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Georgia', 'Hawaii', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Wisconsin')
states_2016 <- c('Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Georgia', 'Hawaii', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'Wisconsin')
states_2017 <- c('Alaska', 'Arizona', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Georgia', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'District of Columbia')
states_2018 <- c('Alabama', 'Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Delaware', 'Georgia', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Missouri', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'District of Columbia', 'California', 'Illinois', 'Pennsylvania')

## str_sub is a function from the 'stringr' package
data1_fix <- data1[(str_sub(data1$Incident.Date,-4,-1) == "2014" & data1$State %in% states_2014) |
                     (str_sub(data1$Incident.Date,-4,-1) == "2015" & data1$State %in% states_2015 ) |
                     (str_sub(data1$Incident.Date,-4,-1) == "2016" & data1$State %in% states_2016) |
                     (str_sub(data1$Incident.Date,-4,-1) == "2017" & data1$State %in% states_2017) |
                     (str_sub(data1$Incident.Date,-4,-1) == "2018" & data1$State %in% states_2018), ]
data1_fix_kill <- data1_fix[data1_fix$X..Killed > 0, ]
data1 <- data1_fix_kill

data2_fix <- data2[(str_sub(data2$Incident.Date,-4,-1) == "2016" & data2$State %in% states_2016), ]
data2_fix_kill <- data2_fix[data2_fix$X..Killed > 0, ]
data2 <- data2_fix_kill

data5_fix <- data5[(str_sub(data5$Incident.Date,-4,-1) == "2014" & data5$State %in% states_2014), ]
data5_fix_kill <- data5_fix[data5_fix$X..Victims.Killed > 0 | data5_fix$X..Subjects.Suspects.Killed > 0 , ]
data5 <- data5_fix_kill

data6_fix <- data6[(str_sub(data6$Incident.Date,-4,-1) == "2015" & data6$State %in% states_2015), ]
data6_fix_kill <- data6_fix[data6_fix$X..Victims.Killed > 0 | data6_fix$X..Subjects.Suspects.Killed > 0 , ]
data6 <- data6_fix_kill

data7_fix <- data7[(str_sub(data7$Incident.Date,-4,-1) == "2016" & data7$State %in% states_2016), ]
data7_fix_kill <- data7_fix[data7_fix$X..Killed > 0 , ]
data7 <- data7_fix_kill

data8_fix <- data8[(str_sub(data8$Incident.Date,-4,-1) == "2017" & data8$State %in% states_2017), ]
data8_fix_kill <- data8_fix[data8_fix$X..Victims.Killed > 0 | data8_fix$X..Subjects.Suspects.Killed > 0 , ]
data8 <- data8_fix_kill

data9_fix <- data9[(str_sub(data9$Incident.Date,-4,-1) == "2018" & data9$State %in% states_2018), ]
data9_fix_kill <- data9_fix[data9_fix$X..Victims.Killed > 0 | data9_fix$X..Subjects.Suspects.Killed > 0 , ]
data9 <- data9_fix_kill


## merging all the data together into one file
data_merged<-bind_rows(data1,data2)
# data_merged2<-bind_rows(data_merged,data3)
# data_merged3<-bind_rows(data_merged2,data4)
data_merged4<-bind_rows(data_merged,data5)
data_merged5<-bind_rows(data_merged4,data6)
data_merged6<-bind_rows(data_merged5,data7)
data_merged7<-bind_rows(data_merged6,data8)
data_merged8<-bind_rows(data_merged7,data9)
# data_merged9<-bind_rows(data_merged8,data10)

GVA_online_combined <- data_merged8

## save the merged file
saveRDS(GVA_online_combined, "GVA_online_combined_fixed.RDS")
write.csv(GVA_online_combined, "GVA_online_combined_fixed.csv", row.names=FALSE)
