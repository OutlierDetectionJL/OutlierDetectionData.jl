using DataDeps

function with_prefix(ls::AbstractVector{<:AbstractString}, prefix)
    ls[startswith.(ls, prefix)]
end
