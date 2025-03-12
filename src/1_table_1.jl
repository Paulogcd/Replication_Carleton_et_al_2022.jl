
# This file is dedicated to reproducing the first table of descriptive statistics of the article.

# Dependencies : 
# using Pkg 
using ReadStatTables
using DataFrames
using Statistics
using StatsBase
using Latexify

### STATA code: 
### 	* 0. generate deathrate
###	keep if year <= 2010
###        * create winsorized deathrate with-in country-agegroup
###        bysort iso agegroup: egen deathrate_p99 = pctile(deathrate), p(99)
###        gen deathrate_w99 = deathrate
###        replace deathrate_w99 = deathrate_p99 if deathrate > deathrate_p99 & !mi(deathrate)
###        drop deathrate_p99

df = DataFrame(readstat("input/final_data/global_mortality_panel_public.dta")) # We load the file
GC.gc()
1+1 # Adding modifications to test changes.

# df = global_mortality_panel_public # [:year] # former version: copy 
df[df.year .<= 2010, :] # We take out the data from before 2010
# GC.gc()
### bysort iso agegroup: egen deathrate_p99 = pctile(deathrate), p(99)

grouped_df = groupby(df, [:iso, :agegroup]) # We group by the variables iso and agegroup

# df[!,:year]
# "deathrate" ∈ names(grouped_df)

deathrate_column = combine(grouped_df, :deathrate => (x -> x) => :deathrate) # We construct the deathrate variable

# grouped_df

clean_df = dropmissing(deathrate_column)  # Drops rows with `missing` or `NaN`
# GC.gc()
# view(deathrate_column,:,3)

# StatsBase.percentile(clean_df[:,3], 99)
# Then, we create the deathrate_p99 variable, by using the quantile function, we ignore the NaNs and missing values:
# df.deathrate_p99 = transform(grouped_df, :deathrate => (x -> quantile(filter(!isnan, collect(skipmissing(x)))),99) => :deathrate_p99)

# df[:,:agegroup]

# Step 1: Keep rows where `year` is less than or equal to 2010
df = df[df.year .<= 2010, :]
GC.gc()
# Step 2: Calculate the 99th percentile of `deathrate` for each `iso` and `agegroup`
# Group the DataFrame by `iso` and `agegroup`
grouped_df = groupby(df, [:iso, :agegroup])

# Define a function to calculate the 99th percentile
function calculate_p99(x)
    return quantile(skipmissing(x), 0.99)
end

# Apply the function to each group and store the result in a new column `deathrate_p99`
df.deathrate_p99 = transform(grouped_df, :deathrate => calculate_p99 => :deathrate_p99).deathrate_p99
GC.gc()
# Step 3: Create a new column `deathrate_w99` that is a copy of `deathrate`
df.deathrate_w99 = df.deathrate

# Step 4: Replace values in `deathrate_w99` with the 99th percentile if `deathrate` > `deathrate_p99` and not missing
df.deathrate_w99 = [coalesce(dr, dr_p99) > dr_p99 ? dr_p99 : coalesce(dr, dr_p99) for (dr, dr_p99) in zip(df.deathrate, df.deathrate_p99)]

# Step 5: Drop the temporary column `deathrate_p99`
select!(df, Not(:deathrate_p99))

# df

### * 0. keep the sample
### gen sample = 0
### replace sample = 1 if year < = 2010
### replace sample = 0 if mi(deathrate_w99)
### replace sample = 0 if mi(tavg_poly_1_GMFD)
### replace sample = 0 if mi(prcp_poly_1_GMFD)
### replace sample = 0 if mi(loggdppc_adm1_avg)
### replace sample = 0 if mi(lr_tavg_GMFD_adm1_avg)
### 
### keep if sample == 1

# Here, staying close to the syntax of the STATA code, we could write : 

df.sample = zeros(size(df)[1])

df.sample[df.year .<= 2010] .= 1
# df.sample[df.year .<= 2010] .= 0

df.sample[ismissing.(df[!,:deathrate_w99])] .= 0
df.sample[ismissing.(df[!,:tavg_poly_1_GMFD])] .= 0
df.sample[ismissing.(df[!,:prcp_poly_1_GMFD])] .= 0
df.sample[ismissing.(df[!,:loggdppc_adm1_avg])] .= 0
df.sample[ismissing.(df[!,:lr_tavg_GMFD_adm1_avg])] .= 0

# findmax(df.sample)
# sum(df.sample)
df = df[df.sample .== 1, :]

