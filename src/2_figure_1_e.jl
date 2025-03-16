using DataFrames, GLM, Plots, StatsBase



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

### foreach age of numlist 1/3
for age in 1:3
    
    ### use `MORTALITY_TEMP', clear
	### merge m:1 adm1_code using "`tercile'"
	### drop if ytile==.

    df_merged = dropmissing(innerjoin(df,df_tercile, on=:adm1_code, makeunique=true), :ytile)

	### foreach y of numlist 1/3 {
	### 	foreach T of numlist 1/3 {
	### 		count if ytile == `y' & ttile == `T' & agegroup==`age'
	### 		local obs_`y'_`T'_`age' = r(N)
	### 	}
	### }
    observations = Array{Float64}(undef,3,3)
    fill!(observations,0)
    for y in 1:3
        for T in 1:3
            tmp = sum(df_merged.ytile .== y .|| df_merged.ttile .== T .|| df_merged.agegroup == age)
            observations[y,T] = tmp
        end
    end
    observations

    # 1 ∈  df_merged.agegroup

    ### 	collapse (mean) loggdppc_adm1_avg lr_tavg_GMFD_adm1_avg, by(ytile ttile)
    df_collapsed = combine(groupby(df_merged, [:ytile, :ttile]),
        :loggdppc_adm1_avg => mean => :loggdppc_adm1_avg,
        :lr_tavg_GMFD_adm1_avg => mean => :lr_tavg_GMFD_adm1_avg)

    ### 	*initialize
	### gen tavg_poly_1_GMFD =.
	### gen deathrate_w99 =.

    df_collapsed.tavg_poly_1_GMFD .= NaN
    df_collapsed.deathrate_w99 .= NaN
			
    ### local ii = 1    
    ### foreach y of numlist 1/3 {
	### 	foreach T of numlist 1/3 {
    for y in 1:3
        for T in 1:3

            ### preserve
			### keep if ytile == `y' & ttile == `T'

            ###     foreach var in "loggdppc_adm1_avg" "lr_tavg_GMFD_adm1_avg" {
            ###         loc zvalue_`var' = `var'[1]
            ###     }
            
            ###     *obs	
            ###     local min = `x_min'
            ###     local max = `x_max'
            ###     local obs = `max' - `min' + 1
            ###     local omit = 20
    
            # tmp_df_collapsed = filter(df_collapsed, df_collapsed.ytile .== y)

            filtered_df = df_collapsed[df_collapsed.ytile .== y .&& df_collapsed.ttile .== T, :]
            # Iterate over the specified variables
            variables = ["loggdppc_adm1_avg", "lr_tavg_GMFD_adm1_avg"]
            zvalues = Dict()
            for var in variables
                zvalues[var] = filtered_df[1, var]  # Assign the first value of the variable
            end
            # Setting local variables
            min_value = x_min
            max_value = x_max
            obs = max_value - min_value + 1
            omit = 20

            ### drop if _n > 0
			### set obs `obs'
			### replace tavg_poly_1_GMFD = _n + `min' - 1

            df_collapsed = DataFrame()
            df_collapsed = DataFrame(tavg_poly_1_GMFD = 1:obs)
            # Replace values in the variable tavg_poly_1_GMFD
            df_collapsed.tavg_poly_1_GMFD = df_collapsed.tavg_poly_1_GMFD .+ min_value .- 1

            ### *----------------------------------
			### *Polynomial (4) 
			### *----------------------------------

            # data = read("/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster",String)
            # data = readstat("/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster")
            # data = readstat("/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/data.txt")

            # run(`touch 0_input/ster/data.txt`)
            # run(`cat 0_input/ster/Agespec_interaction_response.ster ">" 0_input/ster/data.txt`)
            # data = read("0_input/ster/data.txt", String)
            
            # This part was very tricky, and time consuming.
            # The .ster format is not supported by Julia.
            # I had to run on STATA: 
            ### estimate use "/Users/paulogcd/Documents/Replication_Carleton_et_al_2022.jl/0_input/ster/Agespec_interaction_response.ster"
            ### estout using coefficients.csv, replace cells(b se t p) varlabels(_cons Constant) stats(N r2_a, labels("Observations" "Adj. R-squared")) delimiter(",")
            # To obtain a csv file with equivalent data. 
            # This export fashion led to some complication, due to to format issue. 
            # In the following section, I use a workaround to create an acceptable csv file.

            data = CSV.read("0_input/ster/coefficients.csv", DataFrame)
            # coefficients, standard errors, t-statistics, p-value.
            tmp = Array{String}(undef,38)
            for (index_row,row) in enumerate(2:4:size(data)[1])
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
            # We can delete the first line: 
            data = data[Not(1),:]
            # This yields a csv with all the statistics, but with variables in rows.
            # data
            # It is however easier to access variables if they are in the columns. 
            data = permutedims(data, 1) # This is it.
            data = data[:,Not(1)]

            # Last thing: the data is currently in String... We want Floats!
            data = tryparse.(Float64, data[:, :])
            # data

            # Here, the STATA syntax can be confusing. 
            # Indeed, this program stores a "line" macro that is a formula, only 
            # used a the end of the loop. 

            # This can be handled by the Symbol() objects of Julia ?
            # We could also try to assess the "line" and "add" variables bit by bit.

            ### *uninteracted terms
			### local line = "_b[`age'.agegroup#c.tavg_poly_1_GMFD]*(tavg_poly_1_GMFD-`omit')"
			### foreach k of numlist 2/`o' {
			### 	*replace tavg_poly_`k'_GMFD = tavg_poly_1_GMFD ^ `k'
			### 	local add = "+ _b[`age'.agegroup#c.tavg_poly_`k'_GMFD]*(tavg_poly_1_GMFD^`k' - `omit'^`k')"
			### 	local line "`line' `add'"
			### 	}
            # "$age.agegroup#c.tavg_poly_1_GMFD"
            
            tmp = Symbol("$age.agegroup#c.tavg_poly_1_GMFD")
            # line = Symbol("(data[:,$tmp].*df_collapsed.tavg_poly_1_GMFD) .- $omit")
            line = (data[:,tmp].*df_collapsed.tavg_poly_1_GMFD) .- omit
            # data[:,tmp]
            # line = Symbol("(data.'$tmp'.*df_collapsed.tavg_poly_1_GMFD) .- $omit")
            
            # line = string(line)
            # line
            # line_parse = Meta.parse(line)

            # uninteracted terms
            for k in 2:o
                tmp = string(age,".agegroup#c.tavg_poly_",k,"_GMFD")
                tmp = Symbol(tmp)
                # *(tavg_poly_1_GMFD^`k' - `omit'^`k')
                # add = Symbol("+ data[:,$tmp].*")
                to_add = (data[:,tmp].*(df_collapsed.tavg_poly_1_GMFD.^k .- omit^k)) 
                # add = Symbol("+ data[:,tmp].*(df_collapsed.tavg_poly_1_GMFD.^$k .- omit^$k)")
                
                ### local line "`line' `add'"
                # We just evaluate:
                line .= line .+ to_add
            end

            # lgdppc and Tmean at the tercile mean
            
            if false # The source of their original variable is still to determine.
                for vari in ["loggdppc_adm1_avg" ,"lr_tavg_GMFD_adm1_avg"]
                    z = string("zvalue_",vari)
                    for k in 1:o
                        tmp = string(age,".agegroup#c.",vari,"#c.tavg_poly_",k,"_GMFD")
                        tmp = Symbol(tmp)
                        to_add = data[:,tmp] .* df_collapsed[:,tavg_poly_1_GMFD]^k .- omit^k # .* z 
                        ### local add = "+ _b[`age'.agegroup#c.`var'#c.tavg_poly_`k'_GMFD] * (tavg_poly_1_GMFD^`k' - `omit'^`k') * `z'"
                        # df_collapsed[:,z]
                        # Ambiguous... Where is the z? 
                        
                        # local line line add ? 
                        # We just evaluate:
                        line .= line .+ to_add
                        print("This should not appear.")
                    end
                end
            end

            print(line)

            ### predictnl yhat_poly`o'_pop = `line', se(se_poly`o'_pop) ci(lowerci_poly`o'_pop upperci_poly`o'_pop)

            # yhat_poly'o'_pop = line

            ### *----------------------------------
			### * Clipping
			### *----------------------------------

            ### if `yclip' == 1 {
			### 	foreach var of varlist yhat_poly`o'_pop lowerci_poly`o'_pop upperci_poly`o'_pop {
			### 		replace `var' = `yclipmax_a`age'' if `var' > `yclipmax_a`age''
			### 		replace `var' = `yclipmin_a`age'' if `var' < `yclipmin_a`age''
			### 	}
			### }
            if (yclip == 1)
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
            # ? 
            # line
            # Sample data (replace with real data)
            using Plots
            tavg_poly_1_GMFD = collect(-10:0.1:10)  # X-axis values
            yhat_poly4_pop = sin.(tavg_poly_1_GMFD) # Predicted values
            lowerci_poly4_pop = yhat_poly4_pop .- 0.2 # Lower bound
            upperci_poly4_pop = yhat_poly4_pop .+ 0.2 # Upper bound

            
            plot(tavg_poly_1_GMFD, yhat_poly4_pop, color=:black, linewidth=2, label="Prediction")
            fill_between = fill_between = fill_between = plot!(tavg_poly_1_GMFD, lowerci_poly4_pop, upperci_poly4_pop, fillalpha=0.25, color=:gray, label="95% CI")

        end
    end
end