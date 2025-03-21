# Replication attempt: How it went

This page is dedicated to the presentation of our replication attempt.

## The Original Replication Package

The replication files and corresponding documentation can be found [here](https://github.com/ClimateImpactLab/carleton_mortality_2022).
While the associated repository mirrors the structure of the paper, the main challenge is the computation of large-scale climate model projections using Monte Carlo simulations, which are impossible to reproduce in the absence of larger-scale cloud computing capacities.
The material does, however, provide a range of intermediate data, so that the replicator does not have to re-run these, which was also why we were hopeful to be able to reproduce some results.

## Main difficulties: Conda and large files

According to the documentation, the first step is to et up a Conda environment to run the codes provided by the authors, which are written in Stata, Python, and R.
To do so, the replicator is instructed to load the Conda environment associated with the paper. However, we encountered package dependency problems that impeded the environment from loading correctly.
Moreover, even when disregarding the Monte Carlo simulations themselves, loading the necessary data requires at least 85 GB of storage space, not to mention the required RAM needed to manipulate the data.
This exceeded the technical limits of one of our computers.
Therefore, we initially tried to load only most relevant parts of the package and data onto Nuvolos, hoping that this could resolve storage issues.
However, the files were still too large for us to access fully, as our cloud space is limited to 50 GB and is insufficient to decompress the .zip-files we needed.
Thus, we split the files across spaces and decided to try and work using the provided intermediate data straight away.

## Additional Manipulation on Intermediate Data

However, upon closer inspection of the files provided, we came across two problems. First, some files were of small or medium size when read into Stata, but much larger when read into Julia, our language of choice for the replication. This caused one of our computers to crash repeatedly. Second, other files are unusable outside of Stata, as extensions such as .ster or .csvv (sic!) cannot be imported cleanly into Julia. This meant that we attempted to manually repeat some steps of the data cleaning process using the raw data in bash, which diverted us from the actual replication process. The main problem here was that it was not at all obvious which files were used for which figure, as the code itself relied on running the environment and associated functions which we could not load. By trying to reconstruct different steps of the data manipulation process, we suspect that many of our codes we wrote did not run because we used the wrong inputs for the wrong purposes.