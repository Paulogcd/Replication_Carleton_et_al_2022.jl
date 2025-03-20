# This file is dedicated to the functions ensuring that the input data 
# of the package is available in the folder of the user.

using HTTP
using CSV
using DataFrames

"""
The function `loading_Figure_1_estimates` ensures that the file "estimates.csv" is in your input folder. 
It is necessary for the replication of the Figure 1 of the article.
"""
function load_Figure_1_estimates(;pwd::String=pwd())
    path = "0_input/ster/estimates.csv"
    path = string(pwd,"/",path)
    if isfile(path)
        @info string("File ", path ," is already in your system.")
    elseif !isfile(path) # Check and only activates if you do not have the file in your computer:
        @info string("File ", path, " not found. Proceeding to download.")
        url = "https://www.paulogcd.fr/replications/replication_carleton_et_al_2022/resources/0_input/ster/estimates.csv"
        @info string("Dowloading from ", url)
        res = HTTP.get(url)
        body = res.body
        CSV.write(path, CSV.read(body,  DataFrame, header=false))
        sleep(1) # Waiting to avoid HTTP requests problem.
        @info string("File ", path, " successfully downloaded.")
    end
    if isfile(path)
        @info string("File available at: ", path)
    end
end

# load_Figure_1_estimates()

"""
The function `delete_Figure_1_estimates` deletes the file "estimates.csv" from your folder.
"""
function delete_Figure_1_estimates(;pwd::String=pwd())
    path = "0_input/ster/estimates.csv"
    path = string(pwd,"/",path)
    if isfile(path)
        @info string("File ", path," found in your system. Proceeding to its deletion.")
        rm(path)
        if !isfile(path)
            @info string("File ", path," deleted.")
        end
    elseif !isfile(path)
        @info string("File ", path ," not found in your system. It cannot be deleted.")
    end
end

# delete_Figure_1_estimates()

"""
The function `load_covar_pop_count` ensures that the file "covar_pop_count.dta" is in your input folder. 
It is necessary for the replication of the Figure 1 of the article.
"""
function load_covar_pop_count(;pwd::String=pwd())
    path = "0_input/cleaned_data/covar_pop_count.dta"
    path = string(pwd,"/",path)
    if isfile(path)
        @info string("File ", path ," is already in your system.")
    elseif !isfile(path) # Check and only activates if you do not have the file in your computer:
        @info string("File ", path, " not found. Proceeding to download.")
        url = "https://www.paulogcd.fr/replications/replication_carleton_et_al_2022/resources/0_input/cleaned_data/covar_pop_count.dta"
        @info string("Dowloading from ", url)
        res = HTTP.get(url)
        tmp = String(res.body)
        write(path, tmp)
        sleep(1) # Waiting to avoid HTTP requests problem.
        @info string("File ", path, " successfully downloaded.")
    end
    if isfile(path)
        @info string("File available at: ", path)
    end
end

# load_covar_pop_count()

"""
The function `delete_covar_pop_count` deletes the file "covar_pop_count.dta" from your folder.
"""
function delete_covar_pop_count(;pwd::String=pwd())
    path = "0_input/cleaned_data/covar_pop_count.dta"
    path = string(pwd,"/",path)
    if isfile(path)
        @info string("File ", path," found in your system. Proceeding to its deletion.")
        rm(path)
        if !isfile(path)
            @info string("File ", path," deleted.")
        end
    elseif !isfile(path)
        @info string("File ", path ," not found in your system. It cannot be deleted.")
    end
end

# delete_covar_pop_count()

"""
The function `load_coefficients` ensures that the file "coefficients.csv" is in your input folder. 
It is necessary for the replication of the Figure 1 of the article.
"""
function load_coefficients(;pwd::String=pwd())
    path = "0_input/ster/coefficients.csv"
    path = string(pwd,"/",path)
    if isfile(path)
        @info string("File ", path ," is already in your system.")
    elseif !isfile(path) # Check and only activates if you do not have the file in your computer:
        @info string("File ", path, " not found. Proceeding to download.")
        url = "https://www.paulogcd.fr/replications/replication_carleton_et_al_2022/resources/0_input/ster/coefficients.csv"
        @info string("Dowloading from ", url)
        res = HTTP.get(url)
        body = res.body
        CSV.write(path, CSV.read(body,  DataFrame, header=false))
        sleep(1) # Waiting to avoid HTTP requests problem.
        @info string("File ", path, " successfully downloaded.")
    end
    if isfile(path)
        @info string("File available at: ", path)
    end
end

# load_coefficients()

"""
The function `delete_coefficients` deletes the file "coefficients.csv" from your folder.
"""
function delete_coefficients(;pwd::String=pwd())
    path = "0_input/ster/coefficients.csv"
    path = string(pwd,"/",path)
    if isfile(path)
        @info string("File ", path," found in your system. Proceeding to its deletion.")
        rm(path)
        if !isfile(path)
            @info string("File ", path," deleted.")
        end
    elseif !isfile(path)
        @info string("File ", path ," not found in your system. It cannot be deleted.")
    end
end

# delete_coefficients()

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

@info string("Compilation of 0_input_data_2: Done.")

# println("0_input_data_1.jl precompiled")