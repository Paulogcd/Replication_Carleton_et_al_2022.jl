
# This file is dedicated to reproducing the first table of descriptive statistics of the article.
# It is the equivalent of the "/carleton_mortality_2022/1_estimation/estimate.do" file of the original replication package.

#______________________Particular notes______________________: 
# We tried to carefully comment each step.
# The original STATA code is always preceeded by three "#" symbols: ###.
# GC.gc() is the garbage collector command in Julia.
# It will allow us to have less memory used while compiling and running the package.
# varinfo() allows to check all the variables currently used in Julia.
# It appears several times throughout the code in comments, due to previous memory checks.

# Loading the required packages in Julia: 
using Pkg 
using ReadStatTables
using DataFrames
using Statistics
using StatsBase
using Latexify
using Base.GC
using Weave

function calculate_p99(x)
    return quantile(skipmissing(x), 0.99)
end

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
        # println(country)

        filtered_df[index_country] = df[df.keepthiscountry .== 1, :]

        # df_under_work = filtered_df[index_country]
    end
    return filtered_df
end

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

        # println(index_country," ", country) # for debugging reasons.

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

        # For now, we do not use this: 
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
        
        # We push those values in the dedicated arrays. 
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
    results = DataFrame(;table_countries, # This syntax is very practical, I appreciate the use of ";" to make a named object.
                        table_population_size,
                        table_spatial_scale,
                        table_years, 
                        table_age_categories, 
                        table_mortality_rate_age_categories_all_age,
                        table_mortality_rate_age_categories_more_than_64_yr,
                        table_global_population_share)

    return results

end

