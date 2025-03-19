# This file defines the function `load`, that ensures that all the required files 
# are in the directory of the user.

# The following files are responsible for the loading of different 
# data associated with dfferent parts of the article:

# Table 1:
include("0_input_data_1.jl")

# Figure 1:
include("0_input_data_2.jl")
# include("0_input_data_1.jl") # Alerady included.


"""
The function `load` ensures that all the required data is in the local folder of the user. 
It should be run before the `run` function of the package. 
"""
function load(;pwd::String=pwd())

    total = 5
    i = 1

    @info string("Beginning of the data and files loading.")
    
    @info string("Ensuring file 'global_mortality_panel_covariates.dta': ", i,"/", total)
    load_global_mortality_panel_covariates(pwd=pwd) 
    i += 1

    @info string("Ensuring file 'global_mortality_panel_public.dta': ", i,"/", total)
    load_global_mortality_panel_public(pwd=pwd)
    i += 1

    @info string("Ensuring file 'estimates.csv': ", i,"/", total)
    load_Figure_1_estimates(pwd=pwd)
    i += 1

    @info string("Ensuring file 'covar_pop_count.dta': ", i,"/", total)
    load_covar_pop_count(pwd=pwd)
    i += 1

    @info string("Ensuring file 'coefficients.csv': ", i,"/", total)
    load_coefficients(pwd=pwd)
    i += 1

    println()
    @info string("All required files are loaded.")

end

# load()

# We export this function:
export load

@info("Compilation of load(): Done.")