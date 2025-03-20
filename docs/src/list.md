# Technical documentation

This page hosts the technical documentation of the Replication\_Carleton\_et\_al\_2022.jl package.

## Installation

The installation of the package relies on the built-in `Pkg` package, by specifying the url of its [GitHub repository](https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl).

```
using Pkg
Pkg.activate(".")
Pkg.add(url = "https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl")
using Replication_Carleton_et_al_2022 
```

## Main functions

The package contains two main functions: 

- The `load()` function, that ensures that all files required for the data analysis are in your folder
- The `run()` function, that generates all the results we managed to replicate in the an output folder

```
# Ensures that an adequate folder structure is generated, and download the required files in those folders
Replication_Carleton_et_al_2022.load()

# Generate the exhibits we managed to replicate from the original article
Replication_Carleton_et_al_2022.run()
```

## Undocumented list of functions
```@index 
```

## Documented list of functions
```@autodocs
Modules = [Replication_Carleton_et_al_2022]
```