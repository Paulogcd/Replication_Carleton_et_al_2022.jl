# pwd()

# @info string("Test performed from ", pwd())

@testset "load_files.jl" begin

    # This set of tests is dedicated to the tests of the load/delete functions. 

    # Test of 0_input_data_1.jl

    # Test the load of the global mortality panel covariates:
    Replication_Carleton_et_al_2022.load_global_mortality_panel_covariates()#pwd=string("../"))pwd=string("../"))
    path = joinpath(pwd(),"0_input/final_data/global_mortality_panel_covariates.dta")
    @test isfile(path)

    # Test the delete function of the same file:
    Replication_Carleton_et_al_2022.delete_global_mortality_panel_covariates()#pwd=string("../"))
    @test !isfile(path)

    # Test the load of the global mortality panel covariates:
    Replication_Carleton_et_al_2022.load_global_mortality_panel_public()#pwd=string("../"))
    path = joinpath(pwd(),"0_input/final_data/global_mortality_panel_public.dta")
    @test isfile(path)

    # Test the delete function of the same file: 
    Replication_Carleton_et_al_2022.delete_global_mortality_panel_public()#pwd=string("../"))
    @test !isfile(path)

    # Test of 0_input_data_2.jl
    Replication_Carleton_et_al_2022.load_Figure_1_estimates()#pwd=string("../"))
    path = joinpath(pwd(),"0_input/ster/estimates.csv")
    @test isfile(path)

    # Test the delete function of the same file:
    Replication_Carleton_et_al_2022.delete_Figure_1_estimates()#pwd=string("../"))pwd=string("../"))
    @test !isfile(path)

    # Test the load_covar_pop_count() function:
    Replication_Carleton_et_al_2022.load_covar_pop_count()#pwd=string("../"))pwd=string("../"))
    path = joinpath(pwd(),"0_input/cleaned_data/covar_pop_count.dta")
    @test isfile(path)

    Replication_Carleton_et_al_2022.delete_covar_pop_count()#pwd=string("../"))pwd=string("../"))
    @test !isfile(path)

    Replication_Carleton_et_al_2022.load()#pwd=string("../"))
    joinpath(pwd(),"0_input/final_data/global_mortality_panel_covariates.dta")
    @test isfile(path)
    joinpath(pwd(),"0_input/final_data/global_mortality_panel_public.dta")
    @test isfile(path)
    joinpath(pwd(),"0_input/ster/estimates.csv")
    @test isfile(path)
    joinpath(pwd(),"0_input/cleaned_data/covar_pop_count.dta")
    @test isfile(path)

    # We set the variable to nothing
    path = nothing

end