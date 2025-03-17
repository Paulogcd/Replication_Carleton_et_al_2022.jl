# This file is dedicated to the replication of the part D of the file creating the figure 1 of the article. 
# This is the equivalent of: 
# carleton_mortality_2022/1_estimation/3_regressions/3_age_spec_interacted/Figure_I_array_plots.do


# ### STATA:
# ### PART D. Construct Pop Figures
# ### use "`DATA'/2_cleaned/covar_pop_count.dta", clear
# ### rename (loggdppc tmean) (lgdppc Tmean)
# 

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
results_1_2010
results_1_2100

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
i = 1

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

println("Figure 2: Part D done.")