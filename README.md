# OutlierDetectionData

[![Documentation (stable)](https://img.shields.io/badge/docs-stable-blue.svg)](https://OutlierDetectionJL.github.io/OutlierDetection.jl/stable)
[![Documentation (dev)](https://img.shields.io/badge/docs-dev-blue.svg)](https://OutlierDetectionJL.github.io/OutlierDetection.jl/dev)
[![Build Status](https://github.com/OutlierDetectionJL/OutlierDetectionData.jl/workflows/CI/badge.svg)](https://github.com/OutlierDetectionJL/OutlierDetectionData.jl/actions)
[![Coverage](https://codecov.io/gh/OutlierDetectionJL/OutlierDetectionData.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/OutlierDetectionJL/OutlierDetectionData.jl)

*OutlierDetectionData.jl* is a package to download and read common outlier detection datasets. This package is a part of [OutlierDetection.jl](https://github.com/OutlierDetectionJL/OutlierDetection.jl/), the outlier detection ecosystem for Julia.

**API Overview**

The API currently is simple; we provide a single namespace per dataset collection. A dataset collection such as `ODDS` bundles multiple outlier detection datasets. For each dataset collection, the following methods are provided:

List all available datasets in the collection:

```julia
list()
```

List a subset of datasets starting with `prefix`:

```julia
list(prefix::Union{AbstractString, Regex})
```

Load a single dataset with `name`. This command automatically starts to download the file if the file does not exist. Currently, the data is returned as a tuple containing `X::DataFrame` and `y::Vector{Int}`, where `X` is a matrix of features with one observation per row and `y` represents the labels with `"normal"` indicating inliers and `"outlier"` indicating outliers.

```julia
load(name::AbstractString)
```

**Example:**

The following example shows how you can load the `"cardio"` dataset from the ODDS collection.

```julia
using OutlierDetectionData: ODDS

X, y = ODDS.load("cardio")
```

**Available Collections:**

The available collections are:

- [ODDS](http://odds.cs.stonybrook.edu/), Outlier Detection DataSets, Shebuti Rayana, 2016
- [ELKI](https://www.dbs.ifi.lmu.de/research/outlier-evaluation/DAMI/), On the Evaluation of Unsupervised Outlier Detection, Campos et al., 2016
- [TSAD](https://timeseriesclassification.com/), The UCR Time Series Archive, Dau et al., 2018

For the TSAD collection, the class with the least members is chosen as the anomaly class and all other classes are defined as normal. If there are multiple classes, the lexically first class is chosen.

**Licenses**

Please make sure that you check and accept the licenses of the individual datasets before publishing your work. This package is licensed under the terms of the MIT license.