# Then, the authors hard write the populations: 

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
df.pop_adm0_2010 = zeros(size(df)[1]) # Initialising a zero vector 
df.pop_adm0_2010[df.iso .== "BRA",:] .= 196796
df.pop_adm0_2010[df.iso .== "CHL",:] .= 16993
df.pop_adm0_2010[df.iso .== "CHN",:] .= 1337705
df.pop_adm0_2010[df.iso .== "FRA",:] .= 65028
df.pop_adm0_2010[df.iso .== "IND",:] .= 1230981
df.pop_adm0_2010[df.iso .== "JPN",:] .= 128070
df.pop_adm0_2010[df.iso .== "MEX",:] .= 117319
df.pop_adm0_2010[df.iso .== "USA",:] .= 309348
df.pop_adm0_2010 .= df.pop_adm0_2010 * 1000

### * generate pop share for each country
### 	gen popshare_global = pop_adm0_2010 /  pop_global_2010
### 	order popshare_global pop_adm0_2010 pop_global_2010, a(population)

df.popshare_global = df.pop_adm0_2010 ./ pop_global_2010

# The last line just reorder the columns in the dataframe.'


### 2. generate number of days > 28 degree C [GMFD]
### gen NumOfDays_above28 = 0
### forvalues i = 28(1)34 {
###     local j = `i' + 1
###     replace NumOfDays_above28 = NumOfDays_above28 + tavg_bins_`i'C_`j'C_GMFD
### }
### replace NumOfDays_above28 = NumOfDays_above28 + tavg_bins_35C_Inf_GMFD

df.NumOfDays_above28 = zeros(size(df)[1])

for i in 28:1:34
    j = i + 1
    tmp1 = string("tavg_bins_", i)
    tmp2 = string("C_",j)
    tmp3 = string(tmp2,"C_GMFD")
    tmp4 = string(tmp1,tmp3)
    println(tmp4,"\n")
    df.NumOfDays_above28 .= df.NumOfDays_above28 .+ df[!,tmp4]
end

df.NumOfDays_above28 = df.NumOfDays_above28 .+ df.tavg_bins_35C_Inf_GMFD

### gen ww = population if year == 2010 & iso != "IND"
### 	replace ww = population if year == 1995 & iso == "IND"
### 	bysort iso adm1_id adm2_id agegroup: egen weight = max(ww)		

df.ww = zeros(size(df)[1])
df.ww[ (df.year .== 2010) .& (df.iso .!= "IND") ] = df.population[ (df.year .== 2010) .& (df.iso .!= "IND") ]

# foreach(println, names(df))

### foreach iso in "BRA" "CHL" "CHN" "EU" "FRA" "JPN" "MEX" "USA" "IND" "Global" {
### 
### 	* 1. keep the country
### 	gen keepthiscountry = 0
### 	if "`iso'" == "EU" {
### 		replace keepthiscountry	= 1 ///
### 				 if iso != "BRA" & iso != "CHL" & iso != "CHN" & iso != "FRA" ///
### 				  & iso != "IND" & iso != "JPN" & iso != "MEX" & iso != "USA"
### 	}
### 	if "`iso'" == "Global" {
### 		replace keepthiscountry = 1
### 	}
### 	else {
### 		replace keepthiscountry	= 1 ///
### 			     if iso == "`iso'"
### 	}

# Here, we exclude China and USA: 
countries_vector = ["BRA",
                    "CHL",
                    # "CHN",
                    "EU",
                    "FRA",
                    "JPN",
                    "MEX",
                    # "USA",
                    "IND",
                    "Global"]

# filtered_df = Array{DataFrame}(undef,length(countries_vector))

function filter_df(df::DataFrame,countries_vector::Array)::Array{DataFrame}

    filtered_df = Array{DataFrame}(undef,length(countries_vector))

    for (index_country, country) in enumerate(countries_vector)
        
        # Step 1: Create a temporary column to filter the data
        df.keepthiscountry = zeros(size(df)[1])

        if country == "EU"
            df.keepthiscountry .= ifelse.(
                (df.iso .!= "BRA") .& (df.iso .!= "CHL") .& (df.iso .!= "CHN") .&
                (df.iso .!= "FRA") .& (df.iso .!= "IND") .& (df.iso .!= "JPN") .&
                (df.iso .!= "MEX") .& (df.iso .!= "USA"), 1, 0)
        elseif country == "Global"
            df.keepthiscountry .= 1
        else
            df.keepthiscountry = ifelse.(df.iso .== country, 1, 0)
        end

        # println(keepthiscountry)
        println(country)

        filtered_df[index_country] = df[df.keepthiscountry .== 1, :]

        # df_under_work = filtered_df[index_country]
    end
    return filtered_df
end

filtered_df = filter_df(df,countries_vector)
GC.gc()
# filtered_df

    ### 	if "`iso'" != "IND" & "`iso'" != "Global" {
	###	sum year if agegroup != 0
    ###        local N 					= `r(N)'
    ###        * year
    ###        local year_start 			= `r(min)'
    ###        local year_end	 			= `r(max)'
    ###    }

