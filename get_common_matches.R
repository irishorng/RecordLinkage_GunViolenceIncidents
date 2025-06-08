
################
#setting up our data
#################
# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

## your original GVA dataset
GVA_path <- paste(c(current_dir, "GVA.csv"), collapse="/")
our_GVA <- read.csv(GVA_path)

ourdata <- as.list(our_GVA$Incident.ID)

## the single merged file of all data from GVA online reports gotten
## resulting from running combining_online_data.R
online_records_path <- paste(c(current_dir, "GVA_online_combined.csv"), collapse="/")
online_records <- read.csv(online_records_path)
onlinedata <- as.list(online_records$Incident.ID)

## the GVA and NVDRS matches gotten
## resulting from running apply_fastlink.R
merged_path <- paste(c(current_dir, "final_merged.csv"), collapse="/")
merged <- read.csv(merged_path)
our_merged <- as.list(merged$Incident.ID)

################
#seeing out of our original GVA dataset, how many are also in their online records
#################
## incident IDs that are in our original GVA dataset and the GVA online reports
matched <- intersect(ourdata, onlinedata) #1235
## output the IDs of those matches
matched_vector <- unlist(matched)
our_GVA_filtered <- our_GVA[our_GVA$Incident.ID %in% matched_vector,]
online_records_filtered <- online_records[online_records$Incident.ID %in% matched_vector,]


################
#seeing out of our GVA and NVDRS merged dataset, how many are also in their online records
#################
## incident IDs that are in the merged dataset and the GVA online reports
merged_matches <- intersect(our_merged, onlinedata) 

## using the ids that we already know exist in the online records, see which of our merged matches have that id
## multiple of the same id could appear in our merged dataset
merged_keep_matches <- merged[merged$Incident.ID %in% merged_matches,] 
merged_keep_matches$IncidentReport <- sub("^", "https://www.gunviolencearchive.org/incident/", merged_keep_matches$Incident.ID)
merged_keep_matches <- merged_keep_matches %>% relocate(IncidentReport) #764


## optional: put incident id and date to the front so we can see more obviously when the data is outputted in excel
merged_move_to_front <- merged_keep_matches %>% relocate(Incident.ID) #Incident.ID is from the GVA data
merged_date_to_front <- merged_move_to_front %>% relocate(Date)

merged_keep_matches <- merged_date_to_front

################
#save the file, this can be used for manual verification
#################
write.csv(merged_keep_matches, "final_merged_with_GVA_online_records.csv", row.names=FALSE)
