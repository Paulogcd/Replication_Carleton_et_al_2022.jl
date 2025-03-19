# Still to be tested. 

# using CSV, DataFrames, Plots, StatsBase, ColorSchemes
# 
# df = CSV.read("/files/main_specification/main_specification/raw/single/rcp85/CCSM4/low/SSP3/mortality-allpreds_filtered.csv", DataFrame)
# 
# df_2015 = filter(:year => ==(2015), df)
# df_2100 = filter(:year => ==(2100), df)
# 
# num_bins = (30, 30)  # Number of bins in each dimension
# 
# # Function to create a heatmap
# function plot_heatmap(data, year)
#     histogram_data = fit(Histogram, (data.climtas, data.loggdppc), nbins=num_bins)
# 
#     # Extract bin counts and bin edges
#     counts = histogram_data.weights
#     xedges = histogram_data.edges[1]
#     yedges = histogram_data.edges[2]
# 
#     # Convert edges to centers for plotting
#     xcenters = xedges[1:end-1] .+ diff(xedges) ./ 2
#     ycenters = yedges[1:end-1] .+ diff(yedges) ./ 2
# 
#     # Color gradient (white to blue)
#     blue_gradient = cgrad([:white, :blue])
# 
#     # Generate heatmap
#     heatmap(xcenters, ycenters, counts',
#         xlabel="Annual Average Temperature (°C)", 
#         ylabel="log(GDP per capita)",  
#         title="Regions Grouped by Temperature and GDP in $year",
#         colorbar=true,
#         c=blue_gradient)
# end
# 
# # Plot heatmaps for 2015 and 2100
# full_2015 = plot_heatmap(df_2015, 2015)
# full_2100 = plot_heatmap(df_2100, 2100) 
# 
# savefig(full_2015, "heatmap_full_2015.png")
# savefig(full_2100, "heatmap_full_2100.png")
# 