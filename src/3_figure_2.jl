using CSV, DataFrames, Plots, StatsBase, ColorSchemes


"""
The function "create_figure_2()" generates our attempt of replication of the figure 2 in the "output()" folder. 
It creates two png files, respectively "Figure_2_2015" and "Figure_2_2100".

Running a `@time` evaluation on this function, a MacBook Pro M4 (16Gb of RAM) obtains: 
    `13.516709 seconds (83.77 M allocations: 5.982 GiB, 20.97% gc time)`
"""
function create_figure_2()
    # Load dataset. We provide the filtered dataset after we remove irrelevant metadata directly, so that everything can be read into Julia well.

    # df = CSV.read("/files/main_specification/main_specification/raw/single/rcp85/CCSM4/low/SSP3/mortality-allpreds_filtered.csv", DataFrame)
    df = CSV.read("0_input/main_specifications/mortality-allpreds_filtered.csv", DataFrame)
    # Define in-sample countries. This list is based on the original replication material.

    insample = [
        "BRA", "CHL", "CHN", "FRA", "IND", "JPN", "MEX", "USA",
        "AUT", "BEL", "BGR", "CHE", "CYP", "CZE", "DEU", "GBR",
        "DNK", "EST", "GRC", "ESP", "FIN", "FRA", "HRV", "HUN",
        "IRL", "ISL", "ITA", "LIE", "LTU", "LUX", "LVA", "MNE",
        "MKD", "MLT", "NLD", "NOR", "POL", "PRT", "ROU", "SWE",
        "SVN", "SVK", "TUR"
    ]

    # Subset data for 2015 and 2100
    df_2015 = filter(:year => ==(2015), df)
    df_2100 = filter(:year => ==(2100), df)

    # Subset in-sample regions
    df_2015_in = filter(:region => x -> x[1:3] in insample, df_2015)
    df_2100_in = filter(:region => x -> x[1:3] in insample, df_2100)

    # Define number of bins. This can be modified accordingly, we choose 30 for purposes of readability.

    bins = (30, 30)

    full_2015 = plot_heatmap(df_2015, 2015, bins)
    savefig(full_2015, "0_output/heatmap_full_2015.png")

    full_2100 = plot_heatmap(df_2100, 2100, bins)
    savefig(full_2100, "0_output/heatmap_full_2100.png")

    ins_2015 = plot_heatmap(df_2015_in, 2015, bins)
    savefig(ins_2015, "0_output/heatmap_ins_2015.png")

    ins_2100 = plot_heatmap(df_2100_in, 2100, bins)
    savefig(ins_2100, "0_output/heatmap_ins_2100.png")

    println("All heatmaps created and saved successfully.")
end

# Function to create the heatmaps
function plot_heatmap(data, year, num_bins)
    histogram_data = fit(Histogram, (data.climtas, data.loggdppc), nbins=num_bins)

    # Extract bin counts and bin edges

    counts = histogram_data.weights
    xedges = histogram_data.edges[1]
    yedges = histogram_data.edges[2]

    # Convert edges to centers for plotting

    xcenters = xedges[1:end-1] .+ diff(xedges) ./ 2
    ycenters = yedges[1:end-1] .+ diff(yedges) ./ 2

    # Color gradient (white to blue) we chose to our liking, can be modified to taste.

    blue_gradient = cgrad([:white, :blue])

    # Generate heatmap

    heatmap(xcenters, ycenters, counts',
        xlabel="Annual Average Temperature (°C)", 
        ylabel="log(GDP per capita)",  
        title="Regions Grouped by Temperature and GDP in $year",
        colorbar=true,
        c=blue_gradient)
end

# create_figure_2()
