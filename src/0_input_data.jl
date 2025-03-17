# This file is dedicated to the functions ensuring that the input data 
# of the package is available in the folder of the user.

using HTTP

"""
The function `loading_Figure_1_estimates` ensures that the file "estimates.csv" is in your input folder. 
It is necessary for the replication of the Figure 1 of the article.
"""
function load_Figure_1_estimates()
    if isfile("0_input/estimates.csv")
        @info "File 'estimates.csv' is already in your system."
    elseif !isfile("0_input/estimates.csv") # Check and only activates if you do not have the file in your computer:
        @info ("File 'estimates.csv' not found. Proceeding to download.")
        @info "Dowloading from" estimates_csv_url = "https://docs.google.com/spreadsheets/d/1N1sdiNWikmy6ortqiHJ2UuAXcqZEOAymKv8mxVRqxwA/export?format=csv"
        res = HTTP.get(estimates_csv_url)
        body = res.body
        CSV.write("0_input/estimates.csv", CSV.read(body,  DataFrame, header=false))
        sleep(1) # Waiting to avoid HTTP requests problem.
        @info "File 'estimates.csv' successfully downloaded."
    end
    if isfile("0_input/estimates.csv")
        @info "File available at: 0_input/estimates.csv"
    end
end

# loading_Figure_1_estimates()

"""
The function `delete_Figure_1_estimates` deletes the file "estimates.csv" from your folder.
"""
function delete_Figure_1_estimates()
    if isfile("0_input/ster/estimates.csv")
        @info "File 'estimates.csv' found in your system. Proceeding to its deletion."
        rm("0_input/estimates.csv")
        if !isfile("0_input/estimates.csv")
            @info ("File 'estimates.csv' deleted.")
        end
    elseif !isfile("0_input/estimates.csv")
        @info "File 'estimates.csv' not found in your system. It cannot be deleted."
    end
end

# delete_Figure_1_estimates()

"""
# This function is still under progress!!!
The function `load_final_data_covariates` ensures that the file "global_mortality_panel_covariates" is in your input folder.
Since the data weights 2 Gigabytes, be sure to have a good internet connection.
"""
function load_final_data_covariates()
    path = "0_input/final_data/global_mortality_panel_covariates.dta"
    if isfile(path)
        @info string("File ", path, " is already in your system.")
    elseif !isfile(path) # Check and only activates if you do not have the file in your computer:
        @info string("File ", path, " not found. Proceeding to download.")
        url = "https://drive.usercontent.google.com/download?id=1MjvPVcYGqLUhMtywtZCgQekXbXPeCSjr&export=download&confirm=t"
        @info string("Dowloading from: ", url)
        @warn string("The file weights 2 Gigabytes, and its downloading can take some time.")
        
        # Add question for the user, to be sure that they want to proceed.
        # readline(stdin)
        a = readline()
        res = HTTP.get(url)
        body = res.body
        # DO NOT RUN WHILE TESTING
        # I am not sure about this one. This is not a CSV file, but a dta one.
        # CSV.write(path, CSV.read(body,  DataFrame, header=false)) # it would overwrite the rigt data.
        # DO NOT RUN WHILE TESTING
        sleep(1) # Waiting to avoid HTTP requests problem.
        
        # Setting values to nothing and collecting garbage for efficient memory allocation.
        url = res = body = nothing
        GC.gc()
        @info string("File ", path, " successfully downloaded.")
    end
    if isfile(path)
        @info string("File available at: ", path)
    end
end

# load_final_data_covariates()

"""
The function `delete_final_data_covariates` deletes the file "global_mortality_panel_covariates.dta" from your folder.
"""
function delete_final_data_covariates()
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

# Working function to ask for permission.
# """
# """
# function confirmation()
#     println("Enter 'y' to confirm, any other key to refuse.\n")
#     answer = readline()
#     # if answer == "y"
#     #     println("You confirmed, process continuing.")
#     #     return true
#     #     # break
#     # else 
#     #     print("You refuse, process stopping.")
#     #     return false
#     #     # break
#     # end
#     return answer
# end
# 
# confirmation()

# function test()
#     println("Enter 'y' to win, any other key to loose.\n")
#     answer = readline()
#     if answer == "y"
#         println("you win")
#     else 
#         println("you loose")
#     end
# end

# test()

println("Ensuring input data: done.")