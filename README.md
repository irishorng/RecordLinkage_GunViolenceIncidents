# RecordLinkage_GunViolenceIncidents

Authors:
- Iris Horng
- Qishuo Yin
- Dylan Small

Contributing: William Chan, Jared Murray

For a detailed description of the method see:
- Probabilistic Record Linkage: An Application to Gun Homicides (in review)

Data:
- Gun Violence Archive
- National Violent Death Reporting System

# data_processing.R
Multiple steps were carried out to clean and prepare the data
- first enter the file paths of your GVA and NVDRS data respectively as set1 and set2_complete
- make sure the data only includes incidents from 2014 to 2018
  - our GVA dataset already only contained incidents from 2014 to 2018, so we only had to do this step for the NVDRS dataset
- we want to represent the date that the incident occurred as a numerical variable so that we can use this number for numerical comparing. We calculate the `daysSinceStart` variable, which tells you the number of days since January 1, 2014 that the incident occured.
  - for example, an incident that occured on January 1, 2014 would have `daysSinceStart=0`. An incident that occured on January 3, 2014 would have `daysSinceStart=2`
- NVDRS dataset contains all violent death incidents regardless if they resulted in a death by some sort of gun violence
  - We remove NVDRS incidents where the `IncidentCategory` is single suicide or multiple suicide because we only want to include incidents that involved homicides
  - We only keep NVDRS incidents where the `WeaponType` (ie. weapon used in the incident) is a Firearm or non-powder gun
  - We only keep NVDRS incidents where the `DeathCause` involves some sort of firearm, gun, or rifle
- Before, using the fastLink() method, the variables of interest that we would like to link on must have the same name. So we cleaned up some of the names
  - For GVA and NVDRS, the zip code is stored in `InjuryZip` and it must be type numeric
  - the state that the injury occurred in is stored as `InjuryState`
  - the city that the injury occurred in is stored as `InjuryCity`
  - the numbered killed in the incident is stored as `NumKilled`
- Finally, we can save the cleaned data as an RDS or csv

# apply_fastlink.R 
For a detailed description of fastLink and its installation, see Enamorado, Ted, Benjamin Fifield, and Kosuke Imai. 2017. fastLink: Fast Probabilistic Record Linkage with Missing Data. Version 0.6.

Notes:
- first, take your cleaned NVDRS and GVA files that you outputted as RDS files from data_processing.R, and put them as `set1_sub` and `set2_sub` respectively
- we blocked by state for computational efficiency, but you can block on any choice of variable by changing the `varnames` inside the `blockData()` function.
- `final_merged` will store all of the matches that are returned from the fastLink() method.
- fastLink has options to choose variables of interest that you would like to match on.
  - In `varnames`, you should list all the variables of interest.
  - In `stringdist.match`, it's recommended to list the variables that are strings (ie. words) from your variables of interest
  - In `numeric.match`, it's recommended to list the variables that are numeric (ie. numbers) from your variables of interest
- the for loop indicated by `for(i in 1:33)` should span from 1 to the number of blocks that you have.
  - To see how many blocks you have, run `names(blockstate_out)`. Then as an example, if you have 43 blocks, your for loop should say `for(i in 1:43)`
- if there is an error with running fastLink, it is most likely that one of the blocks does not have enough observations to carry out probabilistic record linkage, so you should create separate for loops to avoid that block.
  - In our data, we had a total of 43 blocks. However, blocks 34 and 40 did not have enough observations. So our for loops run from 1 to 33, then 35 to 39, then 41 to 43 (skipping blocks 34 and 40). 

# combining_online_data.R
Here, we combining GVA Standard Reports
From GVA's website (https://www.gunviolencearchive.org/reports), select which standard reports you would like to use to compare with your fastLink merged dataset. 
- download each of the standard reports and save them as csv files. You can then read each of the csv files and store them as `data1`, `data2`, etc.
- merge all of the data together into one file by doing `bind_rows(data1, data2)`
- save the merged file as an RDS file

# get_common_matches.R
Outputs:
- compare the collected GVA standard reports with your original GVA dataset to see common Incident IDs
- compare the collected GVA standard reports with your fastLink merged dataset to see common Incident IDs & return records from the fastLink merged dataset for those common Incident IDS
