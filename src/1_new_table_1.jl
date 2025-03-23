
# This file is dedicated to reproducing the first table of descriptive statistics of the article.
# It is the equivalent of the "carleton_mortality_2022/1_estimation/2_summary_statistics/Table_I_summary_stats.do" file of the original replication package.


#______________________Particular notes______________________: 
# We tried to carefully comment each step.
# The original STATA code is always preceeded by three "#" symbols: ###.
#
# GC.gc() is the garbage collector command in Julia.
# It will allow us to have less memory used while compiling and running the package.
#
# varinfo() allows to check all the variables currently used in Julia.
# It appears several times in comments throughout the code, due to memory checks during the development of the package.

# Loading the required packages in Julia: 
#  using Pkg 
using ReadStatTables
using DataFrames
using Statistics
#  using StatsBase
#  using Latexify
#  using Base.GC
#  using Weave

### use "$DB/0_data_cleaning/3_final/global_mortality_panel"
df = DataFrame(ReadStatTables.readstat("0_input/final_data/global_mortality_panel_public.dta"))
    # Caution: this dataset weights more than 2 Gb.

### PART 1. Generate variables for stats

# A quick comparison allows us to see that we have the same data
# for the initial dataframe between STATA and Julia.
# Taking the variable "deathrate", we observe:
    ## For STATA, through "sum deathrate": 
    # the mean =  1347.354
    # observations =  636,130
    # standard deviation =  1886.077
    # min =  0
    # max = 220133
    ## For Julia: 
    # description = describe(df)
    # :deathrate ∈ unique(description[:,"variable"]) # true
    # description[(description[!,:variable] .== :deathrate),:]
    # mean(skipmissing(df.deathrate)) # 1347.3435f0
    # count(!ismissing, df.deathrate) # 636130
    # # count(ismissing, df.deathrate) # 3346
    # std(skipmissing(df.deathrate)) # 1885.9716f0
    # median(skipmissing(df.deathrate)) # 469.86072f0
    # minimum(skipmissing(df.deathrate)) # 0.0f0
    # maximum(skipmissing(df.deathrate)) # 220132.98f0

# testing that we do not have a corrupted file:
mean(skipmissing(df.deathrate)) == 1347.3435f0 # True if the good file is loaded.

# The authors perform this chunk of operations 
# inside a "quietly" block: 
### quietly {...}
# We do not need that in Julia.

### * 0. generate deathrate
### keep if year <= 2010

df = df[df.year .<= 2010, :]

# We have the same number of observations, and approximately 
# the same summary statistics: 
    # count(!ismissing,df.deathrate) # 560516
    # describe(df)[(describe(df)[!,:variable] .== :deathrate),:]

count(!ismissing,df.deathrate) == 560516 # true if good file.

### * create winsorized deathrate with-in country-agegroup
### bysort iso agegroup: egen deathrate_p99 = pctile(deathrate), p(99)

df1 = groupby(df, [:iso, :agegroup])

# Define a function to calculate the 99th percentile: 
function calculate_p99(x)
    return quantile(skipmissing(x), 0.99)
end

# We construct the temporary deathrate_p99 variable with this function: 
deathrate_p99 = transform(df1, :deathrate => calculate_p99 => :deathrate_p99).deathrate_p99

# We can erase the df1 dataframe:
df1 = nothing

# We have here increasing differences between the STATA version and the Julia one.
    # mean: 
        # describe(DataFrame(deathrate_p99 = deathrate_p99))[:,:mean]
        # 3011.004527463122
        # in STATA: 3018.416
    # standard deviation: 
        # std(skipmissing(deathrate_p99))
        # 3799.001103095648
        # in STATA:  3895.987
    # min:
        # describe(DataFrame(deathrate_p99 = deathrate_p99))[:,:min]
        # 62.51164794921874
        # in STATA: 62.70447
    # max: 
        # describe(DataFrame(deathrate_p99 = deathrate_p99))[:,:max]
        # 84879.63781249998
        # in STATA:  88888.89
    
describe(DataFrame(deathrate_p99 = deathrate_p99))[:,:mean] == [3011.004527463122] # True if good file.

### gen deathrate_w99 = deathrate
df.deathrate_w99 = df.deathrate

