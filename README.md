# RecordLinkage_GunViolenceIncidents

Authors:
- Iris Horng
- Qishuo Yin
- Dylan Small
Contributing: Jared Murray, William Chan, 

For a detailed description of the method see:
-in review

Data:
- Gun Violence Archive
- National Violent Death Reporting System

# Data Processing

# Using fastLink()
For a detailed description of fastLink and its installation, see Enamorado, Ted, Benjamin Fifield, and Kosuke Imai. 2017. fastLink: Fast Probabilistic Record Linkage with Missing Data. Version 0.6.

Notes:
- we blocked by state for computational efficiency, but you can block on any choice of variable.
- fastLink has options to choose variables of interest that you would like to match on.
- the for loop should span from 1 to the number of blocks that you have. 
- if there is an error with running fastLink, it is most likely that one of the blocks does not have enough observations to carry out probabilistic record linkage, so you should create separate for loops to avoid that block.

# Combining GVA Standard Reports
From GVA's website (https://www.gunviolencearchive.org/reports), select which standard reports you would like to use to compare with your fastLink merged dataset. 

# Get Common Matches
Outputs:
- compare the collected GVA standard reports with your original GVA dataset to see common Incident IDs
- compare the collected GVA standard reports with your fastLink merged dataset to see common Incident IDs & return records from the fastLink merged dataset for those common Incident IDS
