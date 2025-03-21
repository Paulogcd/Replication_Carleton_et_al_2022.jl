# Still to be tested. 

# This file is dedicated to the replication of the second figure of the article. 

# Loading required packages: 
using CSV, DataFrames, Plots, StatsBase, ColorSchemes

# Function to create a heatmap
function plot_heatmap(data, year)

    num_bins = (30, 30)  # Number of bins in each dimension

    histogram_data = fit(Histogram, (data.climtas, data.loggdppc), nbins=num_bins)

    # Extract bin counts and bin edges
    counts = histogram_data.weights
    xedges = histogram_data.edges[1]
    yedges = histogram_data.edges[2]

    # Convert edges to centers for plotting
    xcenters = xedges[1:end-1] .+ diff(xedges) ./ 2
    ycenters = yedges[1:end-1] .+ diff(yedges) ./ 2

    # Color gradient (white to blue)
    blue_gradient = cgrad([:white, :blue])

    # Generate heatmap
    heatmap(xcenters, ycenters, counts',
        xlabel="Annual Average Temperature (°C)", 
        ylabel="log(GDP per capita)",  
        title="Regions Grouped by Temperature and GDP in $year",
        colorbar=true,
        c=blue_gradient)
end


"""
The function "create_figure_2()" generates our attempt of replication of the figure 2 in the "output()" folder. 
It creates two png files, respectively "Figure_2_2015" and "Figure_2_2100".

Running a `@time` evaluation on this function, a MacBook Pro M4 (16Gb of RAM) obtains: 
    `13.516709 seconds (83.77 M allocations: 5.982 GiB, 20.97% gc time)`
"""
function create_figure_2(;pwd::AbstractString=pwd())

    # To handle the file, we first have to load it and delete its first 14 lines.
    # The "(...)_filtered" file is obtained by doing so.

    file = "0_input/main_specifications/mortality-allpreds_filtered.csv"
    # !!! Warning !!! : This file weights 3 Gb.
    df = CSV.read(joinpath(pwd,file), DataFrame, header=true)
    # However, the df file that is produced only takes 1.6 Gb...
    # summary(df)

    df_2015 = filter(:year => ==(2015), df)
    df_2100 = filter(:year => ==(2100), df)

    # varinfo()

    # # Plot heatmaps for 2015 and 2100
    full_2015 = plot_heatmap(df_2015, 2015)
    full_2100 = plot_heatmap(df_2100, 2100) 

    @info string("Creating Figure 2 subfigures...")
    savefig(full_2015, joinpath(pwd,"0_output/Figure_2_2015.png"))
    savefig(full_2100, joinpath(pwd,"0_output/Figure_2_2100.png"))
    @info string("Subfigures of figure 2 successfully created!")

end

# @time create_figure_2()

@info ("Compilation of create_figure_2(): Done")