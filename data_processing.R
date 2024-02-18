#install appropriate packages
install.packages(c("fastLink","xtable","tidyverse","ggthemes","gridExtra","grid","data.table","knitr","doParallel","parallel","lattice","stringdist","RecordLinkage","lubridate","chron"))
install.packages(c("fastLink","RecordLinkage"))
library(purrr)
library(dplyr)
library(fastLink)
library(lubridate)
library(chron)
library(tidyverse)
library(readr)
library(fastLink)

## enter the file paths of your GVA and NVDRS data respectively
# set1 <- read.csv("C:/Users/chiufang/Documents/URPS/RURPS/URPS_project3/GVA 2014 - 2018 with Zipcode (after Geocodio) (zip code fixed).csv", header=T, stringsAsFactors = FALSE)
set1 <- read_csv("C:/Users/chiufang/Documents/URPS/datasets/GVA 2014 - 2018 with Zipcode (after Geocodio) (zip code fixed).csv")
# set2_complete <- read.csv("C:/Users/chiufang/Documents/URPS/RURPS/URPS_project3/NVDRS_2014_to_2018_data (zip code fix).csv", header=T, stringsAsFactors = FALSE)
# set2_compared <- read.csv("C:/Users/chiufang/Documents/URPS/datasets/NVDRS_2014_to_2018_data (zip code fix).csv", header=T, stringsAsFactors = FALSE)
set2_complete <- read_csv("~/URPS/datasets/NVDRS_2014_to_2018_data (zip code fix).csv")
# for hpcc
# set1 <- read.csv("GVA 2014 - 2018 with Zipcode (after Geocodio) (zip code fixed).csv", header=T, stringsAsFactors = FALSE)
# set2 <- read.csv("NVDRS_2014_to_2018_data (zip code fix).csv", header=T, stringsAsFactors = FALSE)
# answer2 <- set2_complete %>% count(InjuryDate_year)

################################################################################
########## make sure all data only includes incidents from 2014 to 2018, inclusive
################################################################################
#### for NVDRS, only keep if the year of the InjuryDate is after 2014
set2_sub <- set2_complete[set2_complete$InjuryDate_year >= 2014, ]
# saveRDS(set2_sub, "NVDRS_2014_to_2018_data (zip code fix) (year fix).RDS") #if you want to save this NVDRS version

#rename it back to set2
set2 <- set2_sub

################################################################################
########## make sure all data only includes incidents that resulted in at least one death
################################################################################
########## Fix number killed
names(set1)[names(set1) == "# Killed"] <- "NumKilled"
names(set2)[names(set2) == "VictimNumber"] <- "NumKilled"
set1$NumKilled <- as.numeric(set1$NumKilled) 
set2$NumKilled <- as.numeric(set2$NumKilled) 

set1 <- set1[set1$NumKilled > 0, ]


################################################################################
########## getting daysSinceStart variable 
################################################################################
startdate <- as.Date("01/01/2014","%m/%d/%Y")

set1$date2 <- as.Date(set1$Date, "%m/%d/%Y")
#set2 <- set2[!is.na(set2$date2), ] #ignore missing values but set 1 has no missing date values
set1$date2 <- set1$date2 %m+% (period(c(0,2000), c("weeks","years")))
set1$daysSinceStart  <- difftime(set1$date2,startdate ,units="days")
set1$daysSinceStart <- as.numeric(set1$daysSinceStart)


set2$date2 <- as.Date(set2$InjuryDate, "%m/%d/%Y")
set2 <- set2[!is.na(set2$date2), ] #ignore missing values
set2$date2 <- as.Date(set2$date2, "%m/%d/%Y")
set2$date2 <- set2$date2 %m+% (period(c(0,2000), c("weeks","years")))
set2$daysSinceStart  <- difftime(set2$date2,startdate ,units="days")
set2$daysSinceStart <- as.numeric(set2$daysSinceStart)


################################################################################
########## remove NVDRS incidents where Incident category is
########## single suicide or multiple suicide
################################################################################

