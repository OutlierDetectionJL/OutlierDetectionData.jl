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

The API currently is very simple, we provide a single namespace per dataset collection. A dataset collection such as `ODDS` bundles multiple outlier detection datasets. For each collection, the following is provided:

List all available datasets in the collection:

```
list()
```

Load a single dataset with `name`. This command automatically starts to download the file if the file does not exist. Currently the data is returned as a tuple containing `X::AbstractArray{Real}` and `y::AbstractVector{Int}`, where `X` is an array of features with one observation per row and `y` represents the labels with `1` indicating inliers and `-1` indicating outliers.

```julia
load(name::String)
```

**Example:**

The following example shows how you can download all datasets from the ODDS collection and load the `"cardio"` dataset.

```julia
using OutlierDetectionData: ODDS

X, y = ODDS.load("cardio")
```

**Licenses**

Please make sure that you check and accept the licenses of the individual datasets before publishing your work. This package is licensed under the terms of the MIT license.
