<h1 align="center">OutlierDetectionData.jl</h1>
<p align="center">
  <a href="https://discord.gg/F5MPPS9t4h">
    <img src="https://img.shields.io/badge/chat-on%20discord-7289da.svg?sanitize=true" alt="Chat">
  </a>
  <a href="https://davnn.github.io/OutlierDetectionData.jl/stable">
    <img src="https://img.shields.io/badge/docs-stable-blue.svg" alt="Documentation (stable)">
  </a>
  <a href="https://github.com/davnn/OutlierDetectionData.jl/actions">
    <img src="https://github.com/davnn/OutlierDetectionData.jl/workflows/CI/badge.svg" alt="Build Status">
  </a>
  <a href="https://codecov.io/gh/davnn/OutlierDetectionData.jl">
    <img src="https://codecov.io/gh/davnn/OutlierDetectionData.jl/branch/master/graph/badge.svg" alt="Coverage">
  </a>
</p>

*OutlierDetectionData.jl* is a package to download and read common outlier detection datasets. This package is a part of [OutlierDetection.jl](https://github.com/davnn/OutlierDetection.jl/), the outlier detection ecosystem for Julia.

**API Overview**

The API currently is simple; we provide a single namespace per dataset collection. A dataset collection such as `ODDS` bundles multiple outlier detection datasets. For each dataset collection, the following methods are provided:

List all available datasets in the collection:

```
list()
```

Load a single dataset with `name`. This command automatically starts to download the file if the file does not exist. Currently, the data is returned as a tuple containing `X::DataFrame` and `y::Vector{Int}`, where `X` is a matrix of features with one observation per row and `y` represents the labels with `1` indicating inliers and `-1` indicating outliers.

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

**Licenses**

Please make sure that you check and accept the licenses of the individual datasets before publishing your work. This package is licensed under the terms of the MIT license.
