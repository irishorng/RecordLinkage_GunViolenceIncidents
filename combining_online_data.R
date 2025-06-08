
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

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

create_path_name <- function(file, current_dir) {
  return(paste(c(current_dir, file), collapse = "/"))
}

## the file paths of your GVA and NVDRS data
childrenkilled_path <- create_path_name("childrenkilled.csv", current_dir)
officerinvolvedshooting_path <- create_path_name("officerinvolvedshooting.csv", current_dir)
# schoolshooting_path <- create_path_name("school shootings.csv", current_dir)
# teenskilled_path <- create_path_name("teenskilled.csv", current_dir)
mass_shootings_2014_path <- create_path_name("mass_shootings_2014.csv", current_dir)
mass_shootings_2015_path <- create_path_name("mass_shootings_2015.csv", current_dir)
mass_shootings_2016_path <- create_path_name("mass_shootings_2016.csv", current_dir)
mass_shootings_2017_path <- create_path_name("mass_shootings_2017.csv", current_dir)
mass_shootings_2018_path <- create_path_name("mass_shootings_2018.csv", current_dir)
# mass_shootings_allyears_path <- create_path_name("mass_shooting_allyears.csv", current_dir)

childrenkilled<-read.csv(childrenkilled_path,header=TRUE,sep=",",fill=TRUE) 
officerinvolved<-read.csv(officerinvolvedshooting_path,header=TRUE,sep=",",fill=TRUE)
# schoolshooting<-read.csv(schoolshooting_path,header=TRUE,sep=",",fill=TRUE) #schoolshooting didn't have any observations in 2014-2018
# teenskilled<-read.csv(teenskilled_path,header=TRUE,sep=",",fill=TRUE) #teenskilled didn't have any observations in 2014-2018
mass_shootings_2014<-read.csv(mass_shootings_2014_path,header=TRUE,sep=",",fill=TRUE)
mass_shootings_2015<-read.csv(mass_shootings_2015_path,header=TRUE,sep=",",fill=TRUE)
mass_shootings_2016<-read.csv(mass_shootings_2016_path,header=TRUE,sep=",",fill=TRUE)
mass_shootings_2017<-read.csv(mass_shootings_2017_path,header=TRUE,sep=",",fill=TRUE)
mass_shootings_2018<-read.csv(mass_shootings_2018_path,header=TRUE,sep=",",fill=TRUE)
# mass_shootings_allyears<-read.csv(mass_shooting_allyears_path,header=TRUE,sep=",",fill=TRUE) #mass_shootings_allyears didn't have any observations in 2014-2018


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
childrenkilled_fix <- childrenkilled[(str_sub(childrenkilled$Incident.Date,-4,-1) == "2014" & childrenkilled$State %in% states_2014) |
                     (str_sub(childrenkilled$Incident.Date,-4,-1) == "2015" & childrenkilled$State %in% states_2015 ) |
                     (str_sub(childrenkilled$Incident.Date,-4,-1) == "2016" & childrenkilled$State %in% states_2016) |
                     (str_sub(childrenkilled$Incident.Date,-4,-1) == "2017" & childrenkilled$State %in% states_2017) |
                     (str_sub(childrenkilled$Incident.Date,-4,-1) == "2018" & childrenkilled$State %in% states_2018), ]
childrenkilled_fix_kill <- childrenkilled_fix[childrenkilled_fix$X..Killed > 0, ]
childrenkilled <- childrenkilled_fix_kill

officerinvolved_fix <- officerinvolved[(str_sub(officerinvolved$Incident.Date,-4,-1) == "2016" & officerinvolved$State %in% states_2016), ]
officerinvolved_fix_kill <- officerinvolved_fix[officerinvolved_fix$X..Killed > 0, ]
officerinvolved <- officerinvolved_fix_kill

mass_shootings_2014_fix <- mass_shootings_2014[(str_sub(mass_shootings_2014$Incident.Date,-4,-1) == "2014" & mass_shootings_2014$State %in% states_2014), ]
mass_shootings_2014_fix_kill <- mass_shootings_2014_fix[mass_shootings_2014_fix$X..Victims.Killed > 0 | mass_shootings_2014_fix$X..Subjects.Suspects.Killed > 0 , ]
mass_shootings_2014 <- mass_shootings_2014_fix_kill

mass_shootings_2015_fix <- mass_shootings_2015[(str_sub(mass_shootings_2015$Incident.Date,-4,-1) == "2015" & mass_shootings_2015$State %in% states_2015), ]
mass_shootings_2015_fix_kill <- mass_shootings_2015_fix[mass_shootings_2015_fix$X..Victims.Killed > 0 | mass_shootings_2015_fix$X..Subjects.Suspects.Killed > 0 , ]
mass_shootings_2015 <- mass_shootings_2015_fix_kill

mass_shootings_2016_fix <- mass_shootings_2016[(str_sub(mass_shootings_2016$Incident.Date,-4,-1) == "2016" & mass_shootings_2016$State %in% states_2016), ]
mass_shootings_2016_fix_kill <- mass_shootings_2016_fix[mass_shootings_2016_fix$X..Killed > 0 , ]
mass_shootings_2016 <- mass_shootings_2016_fix_kill

mass_shootings_2017_fix <- mass_shootings_2017[(str_sub(mass_shootings_2017$Incident.Date,-4,-1) == "2017" & mass_shootings_2017$State %in% states_2017), ]
mass_shootings_2017_fix_kill <- mass_shootings_2017_fix[mass_shootings_2017_fix$X..Victims.Killed > 0 | mass_shootings_2017_fix$X..Subjects.Suspects.Killed > 0 , ]
mass_shootings_2017 <- mass_shootings_2017_fix_kill

mass_shootings_2018_fix <- mass_shootings_2018[(str_sub(mass_shootings_2018$Incident.Date,-4,-1) == "2018" & mass_shootings_2018$State %in% states_2018), ]
mass_shootings_2018_fix_kill <- mass_shootings_2018_fix[mass_shootings_2018_fix$X..Victims.Killed > 0 | mass_shootings_2018_fix$X..Subjects.Suspects.Killed > 0 , ]
mass_shootings_2018 <- mass_shootings_2018_fix_kill


## merging all the data together into one file
data_merged<-bind_rows(childrenkilled,officerinvolved)
# data_merged2<-bind_rows(data_merged,schoolshooting)
# data_merged3<-bind_rows(data_merged2,teenskilled)
data_merged4<-bind_rows(data_merged,mass_shootings_2014)
data_merged5<-bind_rows(data_merged4,mass_shootings_2015)
data_merged6<-bind_rows(data_merged5,mass_shootings_2016)
data_merged7<-bind_rows(data_merged6,mass_shootings_2017)
data_merged8<-bind_rows(data_merged7,mass_shootings_2018)
# data_merged9<-bind_rows(data_merged8,mass_shootings_allyears)

GVA_online_combined <- data_merged8

## save the merged file
saveRDS(GVA_online_combined, "GVA_online_combined_fixed.RDS")
write.csv(GVA_online_combined, "GVA_online_combined_fixed.csv", row.names=FALSE)
