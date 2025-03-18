# This file is part of the set of files defining functions to ensure that 
# the data required is in the folder of the user.

# It loads the file responsible for the construction of the Table 1.

using HTTP

"""
# This function did not get tested!!!
The function `load_final_data_covariates` ensures that the file "global_mortality_panel_covariates" is in your input folder.
Since the data weights 2 Gigabytes, be sure to have a good internet connection.
"""
function load_global_mortality_panel_covariates()
    path = "0_input/final_data/global_mortality_panel_covariates.dta"
    if isfile(path)
        @info string("File ", path, " is already in your system.")
    elseif !isfile(path) # Check and only activates if you do not have the file in your computer:
        @info string("File ", path, " not found. Proceeding to download.")
        url = "https://drive.usercontent.google.com/download?id=1MjvPVcYGqLUhMtywtZCgQekXbXPeCSjr&export=download&confirm=t"
        @info string("Dowloading from: ", url)
        @warn string("The file weights 2 Gigabytes, and its downloading can take some time.")
        res = HTTP.get(url)
        res.body
        tmp = String(res.body)
        write(path, tmp)
        sleep(1) # Waiting to avoid HTTP requests problem.
        @info string("File ", path, " successfully downloaded.")
        
        # Setting values to nothing and collecting garbage to reduce memory usage.
        url = res = body = tmp = nothing
        GC.gc()
        @info string("File ", path, " successfully downloaded.")
    end
    if isfile(path)
        @info string("File available at: ", path)
    end
end

# load_global_mortality_panel_covariates()

"""
The function `delete_final_data_covariates` deletes the file "global_mortality_panel_covariates.dta" from your folder.
"""
function delete_global_mortality_panel_covariates()
    path = "0_input/final_data/global_mortality_panel_covariates.dta"
    if isfile(path)
        @info string("File ", path, " found in your system. Proceeding to its deletion.")
        rm(path) 
        if !isfile(path)
            @info string("File ", path," deleted.")
        end
    elseif !isfile(path)
        @info string("File ", path, " not found in your system. It cannot be deleted.")
    end
end

# delete_final_data_covariates

@info string("Compilation of 0_input_data_1: Done.")