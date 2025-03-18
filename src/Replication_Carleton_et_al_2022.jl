module Replication_Carleton_et_al_2022

    """
    The function `test` is a test to check that the `Replication_Carleton_et_al_2022` module is well loaded.
    """
    function test()
        print("The Replication_Carleton_et_al_2022.jl package is well loaded.")
    end
    export test

    # File with function ensuring that the data is available:
    include("0_load.jl")

    # File for the table 1:
    include("1_table_1.jl")

    # Files for the figure 1:
    # include("2_figure_1_a_c.jl")
    # include("2_figure_1_d.jl")
    # include("2_figure_1_e.jl")
    include("2_figure_1_final.jl")

    function run()
        
        @info string("Creating table 1...")
        # Table 1 generated in "0_output/table_1.pdf" file
        create_table_1()

        @info string("Creating figure 1...")
        # Figure 1 generated in "0_output/Figure_1_(...).png" files
        create_figure_1()
    end
    export run

end