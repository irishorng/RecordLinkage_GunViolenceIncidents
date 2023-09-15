

## enter the cleaned datasets for NVDRS and GVA respectively
set1_sub <-readRDS("NVDRS_cleaned.RDS")
set2_sub <-readRDS("GVA_cleaned.RDS")

# ## block by State for efficiency
blockstate_out <- blockData(set1_sub,
                            set2_sub,
                            varnames = "InjuryState")
names(blockstate_out) #see how many blocks there are

final_merged <- list() #create variable for our returned matches

################################################################################
################################################################################
########## USING FASTLINK FUNCTION
################################################################################
################################################################################

## block 34 doesn't run because it only has one observation
for (i in 1:33) {
  set1_block_i <- set1_sub[blockstate_out[[i]]$dfA.inds,]
  set2_block_i <- set2_sub[blockstate_out[[i]]$dfB.inds,]
  temp_out_block_i <- fastLink(
    set1_block_i, set2_block_i,
    varnames = c("InjuryCity", "daysSinceStart", "NumKilled", "InjuryZip"),
    stringdist.match = "InjuryCity",
    numeric.match = c("daysSinceStart", "NumKilled", "InjuryZip")
  )
  summary(temp_out_block_i)
  
  data_name = paste(c("combined_data", i), collapse = "_")
  data_name <- getMatches(set1_block_i, set2_block_i, temp_out_block_i, threshold.match = 0.5, combine.dfs=TRUE)
  
  final_merged <- merge(final_merged, data_name,all=TRUE)
}

## block 40 doesn't run because it only has one observation
for (i in 35:39) {
  set1_block_i <- set1_sub[blockstate_out[[i]]$dfA.inds,]
  set2_block_i <- set2_sub[blockstate_out[[i]]$dfB.inds,]
  temp_out_block_i <- fastLink(
    set1_block_i, set2_block_i,
    varnames = c("InjuryCity", "daysSinceStart", "NumKilled", "InjuryZip"),
    stringdist.match = "InjuryCity",
    numeric.match = c("daysSinceStart", "NumKilled", "InjuryZip")
  )
  summary(temp_out_block_i)
  
  data_name = paste(c("combined_data", i), collapse = "_")
  data_name <- getMatches(set1_block_i, set2_block_i, temp_out_block_i, threshold.match = 0.5, combine.dfs=TRUE)
  
  final_merged <- merge(final_merged, data_name,all=TRUE)
}

for (i in 41:43) {
  set1_block_i <- set1_sub[blockstate_out[[i]]$dfA.inds,]
  set2_block_i <- set2_sub[blockstate_out[[i]]$dfB.inds,]
  temp_out_block_i <- fastLink(
    set1_block_i, set2_block_i,
    varnames = c("InjuryCity", "daysSinceStart", "NumKilled", "InjuryZip"),
    stringdist.match = "InjuryCity",
    numeric.match = c("daysSinceStart", "NumKilled", "InjuryZip")
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
