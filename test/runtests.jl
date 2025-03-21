using Replication_Carleton_et_al_2022
using Test

# print("Initialising tests.")
@testset "Replication_Carleton_et_al_2022.jl" begin
    
    # Test of the loading of the required files.    
    # include("0_tests_load.jl") # All tests pass.
    
    # Test of the function that creates table 1.
    include("1_tests_table_1.jl") # All tests pass.

    # Test of the function that creates figure 1.
    include("2_tests_figure_1.jl") # All tests pass.

    # Test of the function that creates figure 2.
    # include("2_tests_figure_2.jl") # NOT TESTED YET.
end
@info string("Tests done.")