set2_remove1 <- subset(set2, IncidentCategory_c != "Single suicide")
set2_remove2 <- subset(set2_remove1, IncidentCategory_c != "Multiple suicide")
set2 <- set2_remove2

################################################################################
########## only keep NVDRS incidents where Weapon Type and Death Case 
########## involved some sort of firearm 
################################################################################

## find how many weapon types are used
unique(set2$WeaponType1)
unique(set2$WeaponType2)
unique(set2$WeaponType3)

## only want rows where firearm or non-powder gun were used
set2_1 <- set2 %>% filter(grepl("Firearm|Non-powder gun", WeaponType1))
set2_2 <- set2 %>% filter(grepl("Firearm|Non-powder gun", WeaponType2))
set2_3 <- set2 %>% filter(grepl("Firearm|Non-powder gun", WeaponType3))
set2_weaponsfixedtemp <- merge(set2_1, set2_2, all=TRUE)
set2_weaponsfixed <- merge(set2_weaponsfixedtemp, set2_3, all=TRUE)

## find out what are death causes
unique(set2$DeathCause1)
unique(set2$DeathCause2)
unique(set2$DeathCause3)

## only want death causes that involve some sort of firearm
set2_death1 <- set2 %>% filter(grepl("Firearm|gun|firearm|gunshot|rifle", DeathCause1))
set2_death2 <- set2 %>% filter(grepl("Firearm|gun|firearm|gunshot|rifle", DeathCause2))
set2_death3 <- set2 %>% filter(grepl("Firearm|gun|firearm|gunshot|rifle", DeathCause3))

set2_deathfixedtemp <- merge(set2_death1, set2_death2, all=TRUE)
set2_deathfixed <- merge(set2_deathfixedtemp, set2_death3, all=TRUE)

##merge the weapons and deaths
set2_final <- merge(set2_weaponsfixed, set2_deathfixed, all = TRUE)

#set it back to our set2 name
set2 <- set2_final


################################################################################
########## Data Variable Name Cleaning
########## variables used in fastLink must have the same variable name
################################################################################

########## Fix zip code
names(set1)[names(set1) == "Zip"] <- "InjuryZip"
## put 0's in front if the zip code only has 4 numbers
set1$InjuryZip <- as.character(set1$InjuryZip)
set1 <- set1 %>% mutate(InjuryZip = ifelse(nchar(set1$InjuryZip)==4, paste0("0", set1$InjuryZip), set1$InjuryZip))
set1$InjuryZip<- as.numeric(set1$InjuryZip)

set2$InjuryZip <- as.character(set2$InjuryZip)
set2 <- set2 %>% mutate(InjuryZip = ifelse(nchar(set2$InjuryZip)==4, paste0("0", set2$InjuryZip), set2$InjuryZip))
set2$InjuryZip<- as.numeric(set2$InjuryZip)

########## Fix state
names(set1)[names(set1) == "State...3"] <- "InjuryState"

########## Fix city
names(set1)[names(set1) == "City or county"] <- "InjuryCity"
set2 <- set2 %>% mutate(InjuryCity = sub(",.*", "", set2$InjuryCityState) )



## double checking that variable types are what we want
names(set1)
names(set2)
class(set1$InjuryZip)
class(set2$InjuryZip)
class(set1$daysSinceStart)
class(set2$daysSinceStart)
class(set1$InjuryCity)
class(set2$InjuryCity)
class(set1$NumKilled)
class(set2$NumKilled)



