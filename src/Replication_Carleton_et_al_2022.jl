module Replication_Carleton_et_al_2022

    """
    The function `test` is a test to check that the `Replication_Carleton_et_al_2022` module is well loaded.
    """
    function test()
        print("The Replication_Carleton_et_al_2022.jl package is well loaded.")
    end
    export test

    include("1_table_1.jl")

    # Write your package code here.

    function run()
        create_table_1()
        # create_figure_1()
    end
    export run

end