# This file is part of the tests of the Replication_Carleton_et_al_2022.jl package. 
# It tests the functions that are responsible for ensuring the availability of the files 
# required for the data analysis and the replication of the results.

@testset "Loading of the required files" begin

    # This set of tests is dedicated to the tests of the load/delete functions. 
    #
    # It is requires a good internet connection, due to the transfer of an important amount of data, 
    # since all the files may be downloaded several times.
    #
    # It first makes sure that the needed folder structure exists.
    # Then, it loads individually each file needed for the replication 
    # (check their existence and if not present, download them), and test the existence of the file.
    # Then, it deletes them individually, and checks for their absence. 
    # After that, it starts the load() function, which loads all the required files. 
    # It then tests the existence of all files, together. 
    # Finally, it deletes all the files and their associated folders.

    pre_path = pwd() # This is for better modulability in the tests, to be able to redirect to other directories if needed.

    Replication_Carleton_et_al_2022.create_folder_setup(pwd=pre_path)
    # Test of 0_input_data_1.jl

    # Test the load of the global mortality panel covariates:
    
    Replication_Carleton_et_al_2022.load_global_mortality_panel_covariates(pwd=pre_path)
    path = joinpath(pre_path,"0_input/final_data/global_mortality_panel_covariates.dta")
    @test isfile(path)

    # Test the delete function of the same file:
    Replication_Carleton_et_al_2022.delete_global_mortality_panel_covariates(pwd=pre_path)
    @test !isfile(path)

    # Test the load of the global mortality panel covariates:
    Replication_Carleton_et_al_2022.load_global_mortality_panel_public(pwd=pre_path)
    path = joinpath(pre_path,"0_input/final_data/global_mortality_panel_public.dta")
    @test isfile(path)

    # Test the delete function of the same file: 
    Replication_Carleton_et_al_2022.delete_global_mortality_panel_public(pwd=pre_path)
    @test !isfile(path)

    # Test of 0_input_data_2.jl
    Replication_Carleton_et_al_2022.load_Figure_1_estimates(pwd=pre_path)
    path = joinpath(pre_path,"0_input/ster/estimates.csv")
    @test isfile(path)

    # Test the delete function of the same file:
    Replication_Carleton_et_al_2022.delete_Figure_1_estimates(pwd=pre_path)#pwd=pre_path)pwd=pre_path)
    @test !isfile(path)

    # Test the load_covar_pop_count() function:
    Replication_Carleton_et_al_2022.load_covar_pop_count(pwd=pre_path)#pwd=pre_path)pwd=pre_path)
    path = joinpath(pre_path,"0_input/cleaned_data/covar_pop_count.dta")
    @test isfile(path)

    # Test the delete function of the same file:
    Replication_Carleton_et_al_2022.delete_covar_pop_count(pwd=pre_path)#pwd=pre_path)pwd=pre_path)
    @test !isfile(path)

    # Test of the load() function, that loads all the required files altogether:
    Replication_Carleton_et_al_2022.load(pwd=pre_path)#pwd=pre_path)
    path = joinpath(pre_path,"0_input/final_data/global_mortality_panel_covariates.dta")
    @test isfile(path)
    path = joinpath(pre_path,"0_input/final_data/global_mortality_panel_public.dta")
    @test isfile(path)
    path = joinpath(pre_path,"0_input/ster/estimates.csv")
    @test isfile(path)
    path = joinpath(pre_path,"0_input/cleaned_data/covar_pop_count.dta")
    @test isfile(path)

    # Test of the delete_folder_setup(), that deletes all the files, and their associated folder.
    Replication_Carleton_et_al_2022.delete_folder_setup()
    path = joinpath(pre_path,"0_input")
    @test !isfile(path)
    path = joinpath(pre_path,"0_output")
    @test !isfile(path)

    # We set the variable to nothing
    path = pre_path = nothing

end