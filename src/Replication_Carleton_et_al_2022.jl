module Replication_Carleton_et_al_2022

    """
    The function `test` is a test to check that the `Replication_Carleton_et_al_2022` module is well loaded.
    """
    function test()
        print("The Replication_Carleton_et_al_2022.jl package is well loaded.")
    end
    export test

    # File with function ensuring that the data is available:
    include("0_input_data.jl")

    # File for the table 1:
    include("1_table_1.jl")

    # Files for the figure 1:
    include("2_figure_1_a_c.jl")
    include("2_figure_1_d.jl")
    include("2_figure_1_e.jl")

    function run()
        Replication_Carleton_et_al_2022.create_table_1()
        # create_figure_1()
    end
    export run

end