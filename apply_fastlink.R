library(dplyr)
library(fastLink)


# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

## the file paths of your GVA and NVDRS data
GVA_path <- paste(c(current_dir, "data/GVA_cleaned.RDS"), collapse="/")
NVDRS_path <- paste(c(current_dir, "data/NVDRS_cleaned.RDS"), collapse="/")

NVDRS <-readRDS(NVDRS_path) 
GVA <-readRDS(GVA_path) 

blockstate_out <- blockData(NVDRS, 
                            GVA, 
                            varnames = "InjuryState") 
names(blockstate_out) #see how many blocks there are
final_merged <- list() #create variable for our returned matches


################################################################################
################################################################################
########## USING FASTLINK FUNCTION
################################################################################
################################################################################

for (i in 1:41) {
  set1_block_i <- set1_sub[blockstate_out[[i]]$dfA.inds,]
  set2_block_i <- set2_sub[blockstate_out[[i]]$dfB.inds,]
  temp_out_block_i <- fastLink(
    set1_block_i, set2_block_i,
    varnames = c("InjuryCity", "daysSinceStart", "NumKilled", "InjuryZip"),
    stringdist.match = "InjuryCity",
    numeric.match = c("daysSinceStart", "NumKilled", "InjuryZip"),
    dedupe.matches=TRUE
  )
  summary(temp_out_block_i)
  
  data_name = paste(c("combined_data", i), collapse = "_")
  data_name <- getMatches(set1_block_i, set2_block_i, temp_out_block_i, threshold.match = 0.5, combine.dfs=TRUE)
  
  final_merged <- merge(final_merged, data_name,all=TRUE)
  
}

# ################################################################################
# ########## saving the merged dataset as RDS or CSV
# ################################################################################
saveRDS(final_merged, "final_merged.RDS")
write.csv(final_merged, "final_merged.csv", row.names=FALSE)