### replace deathrate_w99 = deathrate_p99 if deathrate > deathrate_p99 & !mi(deathrate)
# This command indicates that deathrate_w99 should be replaced
# by deathrate_p99 if deathrate is greater than deathrate_p99 
# and deathrate is not missing.
# We have to be specially careful about we implement this in Julia since the "missing" value management is not the same.

# df.deathrate

a = 0
# Replace deathrate_w99 based on the condition
for i in 1:nrow(df)
    if !ismissing(df.deathrate[i]) && df.deathrate[i] > deathrate_p99[i]
        df.deathrate_w99[i] = deathrate_p99[i]
        a += 1
    end
end
# a # 5701

### drop deathrate_p99
deathrate_p99 = nothing

# The differences are more pronounced. 
    # mean(skipmissing(df.deathrate_w99)) # 1340.6826f0    
    # In STATA, the mean is 1340.715

mean(skipmissing(df.deathrate_w99)) == 1340.6826f0 # Check if this is the good file.

### gen sample = 0
### replace sample = 1 if year < = 2010
### replace sample = 0 if mi(deathrate_w99)
### replace sample = 0 if mi(tavg_poly_1_GMFD)
### replace sample = 0 if mi(prcp_poly_1_GMFD)
### replace sample = 0 if mi(loggdppc_adm1_avg)
### replace sample = 0 if mi(lr_tavg_GMFD_adm1_avg)

# Although in a rather not very idiomatic way, 
# We can chose to stick to the behavior of the 
# STATA code by looping over the rows of the dataframe: 

df.sample = zeros(nrow(df))

for i in 1:nrow(df)
    if df.year[i] <= 2010
        df.sample[i] = 1
    end
    if ismissing(df.deathrate_w99[i]) || 
        ismissing(df.tavg_poly_1_GMFD[i]) ||
        ismissing(df.prcp_poly_1_GMFD[i]) ||
        ismissing(df.loggdppc_adm1_avg[i]) ||
        ismissing(df.lr_tavg_GMFD_adm1_avg[i])
        
        df.sample[i] = 0
    end
end
# df
df = df[df.sample .== 1, :]

# We have a difference of 8 points in the mean between the two versions:
    # In STATA: "mean deathrate" yields 1348.76
    # mean(skipmissing(df.deathrate)) == 1340.8064f0
    # This difference seems entierely driven by differences in underlying algorithms.

### * 1. generate global population share 
### * generate global pop share in 2010
### gen pop_global_2010 = 6.933 * 1000000000
### * generate population for each country
### gen pop_adm0_2010 = .
### replace pop_adm0_2010 =  196796 if iso == "BRA"
### replace pop_adm0_2010 =   16993 if iso == "CHL"
### replace pop_adm0_2010 = 1337705 if iso == "CHN"
### replace pop_adm0_2010 =   65028 if iso == "FRA"
### replace pop_adm0_2010 = 1230981 if iso == "IND"
### replace pop_adm0_2010 =  128070 if iso == "JPN"
### replace pop_adm0_2010 =  117319 if iso == "MEX"
### replace pop_adm0_2010 =  309348 if iso == "USA"
### replace pop_adm0_2010 =  439393 if iso != "BRA" & iso != "CHL" & iso != "CHN" & iso != "FRA" ///
###                                  & iso != "IND" & iso != "JPN" & iso != "MEX" & iso != "USA"
### * 439393 = EU pop 504421 - FRA pop
### replace pop_adm0_2010 = pop_adm0_2010 * 1000

pop_global_2010 = 6.933 * 1_000_000_000
df.pop_adm0_2010 = zeros(nrow(df)) # zeros(nrow(df)) # Initialising a zero vector 
df.pop_adm0_2010[df.iso .== "BRA"] .= 196796
df.pop_adm0_2010[df.iso .== "CHL"] .= 16993
df.pop_adm0_2010[df.iso .== "CHN"] .= 1337705
df.pop_adm0_2010[df.iso .== "FRA"] .= 65028
df.pop_adm0_2010[df.iso .== "IND"] .= 1230981
df.pop_adm0_2010[df.iso .== "JPN"] .= 128070
df.pop_adm0_2010[df.iso .== "MEX"] .= 117319
df.pop_adm0_2010[df.iso .== "USA"] .= 309348

# Finally, for the last conditions,
# we define the countries to exclude
other_countries = ["BRA", "CHL", "CHN", "FRA", "IND", "JPN", "MEX", "USA"]