################################################################################
########## State Cleaning
########## some states are not meaningfully represented in NVDRS and GVA
################################################################################
states_2014 <- c('Alaska', 'Colorado', 'Georgia', 'Kentucky', 'Maryland', 'Massachusetts', 'Michigan', 'New Jersey', 'New Mexico', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Virginia', 'Wisconsin')
states_2015 <- c('Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Georgia', 'Hawaii', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Wisconsin')
states_2016 <- c('Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Georgia', 'Hawaii', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'Wisconsin')
states_2017 <- c('Alaska', 'Arizona', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Georgia', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'District of Columbia')
states_2018 <- c('Alabama', 'Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Delaware', 'Georgia', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Missouri', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'District of Columbia', 'California', 'Illinois', 'Pennsylvania')

set1_fixed <- set1[(set1$daysSinceStart < 365 & set1$InjuryState %in% states_2014) |
                     (set1$daysSinceStart >= 365 & set1$daysSinceStart < 730 & set1$InjuryState %in% states_2015) |
                     (set1$daysSinceStart >= 730 & set1$daysSinceStart < 1096 & set1$InjuryState %in% states_2016) |
                     (set1$daysSinceStart >= 1096 & set1$daysSinceStart < 1461 & set1$InjuryState %in% states_2017) |
                     (set1$daysSinceStart >= 1461 & set1$daysSinceStart < 1826 & set1$InjuryState %in% states_2018),]
set1_2014 = set1_fixed[set1_fixed$daysSinceStart < 365, ]
set1_2014_count = set1_2014 %>% count(InjuryState)
set1_2015 = set1_fixed[set1_fixed$daysSinceStart >= 365 & set1_fixed$daysSinceStart < 730,]
set1_2015_count = set1_2015 %>% count(InjuryState)
set1_2016 = set1_fixed[set1_fixed$daysSinceStart >= 730 & set1_fixed$daysSinceStart < 1096,]
set1_2016_count = set1_2016 %>% count(InjuryState)
set1_2017 = set1_fixed[set1_fixed$daysSinceStart >= 1096 & set1_fixed$daysSinceStart < 1461,]
set1_2017_count = set1_2017 %>% count(InjuryState)
set1_2018 = set1_fixed[set1_fixed$daysSinceStart >= 1461 & set1_fixed$daysSinceStart < 1826,]
set1_2018_count = set1_2018 %>% count(InjuryState)

set1 <- set1_fixed #name it back to set1

set2_fixed <- set2[(set2$daysSinceStart < 365 & set2$InjuryState %in% states_2014) |
                     (set2$daysSinceStart >= 365 & set2$daysSinceStart < 730 & set2$InjuryState %in% states_2015) |
                     (set2$daysSinceStart >= 730 & set2$daysSinceStart < 1096 & set2$InjuryState %in% states_2016) |
                     (set2$daysSinceStart >= 1096 & set2$daysSinceStart < 1461 & set2$InjuryState %in% states_2017) |
                     (set2$daysSinceStart >= 1461 & set2$daysSinceStart < 1826 & set2$InjuryState %in% states_2018),]
set2_2014 = set2_fixed[set2_fixed$daysSinceStart < 365, ]
set2_2014_count = set2_2014 %>% count(InjuryState)
set2_2015 = set2_fixed[set2_fixed$daysSinceStart >= 365 & set2_fixed$daysSinceStart < 730,]
set2_2015_count = set2_2015 %>% count(InjuryState)
set2_2016 = set2_fixed[set2_fixed$daysSinceStart >= 730 & set2_fixed$daysSinceStart < 1096,]
set2_2016_count = set2_2016 %>% count(InjuryState)
set2_2017 = set2_fixed[set2_fixed$daysSinceStart >= 1096 & set2_fixed$daysSinceStart < 1461,]
set2_2017_count = set2_2017 %>% count(InjuryState)
set2_2018 = set2_fixed[set2_fixed$daysSinceStart >= 1461 & set2_fixed$daysSinceStart < 1826,]
set2_2018_count = set2_2018 %>% count(InjuryState)

set2 <- set2_fixed #name it back to set2

################################################################################
########## save the cleaned data as RDS or CSV
################################################################################
saveRDS(set1, "GVA_cleaned6.RDS")
saveRDS(set2, "NVDRS_cleaned6.RDS")

write.csv(set1, "GVA_cleaned6.csv", row.names=FALSE)
write.csv(set2, "NVDRS_cleaned6.csv", row.names=FALSE)


