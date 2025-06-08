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

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

## the file paths of your GVA and NVDRS data
GVA_path <- paste(c(current_dir, "GVA.csv"), collapse="/")
NVDRS_path <- paste(c(current_dir, "NVDRS.csv"), collapse="/")

GVA <- read_csv(GVA_path)
NVDRS <- read_csv(NVDRS_path)


################################################################################
########## make sure all data only includes incidents from 2014 to 2018, inclusive
################################################################################
#### for NVDRS, only keep if the year of the InjuryDate is after 2014
NVDRS_sub <- NVDRS[NVDRS$InjuryDate_year >= 2014, ]

#rename it back to NVDRS
NVDRS <- NVDRS_sub

################################################################################
########## make sure all data only includes incidents that resulted in at least one death
################################################################################
########## Fix number killed
names(GVA)[names(GVA) == "# Killed"] <- "NumKilled"
names(NVDRS)[names(NVDRS) == "VictimNumber"] <- "NumKilled"
GVA$NumKilled <- as.numeric(GVA$NumKilled) 
NVDRS$NumKilled <- as.numeric(NVDRS$NumKilled) 

GVA <- GVA[GVA$NumKilled > 0, ]

################################################################################
########## getting daysSinceStart variable 
################################################################################
startdate <- as.Date("01/01/2014","%m/%d/%Y")

GVA$date2 <- as.Date(GVA$Date, "%m/%d/%Y")
#GVA <- GVA[!is.na(GVA$date2), ] #GVA has no missing date values
GVA$date2 <- GVA$date2 %m+% (period(c(0,2000), c("weeks","years")))
GVA$daysSinceStart  <- difftime(GVA$date2,startdate ,units="days")
GVA$daysSinceStart <- as.numeric(GVA$daysSinceStart)


NVDRS$date2 <- as.Date(NVDRS$InjuryDate, "%m/%d/%Y")
NVDRS <- NVDRS[!is.na(NVDRS$date2), ] #ignore missing values
NVDRS$date2 <- as.Date(NVDRS$date2, "%m/%d/%Y")
NVDRS$date2 <- NVDRS$date2 %m+% (period(c(0,2000), c("weeks","years")))
NVDRS$daysSinceStart  <- difftime(NVDRS$date2,startdate ,units="days")
NVDRS$daysSinceStart <- as.numeric(NVDRS$daysSinceStart)


################################################################################
########## remove NVDRS incidents where Incident category is
########## single suicide or multiple suicide
################################################################################

NVDRS_no_single_suicide <- subset(NVDRS, IncidentCategory_c != "Single suicide")
NVDRS_no_multiple_suicides <- subset(NVDRS_no_single_suicide, IncidentCategory_c != "Multiple suicide")
NVDRS <- NVDRS_no_multiple_suicides

################################################################################
########## only keep NVDRS incidents where Weapon Type and Death Case 
########## involved some sort of firearm 
################################################################################

## find how many weapon types are used
unique(NVDRS$WeaponType1)
unique(NVDRS$WeaponType2)
unique(NVDRS$WeaponType3)

## only want rows where firearm or non-powder gun were used
NVDRS_weapon1 <- NVDRS %>% filter(grepl("Firearm|Non-powder gun", WeaponType1))
NVDRS_weapon2 <- NVDRS %>% filter(grepl("Firearm|Non-powder gun", WeaponType2))
NVDRS_weapon3 <- NVDRS %>% filter(grepl("Firearm|Non-powder gun", WeaponType3))
NVDRS_weaponsfixedtemp <- merge(NVDRS_weapon1, NVDRS_weapon2, all=TRUE)
NVDRS_weaponsfixed <- merge(NVDRS_weaponsfixedtemp, NVDRS_weapon3, all=TRUE)

## find out what are death causes
unique(NVDRS$DeathCause1)
unique(NVDRS$DeathCause2)
unique(NVDRS$DeathCause3)

## only want death causes that involve some sort of firearm
NVDRS_death1 <- NVDRS %>% filter(grepl("Firearm|gun|firearm|gunshot|rifle", DeathCause1))
NVDRS_death2 <- NVDRS %>% filter(grepl("Firearm|gun|firearm|gunshot|rifle", DeathCause2))
NVDRS_death3 <- NVDRS %>% filter(grepl("Firearm|gun|firearm|gunshot|rifle", DeathCause3))

NVDRS_deathfixedtemp <- merge(NVDRS_death1, NVDRS_death2, all=TRUE)
NVDRS_deathfixed <- merge(NVDRS_deathfixedtemp, NVDRS_death3, all=TRUE)

##merge the weapons and deaths
NVDRS_final <- merge(NVDRS_weaponsfixed, NVDRS_deathfixed, all = TRUE)

#set it back to our NVDRS name
NVDRS <- NVDRS_final


################################################################################
########## Data Variable Name Cleaning
########## variables used in fastLink must have the same variable name
################################################################################

########## Fix zip code
names(GVA)[names(GVA) == "Zip"] <- "InjuryZip"
## put 0's in front if the zip code only has 4 numbers
GVA$InjuryZip <- as.character(GVA$InjuryZip)
GVA <- GVA %>% mutate(InjuryZip = ifelse(nchar(GVA$InjuryZip)==4, paste0("0", GVA$InjuryZip), GVA$InjuryZip))
GVA$InjuryZip<- as.numeric(GVA$InjuryZip)

NVDRS$InjuryZip <- as.character(NVDRS$InjuryZip)
NVDRS <- NVDRS %>% mutate(InjuryZip = ifelse(nchar(NVDRS$InjuryZip)==4, paste0("0", NVDRS$InjuryZip), NVDRS$InjuryZip))
NVDRS$InjuryZip<- as.numeric(NVDRS$InjuryZip)