function statistics_df(filtered_df::Array{DataFrame},countries_vector::Array)

    # We initialise empty arrays for the values of the dataframe : 
    table_countries                                         = []
    table_population_size                                   = []
    table_spatial_scale                                     = []
    table_years                                             = []
    table_age_categories                                    = []
    table_mortality_rate_age_categories_all_age             = []
    table_mortality_rate_age_categories_more_than_64_yr     = []
    table_global_population_share                           = []

    for (index_country,country) in enumerate(countries_vector)

        df_under_work = filtered_df[index_country]

        # println(index_country," ", country)

        if country != "IND" && country != "Global"
            N = nrow(df_under_work[df_under_work.agegroup .!= 0, :])
            year_start = minimum(df_under_work.year[df_under_work.agegroup .!= 0])
            year_end = maximum(df_under_work.year[df_under_work.agegroup .!= 0])
        elseif country == "Global"
            N1 = nrow(df_under_work[df_under_work.agegroup .!= 0, :])
            N2 = nrow(df_under_work[(df_under_work.agegroup .== 0) .& (df_under_work.iso .== "IND"), :])
            N = N1 + N2
            year_start = " "
            year_end = " "
        else
            N = nrow(df_under_work[df_under_work.agegroup .== 0, :])
            year_start = minimum(df_under_work.year[df_under_work.agegroup .== 0])
            year_end = maximum(df_under_work.year[df_under_work.agegroup .== 0])
        end

        if country == "EU"
            spatial_resolution = "NUTS2"
        elseif country == "Global"
            spatial_resolution = " "
        else
            if nrow(df_under_work[.!ismissing.(df_under_work.adm2_id), :]) == 0
                spatial_resolution = "ADM1"
            else
                spatial_resolution = "ADM2"
            end
        end

        # Age categories
        if country == "IND"
            AgeCat = "ALL"
        elseif country == "FRA"
            AgeCat = "0-19, 20-64, 65+"
        elseif country == "Global"
            AgeCat = " "
        else
            unique_agegroups = unique(df_under_work.agegroup)
            if length(unique_agegroups) == 4
                AgeCat = "0-4, 5-64, 65+"
            elseif length(unique_agegroups) == 3
                AgeCat = "0-65, 65+"
            end
        end

        # Death rates
        deathrate_allage = round(mean(df_under_work.deathrate_w99[df_under_work.agegroup .== 0]), digits=1)
        if country != "IND"
            deathrate_65plus = round(mean(df_under_work.deathrate_w99[df_under_work.agegroup .== 3]), digits=1)
        else
            deathrate_65plus = missing
        end

        # Population share
        popshare = round(mean(df_under_work.popshare_global), digits=3)

        # Income, temperature, and days above 28°C
        # income = round(mean(df_under_work.gdppc_adm1_avg[df_under_work.agegroup .== 0]), digits=1)
        # tmean = round(mean(df_under_work.lr_tavg_GMFD_adm1_avg[df_under_work.agegroup .== 0]), digits=1)
        # daysabove28 = round(mean(df_under_work.NumOfDays_above28[df_under_work.agegroup .== 0]), digits=1)

        # Special case for Global
        if country == "Global"
            # df_under_work
            # filtered_df
            global_df = df_under_work[:, [:popshare_global, :iso]]
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
        push!(table_countries,country)
        push!(table_population_size,N)
        push!(table_spatial_scale,spatial_resolution)
        push!(table_years,(year_start,year_end))
        push!(table_age_categories,AgeCat)
        push!(table_mortality_rate_age_categories_all_age,deathrate_allage)
        push!(table_mortality_rate_age_categories_more_than_64_yr,deathrate_65plus)
        push!(table_global_population_share,popshare)
    # end # end of the loop : for (index_country,country) in enumerate(countries_vector)

    # Step 4: Display results
    if country == "BRA"
        # println("")
        # println("=======================================================================================")
        # println("Country & N & Years & All-age & Over 65 & pop.share & GDP p.c. & Tmean & Num of Days>28C \\")
        # println("---------------------------------------------------------------------------------------")
    end
    # println("$country & $N & $spatial_resolution & $year_start-$year_end & $AgeCat & $deathrate_allage & $deathrate_65plus & $popshare & $income & $tmean & $daysabove28 \\")
    end
    # Returning the results: 
    results = DataFrame(;table_countries, # This syntax is amazing, I love the use of ";" to make a named object.
                        table_population_size,
                        table_spatial_scale,
                        table_years, 
                        table_age_categories, 
                        table_mortality_rate_age_categories_all_age,
                        table_mortality_rate_age_categories_more_than_64_yr,
                        table_global_population_share)

    return results

end

results = statistics_df(filtered_df,countries_vector)
GC.gc()
data_table_1 = latexify(results; env=:table, booktabs=true, latex=false)
GC.gc()