function pre_create_table_1()
    # To ensure that the required files are present: 
    # load_global_mortality_panel_covariates()
    load_global_mortality_panel_public()

    # First of all, the authors load the data:
    ### STATA:
    ### do "$REPO/carleton_mortality_2022/0_data_cleaning/1_utils/set_paths.do"

    # !!! Warning: 2.6-2.2 Gigabytes file.
    df = DataFrame(ReadStatTables.readstat("0_input/final_data/global_mortality_panel_public.dta"))

    # varinfo()
    #  df   2.201 GiB 639476×639 DataFrame
    # GC.gc()
    # varinfo()

    # Then, they briefly excluded data from before 2010, and winsorize the rest. 
    # They exclude the extrema of death rate, by remplacing it by the 99th percentile. 

    ### STATA:
    ### 	* 0. generate deathrate
    ###	keep if year <= 2010
    ###        * create winsorized deathrate with-in country-agegroup
    ###        bysort iso agegroup: egen deathrate_p99 = pctile(deathrate), p(99)
    ###        gen deathrate_w99 = deathrate
    ###        replace deathrate_w99 = deathrate_p99 if deathrate > deathrate_p99 & !mi(deathrate)
    ###        drop deathrate_p99

    df = df[df.year .<= 2010, :]                                                        # We take out the data from before 2010
    grouped_df = groupby(df, [:iso, :agegroup])                                         # We group by the variables iso and agegroup
    # Define a function to calculate the 99th percentile: 
    # function calculate_p99(x)
    #     return quantile(skipmissing(x), 0.99)
    # end
    # This function is defined out of the function scope.
    # We construct the temporary deathrate_p99 variable with this function: 
    df.deathrate_p99 = transform(grouped_df, :deathrate => calculate_p99 => :deathrate_p99).deathrate_p99   
    df.deathrate_w99 = df.deathrate     # Step 3: Create a new column `deathrate_w99` that is a copy of `deathrate`
    df.deathrate_w99 = [coalesce(dr, dr_p99) > dr_p99 ? dr_p99 : coalesce(dr, dr_p99) for (dr, dr_p99) in zip(df.deathrate, df.deathrate_p99)] # We replace the values in `deathrate_w99` with the 99th percentile if `deathrate` > `deathrate_p99` and not missing
    select!(df, Not(:deathrate_p99)) # We drop the temporary column `deathrate_p99`

    # Cleaning environment to free memory
    # varinfo()
    grouped_df = nothing 
    GC.gc()
    # varinfo()

    # Then, the authors clean further the data by eliminating missing values, and only keeping data from at most 2010.

    ### STATA:
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
    df.sample[ismissing.(df[!,:deathrate_w99])] .= 0
    df.sample[ismissing.(df[!,:tavg_poly_1_GMFD])] .= 0
    df.sample[ismissing.(df[!,:prcp_poly_1_GMFD])] .= 0
    df.sample[ismissing.(df[!,:loggdppc_adm1_avg])] .= 0
    df.sample[ismissing.(df[!,:lr_tavg_GMFD_adm1_avg])] .= 0
    df = df[df.sample .== 1, :]

    # Then, the authors hard-write the populations: 

    ### STATA:
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

    # Also, they create the population share for each country: 

    ### STATA:
    ### * generate pop share for each country
    ### 	gen popshare_global = pop_adm0_2010 /  pop_global_2010
    ### 	order popshare_global pop_adm0_2010 pop_global_2010, a(population)

    df.popshare_global = df.pop_adm0_2010 ./ pop_global_2010
    # The last line just reorder the columns in the dataframe, putting the mentioned variables after the column "population".

    # Then, the authors generate a variable capturing the number of days above 28 degrees celsius.
    # It is constructed by adding the number of days with temperature from 29 to 34 degrees. 
    # The STATA syntax "28(1)34" corresponds to the Julia syntax "28:1:34".

    ### STATA:
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
        # println(tmp4,"\n")
        df.NumOfDays_above28 .= df.NumOfDays_above28 .+ df[!,tmp4]
    end

    df.NumOfDays_above28 = df.NumOfDays_above28 .+ df.tavg_bins_35C_Inf_GMFD

    # The authors then create the ww variable, which corresponds to the population in some cases. 

    ### STATA:
    ### gen ww = population if year == 2010 & iso != "IND"
    ### 	replace ww = population if year == 1995 & iso == "IND"
    ### 	bysort iso adm1_id adm2_id agegroup: egen weight = max(ww)		

    df.ww = zeros(size(df)[1])
    df.ww[ (df.year .== 2010) .& (df.iso .!= "IND") ] = df.population[ (df.year .== 2010) .& (df.iso .!= "IND") ]


    # The authors then use a loop statement that performs both computations and print the results to the terminal.
    # Here, we decide to divide the code of the loop in several code sections. 

    ### STATA:
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

    # Here, we exclude China and USA, since we do not have their data.
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

    # We then define a function to transform a dataframe in a filtered one:
    # function filter_df(df::DataFrame,countries_vector::Array)::Array{DataFrame}
    # 
    #     filtered_df = Array{DataFrame}(undef,length(countries_vector))
    # 
    #     for (index_country, country) in enumerate(countries_vector)
    #         
    #         # Step 1: Create a temporary column to filter the data
    #         df.keepthiscountry = zeros(size(df)[1])
    # 
    #         if country == "EU"
    #             df.keepthiscountry .= ifelse.(
    #                 (df.iso .!= "BRA") .& (df.iso .!= "CHL") .& (df.iso .!= "CHN") .&
    #                 (df.iso .!= "FRA") .& (df.iso .!= "IND") .& (df.iso .!= "JPN") .&
    #                 (df.iso .!= "MEX") .& (df.iso .!= "USA"), 1, 0)
    #         elseif country == "Global"
    #             df.keepthiscountry .= 1
    #         else
    #             df.keepthiscountry = ifelse.(df.iso .== country, 1, 0)
    #         end
    # 
    #         # println(keepthiscountry)
    #         # println(country)
    # 
    #         filtered_df[index_country] = df[df.keepthiscountry .== 1, :]
    # 
    #         # df_under_work = filtered_df[index_country]
    #     end
    #     return filtered_df
    # end
    # This function is defined out of the function scope.

    filtered_df = filter_df(df,countries_vector)

    # Cleaning environment to free memory
    # varinfo()
    df = nothing 
    GC.gc()
    # varinfo()

    ### STATA:
    ### 	if "`iso'" != "IND" & "`iso'" != "Global" {
    ###	sum year if agegroup != 0
    ###        local N 					= `r(N)'
    ###        * year
    ###        local year_start 			= `r(min)'
    ###        local year_end	 			= `r(max)'
    ###    }

    # function statistics_df(filtered_df::Array{DataFrame},countries_vector::Array)
    # 
    #     # We initialise empty arrays for the values of the dataframe : 
    #     table_countries                                         = []
    #     table_population_size                                   = []
    #     table_spatial_scale                                     = []
    #     table_years                                             = []
    #     table_age_categories                                    = []
    #     table_mortality_rate_age_categories_all_age             = []
    #     table_mortality_rate_age_categories_more_than_64_yr     = []
    #     table_global_population_share                           = []
    # 
    #     for (index_country,country) in enumerate(countries_vector)
    # 
    #         df_under_work = filtered_df[index_country]
    # 
    #         # println(index_country," ", country) # for debugging reasons.
    # 
    #         if country != "IND" && country != "Global"
    #             N = nrow(df_under_work[df_under_work.agegroup .!= 0, :])
    #             year_start = minimum(df_under_work.year[df_under_work.agegroup .!= 0])
    #             year_end = maximum(df_under_work.year[df_under_work.agegroup .!= 0])
    #         elseif country == "Global"
    #             N1 = nrow(df_under_work[df_under_work.agegroup .!= 0, :])
    #             N2 = nrow(df_under_work[(df_under_work.agegroup .== 0) .& (df_under_work.iso .== "IND"), :])
    #             N = N1 + N2
    #             year_start = " "
    #             year_end = " "
    #         else
    #             N = nrow(df_under_work[df_under_work.agegroup .== 0, :])
    #             year_start = minimum(df_under_work.year[df_under_work.agegroup .== 0])
    #             year_end = maximum(df_under_work.year[df_under_work.agegroup .== 0])
    #         end
    # 
    #         if country == "EU"
    #             spatial_resolution = "NUTS2"
    #         elseif country == "Global"
    #             spatial_resolution = " "
    #         else
    #             if nrow(df_under_work[.!ismissing.(df_under_work.adm2_id), :]) == 0
    #                 spatial_resolution = "ADM1"
    #             else
    #                 spatial_resolution = "ADM2"
    #             end
    #         end
    # 
    #         # Age categories
    #         if country == "IND"
    #             AgeCat = "ALL"
    #         elseif country == "FRA"
    #             AgeCat = "0-19, 20-64, 65+"
    #         elseif country == "Global"
    #             AgeCat = " "
    #         else
    #             unique_agegroups = unique(df_under_work.agegroup)
    #             if length(unique_agegroups) == 4
    #                 AgeCat = "0-4, 5-64, 65+"
    #             elseif length(unique_agegroups) == 3
    #                 AgeCat = "0-65, 65+"
    #             end
    #         end
    # 
    #         # Death rates
    #         deathrate_allage = round(mean(df_under_work.deathrate_w99[df_under_work.agegroup .== 0]), digits=1)
    #         if country != "IND"
    #             deathrate_65plus = round(mean(df_under_work.deathrate_w99[df_under_work.agegroup .== 3]), digits=1)
    #         else
    #             deathrate_65plus = missing
    #         end
    # 
    #         # Population share
    #         popshare = round(mean(df_under_work.popshare_global), digits=3)
    # 
    #         # For now, we do not use this: 
    #         # Income, temperature, and days above 28°C
    #         # income = round(mean(df_under_work.gdppc_adm1_avg[df_under_work.agegroup .== 0]), digits=1)
    #         # tmean = round(mean(df_under_work.lr_tavg_GMFD_adm1_avg[df_under_work.agegroup .== 0]), digits=1)
    #         # daysabove28 = round(mean(df_under_work.NumOfDays_above28[df_under_work.agegroup .== 0]), digits=1)
    # 
    #         # Special case for Global
    #         if country == "Global"
    #             # df_under_work
    #             # filtered_df
    #             global_df = df_under_work[:, [:popshare_global, :iso]]
    #             global_df.iso .= ifelse.(
    #                 (global_df.iso .!= "BRA") .& (global_df.iso .!= "CHL") .&
    #                 (global_df.iso .!= "CHN") .& (global_df.iso .!= "FRA") .&
    #                 (global_df.iso .!= "IND") .& (global_df.iso .!= "JPN") .&
    #                 (global_df.iso .!= "MEX") .& (global_df.iso .!= "USA"),
    #                 "EU", global_df.iso
    #             )
    #             global_df = unique(global_df)
    #             popshare = round(sum(global_df.popshare_global), digits=3)
    #         end
    #         
    #         # We push those values in the dedicated arrays. 
    #         push!(table_countries,country)
    #         push!(table_population_size,N)
    #         push!(table_spatial_scale,spatial_resolution)
    #         push!(table_years,(year_start,year_end))
    #         push!(table_age_categories,AgeCat)
    #         push!(table_mortality_rate_age_categories_all_age,deathrate_allage)
    #         push!(table_mortality_rate_age_categories_more_than_64_yr,deathrate_65plus)
    #         push!(table_global_population_share,popshare)
    #     # end # end of the loop : for (index_country,country) in enumerate(countries_vector)
    # 
    #     # Step 4: Display results
    #     if country == "BRA"
    #         # println("")
    #         # println("=======================================================================================")
    #         # println("Country & N & Years & All-age & Over 65 & pop.share & GDP p.c. & Tmean & Num of Days>28C \\")
    #         # println("---------------------------------------------------------------------------------------")
    #     end
    #     # println("$country & $N & $spatial_resolution & $year_start-$year_end & $AgeCat & $deathrate_allage & $deathrate_65plus & $popshare & $income & $tmean & $daysabove28 \\")
    #     end
    #     # Returning the results: 
    #     results = DataFrame(;table_countries, # This syntax is very practical, I appreciate the use of ";" to make a named object.
    #                         table_population_size,
    #                         table_spatial_scale,
    #                         table_years, 
    #                         table_age_categories, 
    #                         table_mortality_rate_age_categories_all_age,
    #                         table_mortality_rate_age_categories_more_than_64_yr,
    #                         table_global_population_share)
    # 
    #     return results
    # 
    # end
    # This function is defined out of the function scope.

    results_table_1 = statistics_df(filtered_df,countries_vector)

    # Cleaning environment to free memory
    # varinfo()
    filtered_df = nothing
    GC.gc()
    # varinfo()

    GC.gc()

    return results_table_1