########## Fix state
names(GVA)[names(GVA) == "State...3"] <- "InjuryState"

########## Fix city
names(GVA)[names(GVA) == "City or county"] <- "InjuryCity"
NVDRS <- NVDRS %>% mutate(InjuryCity = sub(",.*", "", NVDRS$InjuryCityState) )



## double checking that variable types are what we want
names(GVA)
names(NVDRS)
class(GVA$InjuryZip)
class(NVDRS$InjuryZip)
class(GVA$daysSinceStart)
class(NVDRS$daysSinceStart)
class(GVA$InjuryCity)
class(NVDRS$InjuryCity)
class(GVA$NumKilled)
class(NVDRS$NumKilled)



################################################################################
########## State Cleaning
########## some states are not meaningfully represented in NVDRS and GVA
################################################################################
states_2014 <- c('Alaska', 'Colorado', 'Georgia', 'Kentucky', 'Maryland', 'Massachusetts', 'Michigan', 'New Jersey', 'New Mexico', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Virginia', 'Wisconsin')
states_2015 <- c('Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Georgia', 'Hawaii', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Wisconsin')
states_2016 <- c('Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Georgia', 'Hawaii', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'Wisconsin')
states_2017 <- c('Alaska', 'Arizona', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Georgia', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'District of Columbia')
states_2018 <- c('Alabama', 'Alaska', 'Arizona', 'Colorado', 'Connecticut', 'Delaware', 'Georgia', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Missouri', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Rhode Island', 'South Carolina', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'District of Columbia', 'California', 'Illinois', 'Pennsylvania')

GVA_fixed <- GVA[(GVA$daysSinceStart < 365 & GVA$InjuryState %in% states_2014) |
                     (GVA$daysSinceStart >= 365 & GVA$daysSinceStart < 730 & GVA$InjuryState %in% states_2015) |
                     (GVA$daysSinceStart >= 730 & GVA$daysSinceStart < 1096 & GVA$InjuryState %in% states_2016) |
                     (GVA$daysSinceStart >= 1096 & GVA$daysSinceStart < 1461 & GVA$InjuryState %in% states_2017) |
                     (GVA$daysSinceStart >= 1461 & GVA$daysSinceStart < 1826 & GVA$InjuryState %in% states_2018),]
GVA_2014 = GVA_fixed[GVA_fixed$daysSinceStart < 365, ]
GVA_2014_count = GVA_2014 %>% count(InjuryState)
GVA_2015 = GVA_fixed[GVA_fixed$daysSinceStart >= 365 & GVA_fixed$daysSinceStart < 730,]
GVA_2015_count = GVA_2015 %>% count(InjuryState)
GVA_2016 = GVA_fixed[GVA_fixed$daysSinceStart >= 730 & GVA_fixed$daysSinceStart < 1096,]
GVA_2016_count = GVA_2016 %>% count(InjuryState)
GVA_2017 = GVA_fixed[GVA_fixed$daysSinceStart >= 1096 & GVA_fixed$daysSinceStart < 1461,]
GVA_2017_count = GVA_2017 %>% count(InjuryState)
GVA_2018 = GVA_fixed[GVA_fixed$daysSinceStart >= 1461 & GVA_fixed$daysSinceStart < 1826,]
GVA_2018_count = GVA_2018 %>% count(InjuryState)

GVA <- GVA_fixed #name it back to GVA

NVDRS_fixed <- NVDRS[(NVDRS$daysSinceStart < 365 & NVDRS$InjuryState %in% states_2014) |
                     (NVDRS$daysSinceStart >= 365 & NVDRS$daysSinceStart < 730 & NVDRS$InjuryState %in% states_2015) |
                     (NVDRS$daysSinceStart >= 730 & NVDRS$daysSinceStart < 1096 & NVDRS$InjuryState %in% states_2016) |
                     (NVDRS$daysSinceStart >= 1096 & NVDRS$daysSinceStart < 1461 & NVDRS$InjuryState %in% states_2017) |
                     (NVDRS$daysSinceStart >= 1461 & NVDRS$daysSinceStart < 1826 & NVDRS$InjuryState %in% states_2018),]
NVDRS_2014 = NVDRS_fixed[NVDRS_fixed$daysSinceStart < 365, ]
NVDRS_2014_count = NVDRS_2014 %>% count(InjuryState)
NVDRS_2015 = NVDRS_fixed[NVDRS_fixed$daysSinceStart >= 365 & NVDRS_fixed$daysSinceStart < 730,]
NVDRS_2015_count = NVDRS_2015 %>% count(InjuryState)
NVDRS_2016 = NVDRS_fixed[NVDRS_fixed$daysSinceStart >= 730 & NVDRS_fixed$daysSinceStart < 1096,]
NVDRS_2016_count = NVDRS_2016 %>% count(InjuryState)
NVDRS_2017 = NVDRS_fixed[NVDRS_fixed$daysSinceStart >= 1096 & NVDRS_fixed$daysSinceStart < 1461,]
NVDRS_2017_count = NVDRS_2017 %>% count(InjuryState)
NVDRS_2018 = NVDRS_fixed[NVDRS_fixed$daysSinceStart >= 1461 & NVDRS_fixed$daysSinceStart < 1826,]
NVDRS_2018_count = NVDRS_2018 %>% count(InjuryState)

NVDRS <- NVDRS_fixed #name it back to NVDRS

################################################################################
########## save the cleaned data as RDS or CSV
################################################################################
saveRDS(GVA, "GVA_cleaned.RDS")
saveRDS(NVDRS, "NVDRS_cleaned.RDS")

write.csv(GVA, "GVA_cleaned.csv", row.names=FALSE)
write.csv(NVDRS, "NVDRS_cleaned.csv", row.names=FALSE)