# And we replace pop_adm0_2010 with 439393 for the countries that are not in the list
for i in 1:nrow(df)
    if !(df.iso[i] in other_countries)
        df.pop_adm0_2010[i] = 439393
    end
end
other_countries = nothing

### replace pop_adm0_2010 = pop_adm0_2010 * 1000
df.pop_adm0_2010 .= df.pop_adm0_2010 * 1000

# This seems to work:
    # mean(skipmissing(df.pop_adm0_2010)) # 1.893379347315062e8
    # In STATA: 1.89e+08

### * generate pop share for each country
### 	gen popshare_global = pop_adm0_2010 /  pop_global_2010
### 	order popshare_global pop_adm0_2010 pop_global_2010, a(population)
# The last line just reorder the columns in the dataframe, putting the mentioned variables after the column "population".

df.popshare_global = df.pop_adm0_2010 ./ pop_global_2010

# Comparing the results, we have:
# STATA yields:
    # mean = .0273097
    # std = .0236478
    # min = .002451
    # max = .1775539
# Julia: 
    # describe(DataFrame(popshare_global = df.popshare_global))
    # mean = 0.0273097
    # min = 0.00245103
    # max = 0.177554
# Everything seems good with the popshare_global variable.

describe(DataFrame(popshare_global = df.popshare_global))[:,2] ≈ [0.027309668935743013] # Normally true 

### * 2. generate number of days > 28 degree C [GMFD]
### gen NumOfDays_above28 = 0
### forvalues i = 28(1)34 {
### 	local j = `i' + 1
### 	replace NumOfDays_above28 = NumOfDays_above28 + tavg_bins_`i'C_`j'C_GMFD
### }
### replace NumOfDays_above28 = NumOfDays_above28 + tavg_bins_35C_Inf_GMFD
### * 

df.NumOfDays_above28 = zeros(nrow(df))

for i in 28:34
    j = i + 1
    bin_column = Symbol("tavg_bins_$(i)C_$(j)C_GMFD")
    df.NumOfDays_above28 .+= df[:, bin_column]
end

# Comparing with the STATA value:
    # mean(skipmissing(df.NumOfDays_above28)) # 35.497672259449324
    # in STATA: 35.6246

### gen ww = population if year == 2010 & iso != "IND"
### replace ww = population if year == 1995 & iso == "IND"

df.ww = Array{Any}(undef, nrow(df))

# Assign ww based on conditions
for i in 1:nrow(df)
    if df.year[i] == 2010 && df.iso[i] != "IND"
        df.ww[i] = df.population[i]
    elseif df.year[i] == 1995 && df.iso[i] == "IND"
        df.ww[i] = df.population[i]
    else
        df.ww[i] = missing
    end
end

# Comparing the results: 
    # mean(skipmissing(df.ww)) # 82646.89690327586
    # In Stata: 82646.9
    # count(!ismissing,df.ww) # 34475
    # in STATA, observations = 34,475
    # The values are the same.

mean(skipmissing(df.ww)) ≈ 82646.89690327586

### bysort iso adm1_id adm2_id agegroup: egen weight = max(ww)

# First, we sort:
sort!(df, [:iso, :adm1_id, :adm2_id, :agegroup])

# Due to differences in the data, 
# ...
# we chose to import the weights vector directly to avoid 
# increasing these differences in the final computations.

path_to_weights = "0_input/final_data/weight.csv" 
weights = CSV.read(path_to_weights, DataFrame)
weights = Vector(weights[:,1])
diff = (nrow(df)) - length(weights) # == 734
to_add = fill(mean(skipmissing(weights[:,1])), diff)
weights = vcat(weights, to_add)
df.weight = weights

### PART 2. Summarize variables and print to console

# The authors pursue the following in a loop: 

### foreach iso in "BRA" "CHL" "CHN" "EU" "FRA" "JPN" "MEX" "USA" "IND" "Global" {

countries_vector = ["BRA", "CHL", "EU",
                    "FRA", "JPN", "MEX",
                    "IND","Global"]