end

# We call this function: 

# pre_create_table_1()

# Finally, the function that creates the output: 

function generate_table_1(results_table_1)

    # Convert DataFrame to LaTeX table
    output = IOBuffer()
    show(output, MIME("text/latex"), results_table_1)
    table_latex = String(take!(output))

    # Create LaTeX document
    latex_doc = """
    \\documentclass{article}
    \\usepackage{geometry}
    \\geometry{legalpaper, landscape, margin=0.05in}
    \\begin{document}
    $table_latex
    \\end{document}
    """

    # Save and convert to PDF
    write("table_1.tex", latex_doc)
    Base.run(`pdflatex table_1.tex`)
    # Move to 0_output folder
    Base.run(`mv table_1.pdf 0_output/table_1.pdf`)
    
    # Delete artifacts
    Base.run(`rm table_1.tex`)
    Base.run(`rm table_1.aux`)
    Base.run(`rm table_1.log`)

    # @info string("Table 1 created successfully!")
    # GC.gc()
end

# export generate_table_1()

"""
The function `create_table_1()` creates a `pdf` containing the replication result of the Figure 1.

The `pdf` file is created within the `0_output` folder.

"""
function create_table_1()
    generate_table_1(pre_create_table_1())
    @info string("Table 1 created successfully!")
    println("")
    GC.gc()
end

# create_table_1()

# It could also have been possible to access the latex version of the dataframe directly:
# data_table_1 = latexify(results_table_1; env=:table, booktabs=true, latex=false)


"""
The functio 'delete_table_1()' deletes the pdf of the table 1 in the output folder.
"""
function delete_table_1()
    rm("0_output/table_1.pdf")
end

@info ("Compilation of create_table_1(): Done")