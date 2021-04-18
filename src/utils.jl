using DataDeps

function with_env(f, variable::AbstractString, override::Bool)
    value = override ? override : get(ENV, variable, false)
    withenv(f, variable => string(value))
end

function with_accept(f, override::Bool = true)
    with_env(f, "DATADEPS_ALWAYS_ACCEPT", override)
end

function make_download(names)
    function download(name::String; dir::Union{Nothing, String} = nothing, force_accept::Bool = false)
        @assert name in names
    
        with_accept(force_accept) do
            if isnothing(dir)
                @datadep_str name
            else
                DataDeps.download(DataDeps.registry[name], path)
            end
        end
    end
    download
end

function make_remove(names)
    function remove(name::String)
        @assert name in names
        DataDeps.rm(@datadep_str name; recursive=true)
    end
    remove
end
