push!(LOAD_PATH,"../src/")

using Documenter
using Replication_Carleton_et_al_2022

makedocs(
    sitename = "Replication_Carleton_et_al_2022",
    format = Documenter.HTML(),
    modules = [Replication_Carleton_et_al_2022]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl"
)
