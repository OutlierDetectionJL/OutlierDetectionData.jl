module OutlierDetectionData
    include("utils.jl")
    include("ODDS/ODDS.jl")
    include("ELKI/ELKI.jl")

    export ODDS, ELKI, with_env, with_accept
end
