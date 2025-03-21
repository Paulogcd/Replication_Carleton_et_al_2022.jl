@testset "Figure 2" begin
    
    # For the create_figure_2() function to work, as all other functions included in the 'run' function, 
    # it first requires that the right folder structure exists:
    Replication_Carleton_et_al_2022.create_folder_setup()

    # Then, it requires that the right file be available
    # for the data treatment: 
    Replication_Carleton_et_al_2022.load_mortality_allpreds_filtered()

    # We then launch the create_figure_2() function, that 
    # generates 3 png files in the 0_output folder.
    Replication_Carleton_et_al_2022.create_figure_2()
    # Finally, we check for their existence:
    @test isfile(joinpath(pwd(),"0_output/Figure_2_2015.png"))
    @test isfile(joinpath(pwd(),"0_output/Figure_2_2100.png"))

end