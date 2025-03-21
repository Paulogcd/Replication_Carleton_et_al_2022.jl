@testset "Figure 1" begin

    # For the create_figure_1() function to work, as all other functions included in the 'run' function, 
    # it first requires that the right folder structure exists:
    Replication_Carleton_et_al_2022.create_folder_setup()

    # Then, it requires that the right file be available
    # for the data treatment: 
    Replication_Carleton_et_al_2022.load_covar_pop_count()
    Replication_Carleton_et_al_2022.load_coefficients()
    Replication_Carleton_et_al_2022.load_global_mortality_panel_covariates()

    # We then launch the create_figure_1() function, that 
    # generates 3 png files in the 0_output folder.
    Replication_Carleton_et_al_2022.create_figure_1()
    # Finally, we check for their existence:
    @test isfile(joinpath(pwd(),"0_output/Figure_1_1.png"))
    @test isfile(joinpath(pwd(),"0_output/Figure_1_2.png"))
    @test isfile(joinpath(pwd(),"0_output/Figure_1_3.png"))

end