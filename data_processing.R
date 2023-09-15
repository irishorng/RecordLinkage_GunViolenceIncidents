install.packages(c("fastLink","xtable","tidyverse","ggthemes","gridExtra","grid","data.table","knitr","doParallel","parallel","lattice","stringdist","RecordLinkage","lubridate","chron"))
install.packages(c("fastLink","RecordLinkage"))
library(purrr)
library(dplyr)
library(fastLink)
library(lubridate)
library(chron)
library(tidyverse)
library(fastLink)

## enter the file paths of your GVA and NVDRS data respectively
set1 <- read.csv("C:/Users/chiufang/Documents/URPS/RURPS/URPS_project3/GVA 2014 - 2018 with Zipcode (after Geocodio) (zip code fixed).csv", header=T, stringsAsFactors = FALSE)
set2_complete <- read.csv("C:/Users/chiufang/Documents/URPS/RURPS/URPS_project3/NVDRS_2014_to_2018_data (zip code fix).csv", header=T, stringsAsFactors = FALSE)

# for hpcc
# set1 <- read.csv("GVA 2014 - 2018 with Zipcode (after Geocodio) (zip code fixed).csv", header=T, stringsAsFactors = FALSE)
# set2 <- read.csv("NVDRS_2014_to_2018_data (zip code fix).csv", header=T, stringsAsFactors = FALSE)


################################################################################
########## make sure all data only includes incidents from 2014 to 2018, inclusive
################################################################################
#### for NVDRS, only keep if the year of the InjuryDate is after 2014
set2_sub <- set2_complete[set2_complete$InjuryDate_year >= 2014, ]
# saveRDS(set2_sub, "NVDRS_2014_to_2018_data (zip code fix) (year fix).RDS") #if you want to save this NVDRS version

#rename it back to set2
set2 <- set2_sub

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
########## Data Cleaning
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
names(set1)[names(set1) == "State"] <- "InjuryState"

########## Fix city
names(set1)[names(set1) == "City.or.county"] <- "InjuryCity"
set2 <- set2 %>% mutate(InjuryCity = sub(",.*", "", set2$InjuryCityState) )

########## Fix number killed
names(set1)[names(set1) == "X..Killed"] <- "NumKilled"
names(set2)[names(set2) == "VictimNumber"] <- "NumKilled"
set1$NumKilled <- as.numeric(set1$NumKilled) 
set2$NumKilled <- as.numeric(set2$NumKilled) 

## double checking that variable types are what we want
names(set1)
names(set2)
class(set1$InjuryZip)
class(set2$InjuryZip)
class(set1$daysSinceStart)
class(set2$daysSinceStart)
class(set1$InjuryCity)
class(set2$InjuryCity)



################################################################################
########## save the cleaned data as RDS or CSV
################################################################################
saveRDS(set1, "GVA_cleaned.RDS")
saveRDS(set2, "NVDRS_cleaned.RDS")

write.csv(set1, "GVA_cleaned.csv", row.names=FALSE)
write.csv(set2, "NVDRS_cleaned.csv", row.names=FALSE)


