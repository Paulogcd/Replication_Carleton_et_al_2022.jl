@testset "Table 1" begin

    # For the create_table_1() function to work, as all other functions included in the 'run' function, 
    # it first requires that the right folder structure exists:
    Replication_Carleton_et_al_2022.create_folder_setup()

    # Then, it requires that the right file be available
    # for the data treatment: 
    Replication_Carleton_et_al_2022.load_global_mortality_panel_public()

    # The create_table_1() function generates the pdf of the table 1 in the 0_output folder.
    Replication_Carleton_et_al_2022.create_table_1()
    # We test the existence of this file:
    @test isfile("0_output/table_1.html")
    
end
# print("Tests of table 1 done.")