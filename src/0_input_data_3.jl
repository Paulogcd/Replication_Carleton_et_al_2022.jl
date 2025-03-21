"""
The function `load_final_data_covariates` ensures that the file "global_mortality_panel_covariates" is in your input folder.
Since the data weights 3 Gigabytes, be sure to have a good internet connection.
"""
function load_mortality_allpreds_filtered(;pwd::AbstractString=pwd())
    localpath = "0_input/main_specifications/mortality-allpreds_filtered.csv"
    path = joinpath(pwd,localpath)
    if isfile(path)
        @info string("File ", path, " is already in your system.")
    elseif !isfile(path) # Check and only activates if you do not have the file in your computer:
        @info string("File ", path, " not found. Proceeding to download.")
        url = string("https://www.paulogcd.fr/replications/replication_carleton_et_al_2022/resources/", localpath) 
        @info string("Dowloading from: ", url)
        @warn string("The file weights 2 Gigabytes, and its downloading can take some time.")
        res = HTTP.get(url)
        body = res.body
        CSV.write(path, CSV.read(body,  DataFrame), header=true)
        # a = CSV.read(path, DataFrame)
        # write(path, tmp)
        sleep(1) # Waiting to avoid HTTP requests problem.

        # Setting values to nothing and collecting garbage to reduce memory usage.
        url = res = tmp = nothing
        GC.gc()
        @info string("File ", path, " successfully downloaded.")
    end
    if isfile(path)
        @info string("File available at: ", path)
    end
end

# load_mortality_allpreds_filtered

"""
The function `delete_mortality_allpreds_filtered` deletes the file "global_mortality_panel_covariates.csv" from your folder.
"""
function delete_mortality_allpreds_filtered(;pwd::AbstractString=pwd())
    localpath = "0_input/main_specifications/mortality-allpreds_filtered.csv"
    path = joinpath(pwd,localpath)
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