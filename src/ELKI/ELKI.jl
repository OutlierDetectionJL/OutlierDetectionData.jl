module ELKI
    using DataFrames: DataFrame, Not, select, convert, disallowmissing!, rename!
    using DataDeps

    export list, load

    include("ARFF.jl")
    include("datasets.jl")
    ELKI_DATASETS = vcat(ELKI_SEMANTIC, ELKI_LITERATURE)

    const _meta = [
        (
            name = "semantic",
            md5 = "e77ad3d37baeb1e4025497496e2183d3d00c6ea2d1e603b2d388894b490fa71a",
            url = "https://www.dbs.ifi.lmu.de/research/outlier-evaluation/input/semantic.tar.gz",
        ),
        (
            name = "literature",
            md5 =  "42a69b719f846bc03e4a6a0e5776969d4cd6b61a17675035c27753e7a6e0e256",
            url =  "https://www.dbs.ifi.lmu.de/research/outlier-evaluation/input/literature.tar.gz",
        )
    ]

    list() = ELKI_DATASETS
    to_name(dataset::AbstractString) = "elki-$dataset"

    function load(dataset::AbstractString)
        dep = to_dep(dataset)
        folder = match(r"^(\w+?)([_|\.]|$)", dataset, 1).captures[1]
        data = ARFF.read("$dep/$folder/$dataset.arff") |> DataFrame
        # lowercase all columns because some datasets use :Outlier instead of :outlier
        rename!(data, lowercase.(names(data)))
        X, y = select(data, Not([:outlier, :id])), ifelse.(data.outlier .== "no", 1, -1)
        return X, y
    end

    function to_dep(dataset_name::AbstractString)
        if dataset_name in ELKI_LITERATURE
            dep = @datadep_str to_name("literature")
            return "$dep/literature"
        elseif dataset_name in ELKI_SEMANTIC
            dep = @datadep_str to_name("semantic")
            return "$dep/semantic"
        else
            throw(ArgumentError("$dataset_name was not found in the available datasets"))
        end
    end

    function __init__()
        for (name, md5, url) in _meta
            register(DataDep(
                to_name(name),
                """Dataset: $name
                Collection: On the Evaluation of Unsupervised Outlier Detection
                Authors: Campos et al.
                Website: https://www.dbs.ifi.lmu.de/research/outlier-evaluation/DAMI/""",
                url,
                md5,
                post_fetch_method = unpack
            ))
        end
    end
end
