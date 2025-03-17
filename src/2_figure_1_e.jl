# This file is dedicated to the replication of the part E of the file creating the figure 1 of the article. 
# This is the equivalent of: 
# carleton_mortality_2022/1_estimation/3_regressions/3_age_spec_interacted/Figure_I_array_plots.do

# using DataFrames, GLM, Plots, StatsBase
using Plots

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

### foreach age of numlist 1/3
for age in 1:3 # age = 1
    
    ### use `MORTALITY_TEMP', clear
	### merge m:1 adm1_code using "`tercile'"
	### drop if ytile==.

    df_merged = dropmissing(innerjoin(df,df_tercile, on=:adm1_code, makeunique=true), :ytile) ## CURENT DF LOADED

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
    df_collapsed = combine(groupby(df_merged, [:ytile, :ttile]),
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

            filtered_df = df_collapsed[df_collapsed.ytile .== y .&& df_collapsed.ttile .== T, :]
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
                        println("This should not appear.")
                        # The problem comes from loaded coefficients from the ster file. 
                        # However, this seems to also have the same behavior in the original replication package.
                    end
                end
            end

            println(line)

            # The authors then do: 
            ### predictnl yhat_poly`o'_pop = `line', se(se_poly`o'_pop) ci(lowerci_poly`o'_pop upperci_poly`o'_pop)

            # This STATA command serves to run the mentioned model (by line), and specifies the standard errors, 
            # and confidence intervals.
            
            # In our attempt, we can just take the values of the "line" vector.
            # This is already done, and line does not contain a formula, but the values directly.

            yhat_poly4_pop = line
            println(" ")
            println("Figure 2: Part Polynomial (4) done for age = ", age, ", y = ", y, ", T = ", T, ", ii = ", ii)

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

vector_of_plots

Plots.plot(vector_of_plots[1,1])
Plots.plot(vector_of_plots[1,2])
Plots.plot(vector_of_plots[1,3])
Plots.plot(vector_of_plots[1,4])
Plots.plot(vector_of_plots[1,5])
Plots.plot(vector_of_plots[1,6])
Plots.plot(vector_of_plots[1,7])
Plots.plot(vector_of_plots[1,8])
Plots.plot(vector_of_plots[1,9])
Plots.plot(vector_of_plots[2,1])
Plots.plot(vector_of_plots[2,2])
Plots.plot(vector_of_plots[2,3])
Plots.plot(vector_of_plots[2,4])
Plots.plot(vector_of_plots[2,5])
Plots.plot(vector_of_plots[2,6])
Plots.plot(vector_of_plots[2,7])
Plots.plot(vector_of_plots[2,8])
Plots.plot(vector_of_plots[2,9])
Plots.plot(vector_of_plots[3,1])
Plots.plot(vector_of_plots[3,2])
Plots.plot(vector_of_plots[3,3])
Plots.plot(vector_of_plots[3,4])
Plots.plot(vector_of_plots[3,5])
Plots.plot(vector_of_plots[3,6])
Plots.plot(vector_of_plots[3,7])
Plots.plot(vector_of_plots[3,8])
Plots.plot(vector_of_plots[3,9])

# Plots.plot()
println("Figure 2: part E done.")