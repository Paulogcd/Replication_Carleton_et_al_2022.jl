# This file is dedicated to the replication of the parts A to C of the file creating the figure 1 of the article. 
# This is the equivalent of: 
# carleton_mortality_2022/1_estimation/3_regressions/3_age_spec_interacted/Figure_I_array_plots.do

# Loading the required packages in Julia: 
using Statistics
using CategoricalArrays
using CSV
using DataFrames
using ReadStatTables

#______________________Particular notes______________________: 
# We tried to carefully comment each step.
# The original STATA code is always preceeded by three "#" symbols: ###.
# GC.gc() is the garbage collector command in Julia.
# It will allow us to have less memory used while compiling and running the package.
# varinfo() allows to check all the variables currently used in Julia.
# It appears several times throughout the code in comments, due to previous memory checks.


### In parts A and B, the authors set some variables for the rest of the code. 
### STATA:
### PART A. Initializing
### PART B. Toggles 

matsize = 10_000
maxvar = 32_700

ycommon = 1

a1_y = 7
a2_y = 2.5
a3_y = 35
a_x = -8
x_min = -5
x_max = 40
x_int = 10

yclip = 1
yclipmin_a1 = -2
yclipmin_a2 = -2
yclipmin_a3 = -20
yclipmax_a1 = 8
yclipmax_a2 = 3
yclipmax_a3 = 40
o = 4 

suffix = ""

### STATA: 
#### PART C. Prepare Dataset
### use "$data_dir/3_final/global_mortality_panel_covariates.dta", clear

# !!! Caution : this file weights 2.6 Gb !!!
df = DataFrame(ReadStatTables.readstat("0_input/final_data/global_mortality_panel_covariates.dta"))


# To obtain the french subset of the data, we could run: 
# df_fr = filter(row -> row.adm0 == "France", df)
# varinfo()

### Here, the authors generate terciles of income and tmean.

### STATA:
### tempfile MORTALITY_TEMP
### save "`MORTALITY_TEMP'", replace
### use `MORTALITY_TEMP', clear
### collapse (mean) loggdppc_adm1_avg lr_tavg_GMFD_adm1_avg, by(adm1_code)

# df.loggdppc_adm1_avg
# df.lr_tavg_GMFD_adm1_avg

# Here, to collapse the data by adm1_code, calculating means, we can do:
df_collapsed = combine(groupby(df, :adm1_code), 
    :loggdppc_adm1_avg => mean => :loggdppc_adm1_avg_mean,
    :lr_tavg_GMFD_adm1_avg => mean => :lr_tavg_GMFD_adm1_avg_mean
)

# varinfo()

### STATA:
### xtile ytile = loggdppc_adm1_avg, nq(3)
### forval terc = 1/2{
###     sum loggdppc_adm1_avg if ytile == `terc'
###     loc yc`terc' = r(max)
### }

# df_collapsed
# in Julia : 
# Calculate tercile cut points
ytile_cut_points = quantile(df_collapsed.loggdppc_adm1_avg_mean, [0, 1/3, 2/3, 1])
# Assign terciles
df_collapsed[!, :ytile] = cut(df_collapsed.loggdppc_adm1_avg_mean, ytile_cut_points, labels=1:3, extend=true)
# Calculate maximum values for the first two terciles
yc1 = maximum(df_collapsed.loggdppc_adm1_avg_mean[df_collapsed.ytile .== 1])
yc2 = maximum(df_collapsed.loggdppc_adm1_avg_mean[df_collapsed.ytile .== 2])
yc3 = maximum(df_collapsed.loggdppc_adm1_avg_mean[df_collapsed.ytile .== 3])
# Here, we have less information compared to the STATA version.
# varinfo()

### STATA:
### xtile ttile = lr_tavg_GMFD_adm1_avg, nq(3)
###     forval terc = 1/2{
###     sum lr_tavg_GMFD_adm1_avg if ttile == `terc'
###     loc tc`terc' = r(max)
### }

# Calculate tercile cut points
ttile_cut_points = quantile(df_collapsed.lr_tavg_GMFD_adm1_avg_mean, [0, 1/3, 2/3, 1])
# Assign terciles
df_collapsed[!, :ttile] = cut(df_collapsed.lr_tavg_GMFD_adm1_avg_mean, ttile_cut_points, labels=1:3, extend=true)
# Calculate maximum values for the first two terciles
tc1 = maximum(df_collapsed.lr_tavg_GMFD_adm1_avg_mean[df_collapsed.ttile .== 1])
tc2 = maximum(df_collapsed.lr_tavg_GMFD_adm1_avg_mean[df_collapsed.ttile .== 2])

### STATA:
### keep adm1_code ytile ttile
### tempfile tercile
### save "`tercile'", replace

# Keep only the necessary columns
df_tercile = df_collapsed[:, [:adm1_code, :ytile, :ttile]]
# 9.40 Mb

### STATA:
### *generating tercile cutoff values
### use `MORTALITY_TEMP', clear
### merge m:1 adm1_code using "`tercile'"
### drop if ytile==.
### collapse (mean) loggdppc_adm1_avg lr_tavg_GMFD_adm1_avg, by(ytile ttile)

