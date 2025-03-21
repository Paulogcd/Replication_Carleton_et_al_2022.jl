# Replication_Carleton_et_al_2022

[![Build Status](https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl/actions/workflows/CI.yml?query=branch%3Amain)

This repository is dedicated to the replication in Julia of the article Carleton et al, 2022: Valuing the Global Mortality Consequences of Climate Change Accounting for Adaptation Costs and Benefits (doi: [https://doi.org/10.1093/qje/qjac020](https://doi.org/10.1093/qje/qjac020)).

You can go to the dedicated webpage of the replication package [here](https://www.paulogcd.com/Replication_Carleton_et_al_2022.jl/) to have a better overview of the package. Due to large files required for the computation, another server was used (not GitHub pages) to host the required files. The package includes functions downloading required files from this other server, [which you can check here](https://www.paulogcd.fr/replications/replication_carleton_et_al_2022/).

# Starting the package :

This section explains how to use the package.

## Installation: 

This package requires Julia (version 1.11.4 was used) to run. 
Once you are located in a chosen directory, you can launch Julia on your Terminal by entering:

```
julia
```

Then, once Julia has started, we are going to need the `Pkg` module to load the current replication package. We are going to create a local environment, and add to this environment the current replication package. Finally, we are going to load it.

```
# Load the Pkg package:
using Pkg                                   
# Activate an environment at the current directory:
Pkg.activate(".")                           
# Download the current replication package:
Pkg.add(url = "https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl")         
# Load the replication package:
using Replication_Carleton_et_al_2022 
```

Now, the package is loaded in your local environment. You can test that it is loaded by using the `test()` function: 

```
# To test the loading of the package:
Replication_Carleton_et_al_2022.test()
```

This function should print a message indicating that the package is well-loaded.

## Required files:

To maintain the portability of the package, we did not include the large files required to perform the computations directly in it.

This is why we need to download these files via the `load()` function. It will first create two main folders, '0_input' and '0_output', and will then download the files in their corresponding subfolders.

Caution: make sure that you have 5.3 Gigabytes of space available for the package.

```
# To download the required files:
Replication_Carleton_et_al_2022.load()
```

## Replication results:

Once the required files are downloaded, we can generate the replication results, with the `run()` function:

```
# To generate the replication results:
Replication_Carleton_et_al_2022.run()
```

This function will perform the replication computations and will store the results in the '0_output' folder. The replication results corredspond to:

- Table 1: Descriptive statistics of the initial dataset the authors use.
- Figure 1: Plots of function describing the mortality-temperature relationship, based on the theoretical framework of the authors.
- Figure 2: A heatmap showing the predicted mortality effect.

For a more detailed discussion on the replication results, please refer to the website of the package.

## Tests

Several tests are included in the replication package.
They evaluate all functions loading the required files, and creating the replication output.

The results of the tests should be displayed on top of the GitHub repository.

[![Build Status](https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Paulogcd/Replication_Carleton_et_al_2022.jl/actions/workflows/CI.yml?query=branch%3Amain)


However, you can run locally the tests of the package. 
Caution: these tests heavily rely on a file transfer, and it is advised to have a good internet connection to run them.

You can run them locally by entering, in the environment in which you added the replication package:

```
Pkg.test("Replication_Carleton_et_al_2022")
```

For a more detailed discussion on the replication package tests, please refer to the website of the package.

# About

We are [Paulo Gugelmo Cavalheiro Dias](https://www.paulogcd.com) and [Lionel Chambon](https://lionelchambon.github.io), and produced this replication package for the Development Economics class, taught by [Clément Imbert](https://sites.google.com/site/clemimbert/) at Sciences Po in the summer 2025 semester.

For more information on our replication attempt, [visit the package website](https://www.paulogcd.com/Replication_Carleton_et_al_2022.jl).
