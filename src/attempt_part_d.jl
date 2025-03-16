using DataFrames, CSV, Statistics

# Load the data
# Note: Julia uses CSV.read() instead of Stata's "use" command
df = CSV.read("/Users/paulogcd/Documents/Replication_DevEcon/data/0_data_cleaning/2_cleaned/covar_pop_count.dta", DataFrame)
df = covar_pop_count = DataFrame(ReadStatTables.readstat("0_input/cleaned_data/covar_pop_count.dta"))
# Rename columns
rename!(df, :loggdppc => :lgdppc, :tmean => :Tmean)

# Create income and temperature groups
# Note: Make sure yc1, yc2, tc1, tc2 are defined in your Julia code before this point

yc1
yc2
tc1
tc2

df.ytile = fill(missing, nrow(df))
df.ttile = fill(missing, nrow(df))

df.ytile = ifelse.(df.lgdppc .<= yc1, 1, 
                   ifelse.(df.lgdppc .> yc1 .&& df.lgdppc .<= yc2, 2, 
                           ifelse.(df.lgdppc .> yc2, 3, missing)))

df.ttile = ifelse.(df.Tmean .<= tc1, 1, 
                  ifelse.(df.Tmean .> tc1 .&& df.Tmean .<= tc2, 2, 
                          ifelse.(df.Tmean .> tc2, 3, missing)))

# Calculate population shares
df.popshare2 = 1 .- df.popshare1 .- df.popshare3
df.pop1 = df.popshare1 .* df.pop
df.pop2 = df.popshare2 .* df.pop
df.pop3 = df.popshare3 .* df.pop

# Filter out negative popshare2
df = df[df.popshare2 .>= 0, :]

# Collapse (aggregate) by ytile, ttile, year
gdf = groupby(df, [:ytile, :ttile, :year])
collapsed = combine(gdf, [:pop, :pop1, :pop2, :pop3] .=> sum .=> [:pop, :pop1, :pop2, :pop3])

# Calculate totals by year
gdf_year = groupby(collapsed, :year)
transform!(gdf_year, :pop => sum => :pop_tot)
transform!(gdf_year, :pop1 => sum => :pop1_tot)
transform!(gdf_year, :pop2 => sum => :pop2_tot)
transform!(gdf_year, :pop3 => sum => :pop3_tot)

# Calculate percentages
collapsed.pop_per = (collapsed.pop ./ collapsed.pop_tot) .* 100
collapsed.pop1_per = (collapsed.pop1 ./ collapsed.pop1_tot) .* 100
collapsed.pop2_per = (collapsed.pop2 ./ collapsed.pop2_tot) .* 100
collapsed.pop3_per = (collapsed.pop3 ./ collapsed.pop3_tot) .* 100

# Sort the DataFrame
sort!(collapsed, [:year, :ytile, :ttile])

# Define the population share variables
# Note: This part requires manual conversion since Julia doesn't use local macros 
# like Stata. You'll need to extract these values into variables or a dictionary

# Example of how to extract the values (this replaces the local macro approach)
function extract_population_shares(df)
    shares = Dict()
    for age in 1:3
        for y in 1:3
            for t in 1:3
                # Find row for 2010
                idx_2010 = findfirst((df.year .== 2010) .& (df.ytile .== y) .& (df.ttile .== t))
                if !isnothing(idx_2010)
                    shares["a$(age)_Y$(y)T$(t)_g_2010"] = round(df[idx_2010, Symbol("pop$(age)_per")], digits=2)
                end
                
                # Find row for 2100
                idx_2100 = findfirst((df.year .== 2100) .& (df.ytile .== y) .& (df.ttile .== t))
                if !isnothing(idx_2100)
                    shares["a$(age)_Y$(y)T$(t)_g_2100"] = round(df[idx_2100, Symbol("pop$(age)_per")], digits=2)
                end
            end
        end
    end
    
    # Total age shares
    for y in 1:3
        for t in 1:3
            idx_2010 = findfirst((df.year .== 2010) .& (df.ytile .== y) .& (df.ttile .== t))
            if !isnothing(idx_2010)
                shares["a_Y$(y)T$(t)_g_2010"] = round(df[idx_2010, :pop_per], digits=2)
            end
            
            idx_2100 = findfirst((df.year .== 2100) .& (df.ytile .== y) .& (df.ttile .== t))
            if !isnothing(idx_2100)
                shares["a_Y$(y)T$(t)_g_2100"] = round(df[idx_2100, :pop_per], digits=2)
            end
        end
    end
    
    return shares
end

population_shares = extract_population_shares(collapsed)

names_part_D_results = ["ytile", "ttile",	"loggdppc_adm1_avg",	"lr_tavg_GMFD_adm1_avg",	"max_lr_tavg_GMFD_adm1_avg", "max_loggdppc_adm1_avg"]

part_D_result = ["ytile"	"ttile"	"loggdppc_adm1_avg"	"lr_tavg_GMFD_adm1_avg"	"max_lr_tavg_GMFD_adm1_avg"	"max_loggdppc_adm1_avg"
1	3	8.962444	22.9691	22.9691	9.024742
1	1	8.827487	7.957425	9.160113	9.024742
1	2	9.024742	13.51241	13.51241	9.024742
2	2	9.995737	13.37068	13.51241	9.995737
2	3	9.902338	19.6678	22.9691	9.995737
2	1	9.950479	9.160113	9.160113	9.995737
3	3	10.2809	18.52221	22.9691	10.33297
3	2	10.32087	12.88194	13.51241	10.33297
3	1	10.33297	8.609725	9.160113	10.33297
]

part_D_result = DataFrame(part_D_result, :auto)

part_D_result = convert(DataFrame, part_D_result)

DataFrame(part_D_result,names_part_D_results)