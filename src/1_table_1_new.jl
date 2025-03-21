function create_table_1(;pwd::AbstractString=pwd())
    # cd(dirname(pathof(Replication_Monge_et_al_2019)))
    # cd("..")
    write("table_1.jmd", """
    ---
    title: "Table 1"
    author: CHAMBON L., GUGELMO CAVALHEIRO DIAS P.
    ---
    
    This file presents the table 1 obtained from our replication attempt.

    We changed the display of the dataframe for readability reasons.

    ```{julia;echo=false}
    using Replication_Carleton_et_al_2022
    using DataFrames
    ```

    ```{julia;echo=false}
    df = Replication_Carleton_et_al_2022.pre_create_table_1()
    new_names = ["countries", "population size", "spatial scale", "years", "age categories",
        "mortality rate for all age categories", "mortality rate for more than 64 yr individuals", 
        "global population share"]
    rename!(df, new_names)
    nothing
    ```

    ```{julia; echo = false}
    df[!,1:3]
    ```

    ```{julia; echo = false}
    df[!,4:6]
    ```

    ```{julia; echo = false}
    df[!,7:end]
    ```

    """)

    weave("table_1.jmd"; doctype = "md2pdf")

    # rm("header.tex")
    rm("table_1.aux")
    rm("table_1.jmd")
    # rm("table_1.log")
    # rm("table_1.out")
    rm("table_1.tex")
end

# new_create_table_1()
