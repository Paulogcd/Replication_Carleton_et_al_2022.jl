# This file is dedicated to the replication of the parts A to C of the file creating the figure 1 of the article. 
# This is the equivalent of: 
# carleton_mortality_2022/1_estimation/3_regressions/3_age_spec_interacted/Figure_I_array_plots.do

# Loading the required packages in Julia: 
using Statistics
using CategoricalArrays
using CSV
using DataFrames
using ReadStatTables
using Plots

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

function create_figure_1()

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

    # Ensuring that the data is loaded:
    load_global_mortality_panel_covariates()
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

    # varinfo()

    @info string("Figure 1: Parts A-C done.")

    # This file is dedicated to the replication of the part D of the file creating the figure 1 of the article. 
    # This is the equivalent of: 
    # carleton_mortality_2022/1_estimation/3_regressions/3_age_spec_interacted/Figure_I_array_plots.do


    # ### STATA:
    # ### PART D. Construct Pop Figures
    # ### use "`DATA'/2_cleaned/covar_pop_count.dta", clear
    # ### rename (loggdppc tmean) (lgdppc Tmean)


    # Ensures that the data is available:
    load_covar_pop_count()
    # Read it: 
    covar_pop_count = DataFrame(ReadStatTables.readstat("0_input/cleaned_data/covar_pop_count.dta"))
    # covar_pop_count_fr = filter(row -> startswith(row.region, "FR"), covar_pop_count)
    rename!(covar_pop_count, :loggdppc => :lgdppc, :tmean => :Tmean)
    # rename!(covar_pop_count_fr, :loggdppc => :lgdppc, :tmean => :Tmean)
    # 
    # covar_pop_count = covar_pop_count_fr
    # 
    # # We set ytile and ttile based on conditions
    # # Here, we enter example values for thresholds:
    # yc1, yc2 = 30, 60  
    # tc1, tc2 = 20, 40  

    ### gen ytile = .
    ### gen ttile = .
    covar_pop_count.ytile .= NaN
    covar_pop_count.ttile .= NaN
    # We use NaN instead of missing for convenience, since Julia is more strict with missing values management.

    ### replace ytile = 1 if lgdppc<=`yc1'
    ###    replace ytile = 2 if lgdppc>`yc1' & lgdppc<=`yc2'
    ###    replace ytile = 3 if lgdppc>`yc2'
    ###    replace ttile = 1 if Tmean<=`tc1'
    ###    replace ttile = 2 if Tmean>`tc1' & Tmean<=`tc2'
    ###    replace ttile = 3 if Tmean>`tc2'
    # From part c (lines ~90) we have set the values of yc1, etc...

    covar_pop_count.ytile[covar_pop_count.lgdppc .<= yc1] .= 1
    covar_pop_count.ytile[covar_pop_count.lgdppc .> yc1 .&& covar_pop_count.lgdppc .<= yc2] .= 2
    covar_pop_count.ytile[covar_pop_count.lgdppc .> yc2] .= 3
    # sum(covar_pop_count.ytile)

    covar_pop_count.ttile[covar_pop_count.Tmean .<= tc1] .= 1
    covar_pop_count.ttile[covar_pop_count.Tmean .> tc1 .&& covar_pop_count.Tmean .<= tc2] .= 2
    covar_pop_count.ttile[covar_pop_count.Tmean .> tc2] .= 3

    # Former version:
    # covar_pop_count[!, :ytile] .= 1
    # covar_pop_count[!, :ytile] .= 2 .+ (covar_pop_count.lgdppc .> yc1 .&& covar_pop_count.lgdppc .<= yc2)
    # covar_pop_count[!, :ytile] .= 3 .+ (covar_pop_count.lgdppc .> yc2)
    # 
    # covar_pop_count[!, :ttile] .= 1
    # covar_pop_count[!, :ttile] .= 2 .+ (covar_pop_count.Tmean .> tc1 .&& covar_pop_count.Tmean .<= tc2)
    # covar_pop_count[!, :ttile] .= 3 .+ (covar_pop_count.Tmean .> tc2)

    ### gen popshare2 = 1 - popshare1 - popshare3
    ### gen pop1 = popshare1*pop
    ### gen pop2 = popshare2*pop
    ### gen pop3 = popshare3*pop
    ### drop if popshare2<0
    covar_pop_count.popshare2 .= 1 .- covar_pop_count.popshare1 .- covar_pop_count.popshare3 
    covar_pop_count.pop1 = covar_pop_count.popshare1.*covar_pop_count.pop
    covar_pop_count.pop2 = covar_pop_count.popshare2.*covar_pop_count.pop
    covar_pop_count.pop3 = covar_pop_count.popshare3.*covar_pop_count.pop
    covar_pop_count = covar_pop_count[covar_pop_count.popshare2 .>= 0, :]

    # Former version:
    # # Generate new population shares and calculate pop1, pop2, pop3
    # covar_pop_count[!, :popshare2] .= 1 .- covar_pop_count.popshare1 .- covar_pop_count.popshare3
    # covar_pop_count[!, :pop1] .= covar_pop_count.popshare1 .* covar_pop_count.pop
    # covar_pop_count[!, :pop2] .= covar_pop_count.popshare2 .* covar_pop_count.pop
    # covar_pop_count[!, :pop3] .= covar_pop_count.popshare3 .* covar_pop_count.pop
    # 
    # # Remove rows where popshare2 < 0
    # covar_pop_count = covar_pop_count[covar_pop_count.popshare2 .>= 0, :]

    ### collapse (sum) pop pop1 pop2 pop3, by(ytile ttile year)
    ### bysort year: egen pop_tot = total(pop)
    ### bysort year: egen pop1_tot = total(pop1)
    ### bysort year: egen pop2_tot = total(pop2)
    ### bysort year: egen pop3_tot = total(pop3)
    ### bysort year: gen pop_per = (pop/pop_tot)*100
    ### bysort year: gen pop1_per = (pop1/pop1_tot)*100
    ### bysort year: gen pop2_per = (pop2/pop2_tot)*100
    ### bysort year: gen pop3_per = (pop3/pop3_tot)*100
    df_collapsed = combine(groupby(covar_pop_count, [:ytile,:ttile,:year]),
        :pop => sum => :pop, :pop1 => sum => :pop1, :pop2 => sum => :pop2, :pop3 => sum => :pop3)
    # As usual, the combine function transforms the name of the columns. We have to specify the name.

    ### bysort year: egen pop_tot = total(pop)
    df_test = combine(groupby(df_collapsed, :year), :pop => sum => :pop_tot)
    df_collapsed = innerjoin(df_collapsed,df_test, on=:year)

    ### bysort year: egen pop1_tot = total(pop1)
    df_test = combine(groupby(df_collapsed, :year), :pop1 => sum => :pop1_tot)
    df_collapsed = innerjoin(df_collapsed,df_test, on=:year)

    ### bysort year: egen pop2_tot = total(pop2)
    df_test = combine(groupby(df_collapsed, :year), :pop2 => sum => :pop2_tot)
    df_collapsed = innerjoin(df_collapsed,df_test, on=:year)

    ### bysort year: egen pop3_tot = total(pop3)
    df_test = combine(groupby(df_collapsed, :year), :pop3 => sum => :pop3_tot)
    df_collapsed = innerjoin(df_collapsed,df_test, on=:year)

    ### bysort year: gen pop_per = (pop/pop_tot)*100
    df_collapsed.pop_per = (df_collapsed.pop./df_collapsed.pop_tot).*100
    # mean(df_collapsed.pop_per) # Same result.

    ### bysort year: gen pop1_per = (pop1/pop1_tot)*100
    df_collapsed.pop1_per = (df_collapsed.pop1./df_collapsed.pop1_tot).*100

    ### bysort year: gen pop2_per = (pop2/pop2_tot)*100
    df_collapsed.pop2_per = (df_collapsed.pop2./df_collapsed.pop2_tot).*100

    ### bysort year: gen pop3_per = (pop3/pop3_tot)*100
    df_collapsed.pop3_per = (df_collapsed.pop3./df_collapsed.pop3_tot).*100

    ### sort year ytile ttile
    ### foreach age of numlist 1/3 {
    ### 	local i = 1
    ### 	foreach y of numlist 1/3 {
    ### 		foreach t of numlist 1/3 {
    ### 			local a`age'_Y`y'T`t'_g_2010 `=round(pop`age'_per[`i'],.50)'
    ### 			local a`age'_Y`y'T`t'_g_2100 `=round(pop`age'_per[`=`i'+9'],.50)'
    ### 			local i = `i' + 1
    ### 		}
    ### 	}
    ### }


    # Here, we are going to try to use an array, instead of the variables names that STATA use.

    # Initialisation of loop: 
    results_1_2010 = Array{Float64}(undef,3,9,3,3)
    fill!(results_1_2010,0)
    results_1_2100 = Array{Float64}(undef,3,9,3,3)
    fill!(results_1_2100,0)

    sort!(df_collapsed, [:year, :ytile, :ttile])
    for age in 1:3
        i = 1
        for y in 1:3
            for t in 1:3
                # println(age,i,y,t)

                # tmp_name_1 = string("pop",age,"per")
                # tmp_name_2 = string("pop",age,"per")

                # tmp_name_2010 = string("a",age,"_Y",y,"T",t,"_g_2010")
                # tmp_name_2100 = string("a",age,"_Y",y,"T",t,"_g_2100")
                
                # Create variables for 2010 and 2100
                var_2010 = Symbol("a$(age)_Y$(y)T$(t)_g_2010")
                var_2100 = Symbol("a$(age)_Y$(y)T$(t)_g_2100")

                # print(tmp_name)
                results_1_2010[age,i,y,t] = round(df_collapsed[!,Symbol("pop$(age)_per")][i], digits=2)
                results_1_2100[age,i,y,t] = round(df_collapsed[!,Symbol("pop$(age)_per")][i+9], digits=2)
                # Assign rounded values from `pop{age}_per` to the variables
                # df_collapsed[!, var_2010][i] = df_collapsed[!, Symbol("pop$(age)_per")][i] # ) #, digits=2)
                # df_collapsed[!, var_2100] = round.(df_collapsed[!, Symbol("pop$(age)_per")][i + 9], digits=2)

                # Increment the index
                i += 1
            end
        end
    end
    # results_1_2010
    # results_1_2100

    # We obtain similar results, with a different dimension of our object. 

    # Former version, kept for the record:
    # # Using groupby and combine to calculate total population by year
    # covar_pop_count_collapsed = combine(groupby(covar_pop_count, [:ytile, :ttile, :year]),
    #                                     :pop => sum, :pop1 => sum, :pop2 => sum, :pop3 => sum)
    # 
    # names(covar_pop_count_collapsed)
    # 
    # covar_pop_count_collapsed[!, :pop_tot] .= transform(groupby(covar_pop_count_collapsed, :year), :pop_sum => sum).pop_sum
    # covar_pop_count_collapsed[!, :pop1_tot] .= transform(groupby(covar_pop_count_collapsed, :year), :pop1_sum => sum).pop1_sum
    # covar_pop_count_collapsed[!, :pop2_tot] .= transform(groupby(covar_pop_count_collapsed, :year), :pop2_sum => sum).pop2_sum
    # covar_pop_count_collapsed[!, :pop3_tot] .= transform(groupby(covar_pop_count_collapsed, :year), :pop3_sum => sum).pop3_sum
    # 
    # # Calculate population percentages per year
    # covar_pop_count_collapsed[!, :pop_per] .= (covar_pop_count_collapsed.pop_sum ./ covar_pop_count_collapsed.pop_sum) .* 100
    # covar_pop_count_collapsed[!, :pop1_per] .= (covar_pop_count_collapsed.pop1_sum ./ covar_pop_count_collapsed.pop1_sum) .* 100
    # covar_pop_count_collapsed[!, :pop2_per] .= (covar_pop_count_collapsed.pop2_sum ./ covar_pop_count_collapsed.pop2_sum) .* 100
    # covar_pop_count_collapsed[!, :pop3_per] .= (covar_pop_count_collapsed.pop3_sum ./ covar_pop_count_collapsed.pop3_sum) .* 100
    # 
    # # Create age-specific population figures for 2010 and 2100
    # # Assuming pop1_per, pop2_per, pop3_per are ordered for each group
    # age_specific_pop_2010 = Array{Vector}
    # age_specific_pop_2100 = Array{Vector}
    # 
    # for i in 1:nrow(covar_pop_count_collapsed)
    #     for y in 1:3
    #         for t in 1:3
    #             local_idx = findall((covar_pop_count_collapsed.ytile .== y) .& (covar_pop_count_collapsed.ttile .== t))[i]
    #             push!(age_specific_pop_2010, round(covar_pop_count_collapsed.pop_per[local_idx], 0.5))
    #             push!(age_specific_pop_2100, round(covar_pop_count_collapsed.pop_per[local_idx + 9], 0.5))  # 9 for 2100
    #         end
    #     end
    # end


    ### Now, the authors do:
    ### * gen total age shares
    ### local i = 1
    ### sort year ytile ttile
    ### foreach y of numlist 1/3 {
    ###     foreach t of numlist 1/3 {
    ###         local a_Y`y'T`t'_g_2010 = round(pop_per[`i'],.50)
    ###         local a_Y`y'T`t'_g_2100 = round(pop_per[`=`i'+9'],.50)
    ###         local i = `i' + 1
    ###     }
    ### }
    ### restore

    # Initialisation:
    sort!(df_collapsed, [:ytile,:ttile])
    global i = 1

    results_2_2010 = Array{Float64}(undef,3,9,3)
    fill!(results_2_2010,0)
    results_2_2100 = Array{Float64}(undef,3,9,3)
    fill!(results_2_2100,0)

    for y in 1:3
        for t in 1:3
            results_2_2010[y,i,t] = round(df_collapsed.pop_per[i],digits=2)
            results_2_2100[y,i,t] = round(df_collapsed.pop_per[i+9],digits=2)
            global i += 1
        end
    end
    i = nothing
    results_2_2010
    results_2_2100

    # Former version, kept for the record:
    # Total age shares for 2010 and 2100
    # total_age_pop_2010 = []
    # total_age_pop_2100 = []
    # 
    # for y in 1:3
    #     for t in 1:3
    #         local_idx = findall((covar_pop_count_collapsed.ytile .== y) .& (covar_pop_count_collapsed.ttile .== t))
    #         push!(total_age_pop_2010, round(covar_pop_count_collapsed.pop_per[local_idx], 0.5))
    #         push!(total_age_pop_2100, round(covar_pop_count_collapsed.pop_per[local_idx + 9], 0.5))  # 9 for 2100
    #     end
    # end
    # 
    #

    # df_collapsed 

    # The authors then restore, obtaining: 
    # part_D_result = ["ytile"	"ttile"	"loggdppc_adm1_avg"	"lr_tavg_GMFD_adm1_avg"	"max_lr_tavg_GMFD_adm1_avg"	"max_loggdppc_adm1_avg"
    # 1	3	8.962444	22.9691	22.9691	9.024742
    # 1	1	8.827487	7.957425	9.160113	9.024742
    # 1	2	9.024742	13.51241	13.51241	9.024742
    # 2	2	9.995737	13.37068	13.51241	9.995737
    # 2	3	9.902338	19.6678	22.9691	9.995737
    # 2	1	9.950479	9.160113	9.160113	9.995737
    # 3	3	10.2809	18.52221	22.9691	10.33297
    # 3	2	10.32087	12.88194	13.51241	10.33297
    # 3	1	10.33297	8.609725	9.160113	10.33297
    # ]

    # part_D_result = DataFrame(part_D_result, :auto)

    @info ("Figure 1: Part D done.")

    # This file is dedicated to the replication of the part E of the file creating the figure 1 of the article. 
    # This is the equivalent of: 
    # carleton_mortality_2022/1_estimation/3_regressions/3_age_spec_interacted/Figure_I_array_plots.do

    # using DataFrames, GLM, Plots, StatsBase
    # using Plots

    # In case we did not perform the previous files (2_figure_1_a_c.jl and 2_figure_1_d.jl): 

    # df = DataFrame(readdta("3_final/global_mortality_panel_covariates.dta"))
    # covar_pop_count = DataFrame(ReadStatTables.readstat("0_input/final_data/global_mortality_panel_covariates.dta"))
    # df = covar_pop_count_fr = filter(row -> startswith(row.iso, "FR"), covar_pop_count)

    # Assuming `MORTALITY_TEMP` and `tercile` are loaded as DataFrames
    # Example initialization (you'll need to replace these with actual loading)
    # df_mortality = df 
    # df_tercile

    # df = DataFrame(ReadStatTables.readstat("0_input/final_data/global_mortality_panel_covariates.dta"))
    # df

    ### *----------------------------------
    ### *generating age-specific plots
    ### *----------------------------------

    # We also initialise an empty vector that will contain our plots: 
    vector_of_plots = Array{Plots.Plot{Plots.GRBackend}}(undef,3,9)

    df_merged = dropmissing(innerjoin(df,df_tercile, on=:adm1_code, makeunique=true), :ytile) ## CURENT DF LOADED

    ### foreach age of numlist 1/3
    for age in 1:3 # age = 1
        
        ### use `MORTALITY_TEMP', clear
        ### merge m:1 adm1_code using "`tercile'"
        ### drop if ytile==.

        # We can set this outside the loop.
        # df_merged = dropmissing(innerjoin(df,df_tercile, on=:adm1_code, makeunique=true), :ytile) ## CURENT DF LOADED

        ### foreach y of numlist 1/3 {
        ### 	foreach T of numlist 1/3 {
        ### 		count if ytile == `y' & ttile == `T' & agegroup==`age'
        ### 		local obs_`y'_`T'_`age' = r(N)
        ### 	}
        ### }

        # Similarily to earlier, we are going to use an array to store these data: 
        observations = Array{Float64}(undef,3,3)
        fill!(observations,0)
        for y in 1:3
            for T in 1:3
                tmp1 = df_merged[df_merged.ytile .== y,:]
                tmp2 = tmp1[tmp1.ttile .== T,:]
                tmp3 = tmp2[tmp2.agegroup .== age,:]
                tmp = size(tmp3)[1]

                # Former version : 
                # tmp = sum(df_merged.ytile .== y .&& df_merged.ttile .== T .&& df_merged.agegroup == age)
                observations[y,T] = tmp
            end
        end
        tmp = tmp1 = tmp2 = tmp3 = nothing # We clear the data
        GC.gc() # And call the garbage collector
        observations # We obtain very close results.

        ### 	collapse (mean) loggdppc_adm1_avg lr_tavg_GMFD_adm1_avg, by(ytile ttile)
        global df_collapsed = combine(groupby(df_merged, [:ytile, :ttile]),
            :loggdppc_adm1_avg => mean => :loggdppc_adm1_avg,
            :lr_tavg_GMFD_adm1_avg => mean => :lr_tavg_GMFD_adm1_avg)

        ### 	*initialize
        ### gen tavg_poly_1_GMFD =.
        ### gen deathrate_w99 =.

        df_collapsed.tavg_poly_1_GMFD .= NaN
        df_collapsed.deathrate_w99 .= NaN
        # df_collapsed

        ### local ii = 1    
        ### foreach y of numlist 1/3 {
        ### 	foreach T of numlist 1/3 {
        ii = 1
        for y in 1:3 # y=1
            for T in 1:3 # T = 1

                ### preserve
                ### keep if ytile == `y' & ttile == `T'

                global filtered_df = df_collapsed[df_collapsed.ytile .== y .&& df_collapsed.ttile .== T, :]
                # Checked: same result.

                ###     foreach var in "loggdppc_adm1_avg" "lr_tavg_GMFD_adm1_avg" {
                ###         loc zvalue_`var' = `var'[1]
                ###     }

                # This time, due to the specific names of the variables, we use a dictionary instead of an array.
                variables = ["loggdppc_adm1_avg", "lr_tavg_GMFD_adm1_avg"]
                zvalues = Dict()
                for vari in variables
                    zvalues[vari] = filtered_df[1, vari]  # Assign the first value of the variable
                end
                # Check: we obtain the same values at 2 digits.
                
                ###     *obs	
                ###     local min = `x_min'
                ###     local max = `x_max'
                ###     local obs = `max' - `min' + 1
                ###     local omit = 20

                # Setting local variables
                min_value = x_min
                max_value = x_max
                obs = max_value - min_value + 1
                omit = 20

                ### drop if _n > 0
                ### set obs `obs'
                ### replace tavg_poly_1_GMFD = _n + `min' - 1

                # This now is a bit more delicate to interpret. 
                # This STATA code deletes the currently loaded dataset, and create a vector of 46 dimensions named "tavg_poly_1_GMFD". 
                # The STATA code refers to it as "tavg_poly_1_GMFD", but if we were to perform the exact same operation, we would need 
                # to delete the dataframe, and create a new one, with empty values, and only a non-empty "tavg_poly_1_GMFD" column.
                # This is not convenient, we can therefore just create a new variable.

                # for i in (1:size(df_collapsed)[1])
                #     delete!(df_collapsed, [1])
                # end
                # df_collapsed

                tavg_GMFD_adm1_avg = obs = x_min:x_max

                # This does not correspond to the STATA code, but is a fair approximation. 
                # We have a vector containing what they have in their loaded dataframe. 
                # To be complete, we can try: 

                # names(df_collapsed)
                # ytile                       = zeros(size(obs))
                # ttile                       = zeros(size(obs))
                # loggdppc_adm1_avg           = zeros(size(obs))
                # lr_tavg_GMFD_adm1_avg       = obs
                # tavg_poly_1_GMFD            = zeros(size(obs))
                # deathrate_w99               = zeros(size(obs))

                loaded_df = DataFrame(            
                ytile                       = zeros(size(obs)), 
                ttile                       = zeros(size(obs)), 
                loggdppc_adm1_avg           = zeros(size(obs)), 
                lr_tavg_GMFD_adm1_avg       = zeros(size(obs)),
                tavg_poly_1_GMFD            = obs,
                deathrate_w99               = zeros(size(obs)))

                # tavg_poly_1_GMFD

                ### *----------------------------------
                ### *Polynomial (4) 
                ### *----------------------------------

                ### * estimate use "`STER'/Agespec_interaction_response.ster"
                ### estimate use "/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster"
                ### estimates
                
                # This part was very tricky, and time consuming.
                # The .ster format is not supported by Julia.
                # I had to run on STATA: 
                ### estimate use "/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster"
                ### estout using coefficients.csv, replace cells(b se t p) varlabels(_cons Constant) stats(N r2_a, labels("Observations" "Adj. R-squared")) delimiter(",")
                # To obtain a csv file with partial equivalent data. 
                # This export fashion led to some complication, due to to format issue. 
                # In the following section, I use a workaround to create an acceptable csv file.

                # Ensuring data is available: 
                if T == y == age == 1
                    load_coefficients()
                end
                # loading the data:
                data = CSV.read("0_input/ster/coefficients.csv", DataFrame)
                # We can delete the two first lines: 
                data = data[Not(1),:]
                data = data[Not(1),:]
                # data = data[Not(1),:]
                # coefficients, standard errors, t-statistics, p-value.
                tmp = Array{String}(undef,38)
                for (index_row,row) in enumerate(1:4:size(data)[1])
                    tmp[index_row] = data[row,1]
                    
                    if tmp[index_row] == "Observations" # At the end, irregularity.
                        break
                    end
                    
                    data[row+1,1] = string(tmp[index_row],"_se")
                    data[row+2,1] = string(tmp[index_row],"_t-statistics")
                    data[row+3,1] = string(tmp[index_row],"_p-value")
                    # println(tmp[index_row])
                end
                # data[3,1]
                # This yields a csv with all the statistics, but with variables in rows.
                # data
                # It is however easier to access variables if they are in the columns. 
                data = permutedims(data, 1) # This is it.
                data = data[:,Not(1)]

                # Last thing: the data is currently in String... We want Floats!
                data = tryparse.(Float64, data[:, :])
                # data[1,1]

                # Former version, kept for the record:
                # data = read("/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster",String)
                # data = readstat("/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster")
                # data = readstat("/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/data.txt")

                # run(`touch 0_input/ster/data.txt`)
                # run(`cat 0_input/ster/Agespec_interaction_response.ster ">" 0_input/ster/data.txt`)
                # data = read("0_input/ster/data.txt", String)

                # Then, the authors do:

                ### *uninteracted terms
                ### local line = "_b[`age'.agegroup#c.tavg_poly_1_GMFD]*(tavg_poly_1_GMFD-`omit')"

                # Here, the STATA syntax can be confusing. 
                # Indeed, this program stores a "line" macro that is a formula, only 
                # used a the end of the loop. 

                # The "_b[]" syntax in STATA refers to estimates.
                # Since we have loaded the "data" dataframe, we can use "data[:,name]" each time STATA refers to "_b[name]".

                # This could be handled by the Symbol() objects of Julia.
                # We could also try to assess the "line" and "add" variables bit by bit.

                # First, let us define a Julia symbol, to contain the name of the variable that contains "." and "#", 
                # which are both special characters in Julia. 
                tmp = Symbol("$age.agegroup#c.tavg_poly_1_GMFD")
                # line = Symbol("(data[:,$tmp].*tavg_poly_1_GMFD) .- $omit") # Former attempt 
                # Then, we can directly evaluate: 
                line = (data[:,tmp].*tavg_GMFD_adm1_avg) .- omit
                # This is consistent with what we obtain via STATA, i.e. a 46-dimensions vector. 

                # Former attempts, kept for the record:
                # data[:,tmp]
                # line = Symbol("(data.'$tmp'.*df_collapsed.tavg_poly_1_GMFD) .- $omit")
                # line = string(line)
                # line
                # line_parse = Meta.parse(line)

                # Then, the authors do: 

                ### foreach k of numlist 2/`o' {
                ### 	*replace tavg_poly_`k'_GMFD = tavg_poly_1_GMFD ^ `k'
                ### 	local add = "+ _b[`age'.agegroup#c.tavg_poly_`k'_GMFD]*(tavg_poly_1_GMFD^`k' - `omit'^`k')"
                ### 	local line "`line' `add'"
                ### 	}

                for k in 2:o # k=2
                    tmp = string(age,".agegroup#c.tavg_poly_",k,"_GMFD")
                    tmp = Symbol(tmp)
                    # *(tavg_poly_1_GMFD^`k' - `omit'^`k')
                    # add = Symbol("+ data[:,$tmp].*")
                    to_add = (data[:,tmp].*(loaded_df.tavg_poly_1_GMFD .^ k .- omit^k)) 
                    # data[:,tmp]
                    # df_collapsed.tavg_poly_1_GMFD .^ k 
                    # omit^k
                    # add = Symbol("+ data[:,tmp].*(df_collapsed.tavg_poly_1_GMFD.^$k .- omit^$k)")
                    
                    ### local line "`line' `add'"
                    # We just evaluate:
                    line .= line .+ to_add
                end

                # lgdppc and Tmean at the tercile mean

                ### *lgdppc and Tmean at the tercile mean
                ### foreach var in "loggdppc_adm1_avg" "lr_tavg_GMFD_adm1_avg" {
                ### 	loc z = `zvalue_`var''
                ### 	foreach k of numlist 1/`o' {
                ### 		*replace tavg_poly_`k'_GMFD = tavg_poly_1_GMFD ^ `k'
                ### 		local add = "+ _b[`age'.agegroup#c.`var'#c.tavg_poly_`k'_GMFD] * (tavg_poly_1_GMFD^`k' - `omit'^`k') * `z'"
                ### 		local line "`line' `add'"
                ### 		}
                ### 	}

                # This is bugging. 
                # The source of their original variable is still to determine.
                if false 
                    for vari in ["loggdppc_adm1_avg" ,"lr_tavg_GMFD_adm1_avg"]
                        z = string("zvalue_",vari)
                        for k in 1:o
                            
                            # Directly translating from the STATA code: 
                            ### local add = "+ _b[`age'.agegroup#c.`var'#c.tavg_poly_`k'_GMFD] * (tavg_poly_1_GMFD^`k' - `omit'^`k') * `z'"

                            tmp = string(age,".agegroup#c.",vari,"#c.tavg_poly_",k,"_GMFD")
                            tmp = Symbol(tmp)
                            # However, this yields a name that is not in the estimates data: 
                            tmp ∈ names(data) # false !!!
                            # If we use data[:,tmp] with the current value of tmp, this yields an empty vector for "line".
                            
                            # data[:"1.agegroup#c.loggdppc_adm1_avg"]
                            # to_add = data[:,tmp] .* loaded_df[:,loaded_df.tavg_poly_1_GMFD]^k .- omit^k # .* z 
                            
                            # data[:,"1.agegroup#c.loggdppc_adm1_avg"]
                            "1.agegroup#c.tavg_poly_1_GMFD" ∈ names(data) # This exists in the data,
                            "1.agegroup#c.loggdppc_adm1_avg" ∈ names(data) # This does not exists in the data.
                            
                            ### local add = "+ _b[`age'.agegroup#c.`var'#c.tavg_poly_`k'_GMFD] * (tavg_poly_1_GMFD^`k' - `omit'^`k') * `z'"
                            # df_collapsed[:,z]
                            # Ambiguous... Where is the z? 
                            
                            # We just evaluate:
                            line .= line .+ to_add
                            @warn ("This should not appear.")
                            # The problem comes from loaded coefficients from the ster file. 
                            # However, this seems to also have the same behavior in the original replication package.
                        end
                    end
                end

                # println(line)

                # The authors then do: 
                ### predictnl yhat_poly`o'_pop = `line', se(se_poly`o'_pop) ci(lowerci_poly`o'_pop upperci_poly`o'_pop)

                # This STATA command serves to run the mentioned model (by line), and specifies the standard errors, 
                # and confidence intervals.
                
                # In our attempt, we can just take the values of the "line" vector.
                # This is already done, and line does not contain a formula, but the values directly.

                yhat_poly4_pop = line
                # println(" ")
                # println("figure 1: Part Polynomial (4) done for age = ", age, ", y = ", y, ", T = ", T, ", ii = ", ii)

                ### ______________________WARNING______________________: 
                # The above issue has been examined in detail.
                # To the best of our knowledge, this discrepancy of results is due to differences in the "data" DataFrame,
                # containing the estimates.
                # The estimates from the original replication package have been put in a file "0_input/estimates.csv".

                ### *----------------------------------
                ### * Clipping
                ### *----------------------------------

                ### if `yclip' == 1 {
                ### 	foreach var of varlist yhat_poly`o'_pop lowerci_poly`o'_pop upperci_poly`o'_pop {
                ### 		replace `var' = `yclipmax_a`age'' if `var' > `yclipmax_a`age''
                ### 		replace `var' = `yclipmin_a`age'' if `var' < `yclipmin_a`age''
                ### 	}
                ### }
                
                # This STATA code is replicable due to the lack of data from the "predict" command. 
                # Indeed, we do not have the lower and upper confidence intervals in our simplified version.
                
                if (yclip == 1) & false # prohibiting condition
                    # string("yhat_poly",o,"_pop")
                    varlist = [string("yhat_poly",o,"_pop"), string("lowerci_poly",o,"_pop"), string("upperci_poly",o,"_pop")]
                    for vari in varlist
                        tmp1 = string("yclipmax_a$age")
                        tmp1 = Symbol(tmp1)
                        # eval(tmp1)

                        tmp2 = string("yclipmin_a$age")
                        tmp2 = Symbol(tmp2)
                        # eval(tmp2)
                        
                        if vari > eval(tmp1)
                            vari = eval(tmp1)
                        elseif vari < eval(tmp2)
                            vari = eval(tmp2)
                        end
                    end
                end

                ### local graph_`ii' "(line yhat_poly4_pop tavg_poly_1_GMFD, lc(black) lwidth(medthick)) (rarea lowerci_poly4_pop upperci_poly4_pop tavg_poly_1_GMFD, col(gray%25) lwidth(none))" display("saved `graph_`ii'' `ii'")
                
                # This STATA command creates a "graph" object, such that:

                # yhat_poly4_pop is the Y-variable (predicted values)
                # tavg_poly_1_GMFD is the X-variable 
                # lc(black) sets the line color to black.
                # lwidth(medthick) sets the line width to medium thickness.

                # In this sense, we can try: 
                vector_of_plots[age,ii] = 
                Plots.plot(loaded_df.tavg_poly_1_GMFD, yhat_poly4_pop, color=:black, linewidth=2, label="Prediction")
                # fill_between = fill_between = fill_between = plot!(tavg_poly_1_GMFD, lowerci_poly4_pop, upperci_poly4_pop, fillalpha=0.25, color=:gray, label="95% CI")

                ### *----------------------------------
                ### * Set axes and titles
                ### *----------------------------------

                ### loc ytit "Deaths per 100k"
                ### loc xtit "Temperature (°C)"
                ### loc empty ""
                ### loc space "" ""
                ytit = "Deaths per 100k"
                xtit = "Temperature (°C)"
                empty = ""
                space = " "

                ### if `ii' == 7 | `ii' == 4 {
                ### 	loc ylab "ytitle(`ytit') ylabel(, labsize(small))"
                ### 	loc xlab "xtitle(`space') xlabel(none) xscale(off) fysize(25.2)"
                ### } 
                if ii == 7 | ii ==4
                    # ylab = string("ytitle(",$ytit,") ylabel(, labsize(small))")
                    # xlab = string("xtitle(",$space,") xlabel(none) xscale(off) fysize(25.2)")
                end

                # ...

                ### *----------------------------------
                ### * Plot charts
                ### *----------------------------------

                ### if `ycommon' == 1 {
                ### 	twoway `graph_conc' ///
                ### 	, yline(0, lcolor(red%50) lwidth(vvthin)) name(matrix_Y`y'_T`T'_noSE, replace) ///
                ### 	`xlab' `ylab' plotregion(icolor(white) lcolor(black)) ///
                ### 	graphregion(color(white)) legend(off) ///						
                ### 	text(`a`age'_y' `a_x' "{bf:%POP 2010: `a`age'_Y`y'T`T'_g_2010'}", place(ne) size(small)) ///
                ### 	text(`a`age'_y' `a_x' "{bf:%POP 2100: `a`age'_Y`y'T`T'_g_2100'}", place(se) color(gray) size(small))
                ### }
                if ycommon == 1
                    
                # ...

                ### else {
                ### 	twoway `graph_conc' ///
                ### 	, yline(0, lcolor(gs5) lwidth(vthin)) name(matrix_Y`y'_T`T'_noSE, replace) ///
                ### 	`xlab' `ylab' plotregion(icolor(white) lcolor(black)) ///
                ### 	graphregion(color(white)) legend(off) 
                ### }
                else
                    # ...
                end

                ii += 1

            end # end of T loop
        end # end of y loop
    end # end of age loop

    # varinfo()

    # vector_of_plots

    # Plots.plot(vector_of_plots[1,1])
    # Plots.plot(vector_of_plots[1,2])
    # Plots.plot(vector_of_plots[1,3])
    # Plots.plot(vector_of_plots[1,4])
    # Plots.plot(vector_of_plots[1,5])
    # Plots.plot(vector_of_plots[1,6])
    # Plots.plot(vector_of_plots[1,7])
    # Plots.plot(vector_of_plots[1,8])
    # Plots.plot(vector_of_plots[1,9])
    # Plots.plot(vector_of_plots[2,1])
    # Plots.plot(vector_of_plots[2,2])
    # Plots.plot(vector_of_plots[2,3])
    # Plots.plot(vector_of_plots[2,4])
    # Plots.plot(vector_of_plots[2,5])
    # Plots.plot(vector_of_plots[2,6])
    # Plots.plot(vector_of_plots[2,7])
    # Plots.plot(vector_of_plots[2,8])
    # Plots.plot(vector_of_plots[2,9])
    # Plots.plot(vector_of_plots[3,1])
    # Plots.plot(vector_of_plots[3,2])
    # Plots.plot(vector_of_plots[3,3])
    # Plots.plot(vector_of_plots[3,4])
    # Plots.plot(vector_of_plots[3,5])
    # Plots.plot(vector_of_plots[3,6])
    # Plots.plot(vector_of_plots[3,7])
    # Plots.plot(vector_of_plots[3,8])
    # Plots.plot(vector_of_plots[3,9])

    # Plots.plot()
    @info ("Figure 1: part E done.")

    # vector_of_plots[1,1]

    @info string("Creating Figure 1 subfigures...")
    savefig(vector_of_plots[1,1], "0_output/Figure_1_1.png")
    savefig(vector_of_plots[2,1], "0_output/Figure_1_2.png")
    savefig(vector_of_plots[3,1], "0_output/Figure_1_3.png")
    @info string("Subfigures of figure 1 successfully created!")

end

@info ("Compilation of create_figure_1(): Done")