# Tests

This page is dedicated to the presentation of the tests of the package.

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

They should yield something similar to: 

![Tests status](tests.png)