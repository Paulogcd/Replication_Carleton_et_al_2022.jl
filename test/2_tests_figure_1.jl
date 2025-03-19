@testset "2_tests_figure_1.jl" begin

    Replication_Carleton_et_al_2022.create_figure_1()
    @test isfile("0_output/figure_1_1.png")
    @test isfile("0_output/figure_1_2.png")
    @test isfile("0_output/figure_1_3.png")

end