module OutlierDetectionData
    include("utils.jl")
    include("ODDS/ODDS.jl")
    include("ELKI/ELKI.jl")

    # Extend list with prefix search
    ELKI.list(prefix::Union{Regex, AbstractString}) = with_prefix(ELKI.list(), prefix)
    ODDS.list(prefix::Union{Regex, AbstractString}) = with_prefix(ODDS.list(), prefix)

    export ODDS, ELKI, with_env, with_accept
end
