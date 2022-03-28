module ARFF

# Simply uses the CSV.jl parser for fast ARFF loading with the header parsing logic from ARFFFiles.jl
# Once there is a sufficiently fast ARFF library available in Julia, this module will become obsolete

# Doesn't support:
# - multi-instance attributes
# - weighted data
# - sparse data

using CSV
using Dates:DateTime

export ARFFType,
       ARFFNumericType,
       ARFFStringType,
       ARFFDateType,
       ARFFNominalType,
       ARFFRelation,
       ARFFAttribute,
       ARFFData,
       ARFFHeader,
       header,
       read

include("parsing.jl")

# The unique name of the relation in the corresponding file.
struct ARFFRelation
    name::String
end

# Abstract type of ARFF types
abstract type ARFFType end

struct ARFFNumericType <: ARFFType
    native::Type
end
ARFFNumericType() = ARFFNumericType(Float64)

struct ARFFStringType <: ARFFType
        native::Type
end
ARFFStringType() = ARFFStringType(String)

struct ARFFDateType <: ARFFType
    native::Type
    format::String
end
ARFFDateType() = ARFFDateType(DateTime, "yyyy-MM-dd'T'HH:mm:ss")

struct ARFFNominalType <: ARFFType
    native::Type
    classes::Vector{String}
end
ARFFNominalType(classes::Vector{String}) = ARFFNominalType(String, classes)

# Represents a single ARFF @attribute.
struct ARFFAttribute
    name::String
    type::ARFFType
end

# Indicates the start of the data rows (to be parsed as CSV).
struct ARFFData end

# Represents the header information in an ARFF file.
struct ARFFHeader
    relation::String
    attributes::Vector{ARFFAttribute}
end

function header(path)
    @debug "Reading header metadata"
    open(path, "r") do io
        return parse_header(io)
    end
end

function read(path; kwargs...)
    h, lineno = header(path)

    @debug "Reading data"
    colnames = map(a -> a.name, h.attributes)
    coltypes = map(a -> a.type.native, h.attributes)
    formats = [a.format for a in h.attributes if isa(a, ARFFDateType)]
    @assert all(y -> y==formats[1], formats) "Expected all date formats to be equal (see constraints in the README)"

    f = CSV.File(path;
        skipto=lineno+1,
        header=colnames,
        types=coltypes,
        missingstring="?",
        comment="%",
        dateformat=length(formats) > 0 ? formats[1] : nothing,
        kwargs...)
    return f
end

end
