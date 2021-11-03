module OutlierDetectionData
    include("utils.jl")
    include("ARFF/ARFF.jl")
    include("ODDS/ODDS.jl")
    include("ELKI/ELKI.jl")

    # Extend list with prefix search
    ELKI.list(prefix::Union{Regex, AbstractString}) = with_prefix(ELKI.list(), prefix)
    ODDS.list(prefix::Union{Regex, AbstractString}) = with_prefix(ODDS.list(), prefix)

    """    list([prefix])
    List the available datasets in a dataset collection optionally given a prefix.

    Parameters
    ----------
        prefix::Union{Regex, AbstractString}
    Regex or string used to filter the datasets.    
    """
    function list end

    """    load(dataset)
    Load a given dataset from a dataset collection.

    Parameters
    ----------
        name::AbstractString
    Name of the dataset to load.
    """
    function load end

    export ODDS, ELKI, ARFF, list, load
end