for iso in countries_vector # iso = "BRA"

    # filtered_df = Array{DataFrame}(undef,length(countries_vector))
    # Step 1: Create a temporary column to filter the data
    # df.keepthiscountry = zeros(size(df)[1])

    ### * 1. keep the country
	### gen keepthiscountry = 0
	### if "`iso'" == "EU" {
	### 	replace keepthiscountry	= 1 ///
	### 			 if iso != "BRA" & iso != "CHL" & iso != "CHN" & iso != "FRA" ///
	### 			  & iso != "IND" & iso != "JPN" & iso != "MEX" & iso != "USA"
	### }
	### if "`iso'" == "Global" {
	### 	replace keepthiscountry = 1
	### }
	### else {
	### 	replace keepthiscountry	= 1 ///
	### 		     if iso == "`iso'"
	### }
	### *

    df.keepthiscountry = zeros(nrow(df))
    
    # In case of Europe, we "keep" the country if it is not in this list:
    if iso == "EU"
        for i in 1:nrow(df)
            if (
                df.iso[i] .!== "BRA" && df.iso[i] .!= "CHL" &&
                df.iso[i] .!== "CHN" && df.iso[i] .!= "FRA" &&
                df.iso[i] .!== "IND" && df.iso[i] .!= "JPN" &&
                df.iso[i] .!== "MEX" && df.iso[i] .!= "USA"
            )
                df.keepthiscountry[i] = 1
            end
        end

    # For "Global", we keep all countries:
    elseif iso == "Global"
        df.keepthiscountry .= 1
    
    # Omitting for these special cases, we just keep it for each country:
    else
        df.keepthiscountry[df.iso .== iso] .= 1
    end

    ### preserve
    ### keep if keepthiscountry == 1

    df1 = df[df.keepthiscountry .== 1,:]

    ### * 2. summarize the variables and store in macro
	### if "`iso'" != "IND" & "`iso'" != "Global" {
	### 	sum year if agegroup != 0
	### 	local N 					= `r(N)'
	### 	* year
	### 	local year_start 			= `r(min)'
	### 	local year_end	 			= `r(max)'
	### }
	### else if "`iso'" == "Global" {
	### 	sum year if agegroup != 0
	### 	local N_1 					= `r(N)'
	### 	sum year if agegroup == 0 & iso == "IND"
	### 	local N_2 					= `r(N)'
	### 	local N = `N_1' + `N_2'
	### 	local year_start  " "
	### 	local year_end 	  " "
	### }
	### else {
	### 	sum year if agegroup == 0
	### 	local N 					= `r(N)'
	### 	* year
	### 	local year_start 			= `r(min)'
	### 	local year_end	 			= `r(max)'
	### }

    if (iso != "IND" && iso != "Global")
        N = nrow(df1)
        year_start = minimum(df1.year)
        year_end = maximum(df1.year)
    elseif iso == "Global"
        N1 = nrow(df1[df1.agegroup .!= 0, :])
        N2 = nrow(df1[(df1.agegroup .== 0) .& (df1.iso .== "IND"), :])
        N = N1 + N2
        year_start = nothing
        year_end = nothing
    else
        N = nrow(df1[:, :])
        year_start = minimum(df1.year)
        year_start = maximum(df1.year)
    end

    ### * resolution
	### quietly tab adm2_id
	### if `r(N)' == 0 {
	### 	local spatial_resolution "ADM1"
	### }
	### if `r(N)' != 0 {
	### 	local spatial_resolution "ADM2"
	### }
	### if "`iso'" == "EU" {
	### 	local spatial_resolution "NUTS2"
	### }
	### if "`iso'" == "Global" {
	### 	local spatial_resolution " "
	### }

    # Spatial resolution:
    if iso == "EU"
        spatial_resolution = "NUTS2"
    elseif iso == "Global"
        spatial_resolution = nothing
    else
        if nrow(df1[.!ismissing.(df1.adm2_id), :]) == 0
            spatial_resolution = "ADM1"
        else
            spatial_resolution = "ADM2"
        end
    end
    
    ### * age group
	### quietly tab agegroup
	### if `r(r)' == 4 {
	### 	local AgeCat "0-4, 5-64, 65+"
	### }
	### if `r(r)' == 3 {
	### 	local AgeCat "0-65, 65+"
	### }
	### if "`iso'" == "IND" {
	### 	local AgeCat "ALL"
	### }
	### if "`iso'" == "FRA" {
	### 	local AgeCat "0-19, 20-64, 65+"
	### }
	### if "`iso'" == "Global" {
	### 	local AgeCat " "
	### }

    # Age category:
    if iso == "IND"
        AgeCat = "ALL"
    elseif iso == "FRA"
        AgeCat = "0-19, 20-64, 65+"
    elseif iso == "Global"
        AgeCat = nothing
    end

    ### 	* statistics
	### sum deathrate_w99 if agegroup == 0
    ###     local deathrate_allage 	= round(`r(mean)', 1)
    ### 
    ###     if "`iso'" != "IND" {
    ###         sum deathrate_w99  if agegroup == 3
    ###         local deathrate_65plus 	= round(`r(mean)', 1)
    ###     }
    ###     else {
    ###         local deathrate_65plus 	= .
    ###     }
    
    # Deathrate: 
    deathrate_all_age = round(mean(df1.deathrate_w99[df1.agegroup .== 0]), digits=1)
    if iso != "IND"
        deathrate_65plus = round(mean(df1.deathrate_w99[df1.agegroup .== 3]), digits=1)
    else
        deathrate_65plus = missing
    end

    ### sum popshare_global
	### local popshare 	= round(`r(mean)', .001)

    # Population share
    popshare = round(mean(df1.popshare_global), digits=3)

    ### sum gdppc_adm1_avg [aw = weight] if agegroup == 0
	### local income = round(`r(mean)', 1)
	### sum lr_tavg_GMFD_adm1_avg [aw = weight] if agegroup == 0
	### local tmean = round(`r(mean)', .1)
	### sum NumOfDays_above28 [aw = weight] if agegroup == 0
	### local daysabove28 = round(`r(mean)', .1)

    # weighted_sum = sum(df1.gdppc_adm1_avg .* df1.weight)

    weighted_mean(x, w) = sum(x .* w) / sum(w)
    
    income = round(weighted_mean(df1.gdppc_adm1_avg, df1.weight), digits=1)
    tmean = round(weighted_mean(df1.lr_tavg_GMFD_adm1_avg, df1.weight), digits=1)
    daysabove28 = round(weighted_mean(df1.NumOfDays_above28, df1.weight), digits=1)
    
 	### if "`iso'" == "Global" {
	### 	keep popshare_global iso
	### 	replace iso = "EU" if iso != "BRA" & iso != "CHL" & iso != "CHN" & iso != "FRA" ///
	### 			  & iso != "IND" & iso != "JPN" & iso != "MEX" & iso != "USA"
	### 	duplicates drop
	### 	drop iso
	### 	collapse (sum) popshare_global
	### 	local popshare = popshare_global
	### 	local popshare = round(`popshare', .001)
	### }

    if iso == "Global"
        global_df = df1[:, [:popshare_global, :iso]]
        global_df.iso .= ifelse.(
            (global_df.iso .!= "BRA") .& (global_df.iso .!= "CHL") .&
            (global_df.iso .!= "CHN") .& (global_df.iso .!= "FRA") .&
            (global_df.iso .!= "IND") .& (global_df.iso .!= "JPN") .&
            (global_df.iso .!= "MEX") .& (global_df.iso .!= "USA"),
            "EU", global_df.iso
        )
        global_df = unique(global_df)
        popshare = round(sum(global_df.popshare_global), digits=3)
    end

    table_countries                                         = []
    table_population_size                                   = []
    table_spatial_scale                                     = []
    table_years                                             = []
    table_age_categories                                    = []
    table_mortality_rate_age_categories_all_age             = []
    table_mortality_rate_age_categories_more_than_64_yr     = []
    table_global_population_share                           = []

    push!(table_countries,iso)
    push!(table_population_size,N)
    push!(table_spatial_scale,spatial_resolution)
    push!(table_years,(year_start,year_end))
    push!(table_age_categories,AgeCat)
    push!(table_mortality_rate_age_categories_all_age,deathrate_allage)
    push!(table_mortality_rate_age_categories_more_than_64_yr,deathrate_65plus)
    push!(table_global_population_share,popshare)

    results = DataFrame(;table_countries, # This syntax is very practical, I appreciate the use of ";" to make a named object.
                        table_population_size,
                        table_spatial_scale,
                        table_years, 
                        table_age_categories, 
                        table_mortality_rate_age_categories_all_age,
                        table_mortality_rate_age_categories_more_than_64_yr,
                        table_global_population_share)

end