# The following is not done due to computational requirements.
# We simply do not have enough computation power.
## # !!! Perform operations in chunks !!!
## 
## # Initialisation : 
## # Define the chunk size
## chunk_size = 10
## merged_df = DataFrame()
## tmp = DataFrame()
## # Create chunks by partitioning the DataFrame
## chunks = Iterators.partition(eachrow(df), chunk_size)
## total_chunks = ceil(Int, nrow(df) / chunk_size)
## 
## # merge(df, df_tercile, on = :adm1_code, makeunique=true)
## 
## # Simple version (without multithreading)
## function one_merge(index_chunk,chunk)
##     chunk_df = DataFrame(chunk)
##     tmp = leftjoin(chunk_df, df_tercile, on = :adm1_code, makeunique=true)
##     println("Processing chunk with ", nrow(chunk_df), " rows")
##     println("Chunk number: ", index_chunk)
##     append!(merged_df,tmp)
##     tmp = nothing
##     GC.gc()
## end
## 
## for (index_chunk,chunk) in enumerate(chunks)
##         @time begin one_merge(index_chunk,chunk) end
##     if index_chunk == 1000
##        break
##     end
## end
## # The result will be stored in merged_df

### !!!
# This step takes too much time if done on the entire dataframe. 
# Therefore, we chose to focus on French data: 
### !!!

# df.adm1_code

# df_fr.ytile

# Step 1: Merge df with df_tercile on adm1_code
df_merged = innerjoin(df, df_tercile, on=:adm1_code, makeunique = true) 
# Step 2: Drop rows where ytile is missing
df_merged = dropmissing(df_merged, :ytile)

### collapse (mean) loggdppc_adm1_avg lr_tavg_GMFD_adm1_avg, by(ytile ttile)

# Step 3: Collapse the data by calculating the mean of loggdppc_adm1_avg and lr_tavg_GMFD_adm1_avg
# for each combination of ytile and ttile
df_collapsed = combine(groupby(df_merged, [:ytile, :ttile]),
    :loggdppc_adm1_avg => mean => :loggdppc_adm1_avg_mean,
    :lr_tavg_GMFD_adm1_avg => mean => :lr_tavg_GMFD_adm1_avg_mean
)
# Here, we have slightly different results compared to the STATA output. 

### sort ttile
### by ttile: egen max_lr_tavg_GMFD_adm1_avg = max(lr_tavg_GMFD_adm1_avg)
### local T1 = max_lr_tavg_GMFD_adm1_avg[1]
### local T2 = max_lr_tavg_GMFD_adm1_avg[4]
### local T3 = max_lr_tavg_GMFD_adm1_avg[7]

sort!(df_collapsed, :ttile)

# Calculate the maximum lr_tavg_GMFD_adm1_avg within each ttile group
df_collapsed_2 = combine(groupby(df_merged, :ttile),
                       :lr_tavg_GMFD_adm1_avg => maximum => :max_lr_tavg_GMFD_adm1_avg)


df_test = leftjoin(df_collapsed,df_collapsed_2,on=:ttile,makeunique=true)
# Here, the threshholds are a it amplified.
# From 9,13,22, we get 10,15,28. 

# Former version, kept for the record:
# Extract the maximum values for specific indices, if they exist
# T1 = nrow(df_collapsed_2) >= 1 ? df_collapsed_2[1, :max_lr_tavg_GMFD_adm1_avg] : missing
# T2 = nrow(df_collapsed_2) >= 4 ? df_collapsed_2[4, :max_lr_tavg_GMFD_adm1_avg] : missing
# T3 = nrow(df_collapsed) >= 7 ? df_collapsed[7, :max_lr_tavg_GMFD_adm1_avg] : missing

### sort ytile
### by ytile: egen max_loggdppc_adm1_avg = max(loggdppc_adm1_avg)
### local Y1 = max_loggdppc_adm1_avg[1]
### local Y2 = max_loggdppc_adm1_avg[4]
### local Y3 = max_loggdppc_adm1_avg[7]

sort!(df_test, :ytile)

# Calculate the maximum loggdppc_adm1_avg within each ytile group
df_collapsed_3 = combine(groupby(df_test, :ytile),
                       :loggdppc_adm1_avg_mean => maximum => :max_loggdppc_adm1_avg_mean)
# The values are closer this time.

results_part_c = leftjoin(df_test,df_collapsed_3,on=:ytile)
# We have almost perfectly identic results.

# Former version, kept for the record:
# Extract the maximum values for specific indices, if they exist
# Y1 = nrow(df_collapsed) >= 1 ? df_collapsed[1, :max_loggdppc_adm1_avg] : missing
# Y2 = nrow(df_collapsed) >= 4 ? df_collapsed[4, :max_loggdppc_adm1_avg] : missing
# Y3 = nrow(df_collapsed) >= 7 ? df_collapsed[7, :max_loggdppc_adm1_avg] : missing

varinfo()

print("Figure 2: Parts A-C done.")
