using DataDeps

function with_env(f, variable::AbstractString, override::Bool)
    value = override ? override : get(ENV, variable, false)
    withenv(f, variable => string(value))
end

function with_accept(f, override::Bool = true)
    with_env(f, "DATADEPS_ALWAYS_ACCEPT", override)
end

function with_prefix(ls::AbstractVector{<:AbstractString}, prefix::Regex)
    ls[startswith.(ls, prefix)]
end
