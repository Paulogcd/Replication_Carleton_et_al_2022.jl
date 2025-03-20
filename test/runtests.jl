using Replication_Carleton_et_al_2022
using Test

# print("Initialising tests.")
@testset "Replication_Carleton_et_al_2022.jl" begin
    
    # Write your tests here.
    @test 1==1
    
    # include("0_tests_load.jl") # All tests pass.
    
    include("1_tests_table_1.jl")

    # include("2_tests_figure_1.jl")

end
print("Tests done.")
