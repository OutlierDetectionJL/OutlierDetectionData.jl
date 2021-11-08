module TSAD
    using ..OutlierDetectionData: ARFF
    using OutlierDetection: CLASS_NORMAL, CLASS_OUTLIER, to_categorical
    using DataFrames: DataFrame, Not, select, convert, disallowmissing!, rename!
    using DataDeps
    using DataFrames

    export list, load

    include("datasets.jl")

    const TSAD_DATASETS = [
        (
            name = "univariate",
            md5 = "0eb0d3d5fd107ea0e92e1a76d25a662e73de93e6c6bcdfc0ef693246f10401f4",
            url = "http://www.timeseriesclassification.com/Downloads/Archives/Univariate2018_arff.zip",
        ),
        (
            name = "multivariate",
            md5 =  "37508dd78a3683ec7aaf26e787f4f5890cd20872539a0c4cb28bcfacc7a02536",
            url =  "http://www.timeseriesclassification.com/Downloads/Archives/Multivariate2018_arff.zip",
        )
    ]

    list() = vcat(TSAD_UNIVARIATE, TSAD_MULTIVARIATE)
    to_name(dataset::AbstractString) = "tsad-$dataset"
    dataset_not_found(dataset) = ArgumentError("$dataset was not found in the available datasets.")
    check_dataset(dataset) = dataset in list() || throw(dataset_not_found(dataset))

    # some datasets use the '"' character in the comments, which leads to CSV parsing errors
    univariate_read(dataset) = last(splitdir(dataset)) in ["Coffee_TRAIN.arff",
                                                           "Coffee_TEST.arff",
                                                           "OliveOil_TRAIN.arff",
                                                           "OliveOil_TEST.arff"] ?
                               ARFF.read(dataset, quotechar=UInt8(''')) |> DataFrame :
                               ARFF.read(dataset) |> DataFrame

    function load(dataset::AbstractString, anomaly_class)
        dep_path = to_dep(dataset)
        path_train = joinpath(dep_path, dataset, "$(dataset)_TRAIN.arff")
        path_test = joinpath(dep_path, dataset, "$(dataset)_TEST.arff")

        # load training and test data and combine
        data_train, data_test = univariate_read(path_train), univariate_read(path_test)
        data_train[!, :is_train] .= true
        data_test[!, :is_train] .= false
        data = vcat(data_train, data_test)

        # check if anomaly class is in the targets
        unique_targets = sort(unique(data.target))
        @assert anomaly_class in unique_targets "The anomaly class $anomaly_class was not found in "*
                                                "the targets $unique_targets."

        # prepare data ready to return
        labels = to_categorical(ifelse.(data.target .== anomaly_class, CLASS_OUTLIER, CLASS_NORMAL))
        X, y = select(data, Not([:target])), labels
        return X, y
    end

    function load(dataset::AbstractString)
        check_dataset(dataset)
        load(dataset, TSAD_UNIVARIATE_DEFAULTS[dataset])
    end

    function to_dep(dataset::AbstractString)
        if dataset in TSAD_UNIVARIATE
            dep = @datadep_str to_name("univariate")
            return "$dep/Univariate_arff"
        elseif dataset in TSAD_MULTIVARIATE
            dep = @datadep_str to_name("multivariate")
            return "$dep/Multivariate_arff"
        else
            throw(dataset_not_found(dataset))
        end
    end

    function __init__()
        for (name, md5, url) in TSAD_DATASETS
            register(DataDep(
                to_name(name),
                """Dataset: $name
                Collection: The UCR Time Series Archive
                Authors: Dau et al.
                Website: https://www.timeseriesclassification.com""",
                url,
                md5,
                post_fetch_method = unpack
            ))
        end
    end
end
