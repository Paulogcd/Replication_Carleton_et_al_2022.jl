# pwd()

# @info string("Test performed from ", pwd())

@testset "load_files.jl" begin

    # This set of tests is dedicated to the tests of the load/delete functions. 

    pre_path = pwd()

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

    Replication_Carleton_et_al_2022.delete_covar_pop_count(pwd=pre_path)#pwd=pre_path)pwd=pre_path)
    @test !isfile(path)

    Replication_Carleton_et_al_2022.load(pwd=pre_path)#pwd=pre_path)
    path = joinpath(pre_path,"0_input/final_data/global_mortality_panel_covariates.dta")
    @test isfile(path)
    path = joinpath(pre_path,"0_input/final_data/global_mortality_panel_public.dta")
    @test isfile(path)
    path = joinpath(pre_path,"0_input/ster/estimates.csv")
    @test isfile(path)
    path = joinpath(pre_path,"0_input/cleaned_data/covar_pop_count.dta")
    @test isfile(path)

    Replication_Carleton_et_al_2022.delete_folder_setup()
    path = joinpath(pre_path,"0_input")
    @test !isfile(path)
    path = joinpath(pre_path,"0_output")
    @test !isfile(path)

    # We set the variable to nothing
    path = pre_path = nothing

end