# Technical documentation

This page hosts the technical documentation of the Replication\_Carleton\_et\_al\_2022.jl package.


## Installation

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

## Required files

To maintain the portability of the package, we did not include the large files required to perform the computations directly in it.

This is why we need to download these files via the `load()` function. It will first create two main folders, `0_input` and `0_output`, and will then download the files in their corresponding subfolders.

Caution: make sure that you have 5.3 Gigabytes of space available for the package.

```
# To download the required files:
Replication_Carleton_et_al_2022.load()
```

## Replication results

Once the required files are downloaded, we can generate the replication results, with the `run()` function:

```
# To generate the replication results:
Replication_Carleton_et_al_2022.run()
```

This function will perform the replication computations and will store the results in the '0_output' folder. The replication results corredspond to:

- Table 1: Descriptive statistics of the initial dataset the authors use.
- Figure 1: Plots of function describing the mortality-temperature relationship, based on the theoretical framework of the authors.
- Figure 2: A heatmap showing the predicted mortality effect.

## Delete required files

Due to the large size of the package files, we also included a function to manage their deletion.
If you wish to keep your directory, but without the `0_input` and `0_output` folders, you can delete them via the following function:

```
Replication_Carleton_et_al_2022.delete_folder_setup()
```

Be careful. This is irreversible.

## Undocumented list of functions of the package

```@index 
```

## Documented list of functions of the package

```@autodocs
Modules = [Replication_Carleton_et_al_2022]
```