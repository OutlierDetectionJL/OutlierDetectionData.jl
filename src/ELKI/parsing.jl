# Header parsing logic, as in https://github.com/cjdoris/ARFFFiles.jl

const _SPACE = UInt8(' ')
const _AT = UInt8('@')
const _COMMENT = UInt8('%')
const _DQUO = UInt8('"')
const _SQUO = UInt8('\'')
const _SEP = UInt8(',')
const _MISSING = UInt8('?')
const _ESC = UInt8('\\')
const _NOMSTART = UInt8('{')
const _NOMEND = UInt8('}')
const _ILLEGAL_RAWCHAR = (_SPACE, _AT, _COMMENT, _DQUO, _SQUO, _SEP, _MISSING, _ESC, _NOMSTART, _NOMEND)
const _A = (UInt8('a'), UInt8('A'))
const _B = (UInt8('b'), UInt8('B'))
const _C = (UInt8('c'), UInt8('C'))
const _D = (UInt8('d'), UInt8('D'))
const _E = (UInt8('e'), UInt8('E'))
const _G = (UInt8('g'), UInt8('G'))
const _I = (UInt8('i'), UInt8('I'))
const _L = (UInt8('l'), UInt8('L'))
const _M = (UInt8('m'), UInt8('M'))
const _N = (UInt8('n'), UInt8('N'))
const _O = (UInt8('o'), UInt8('O'))
const _R = (UInt8('r'), UInt8('R'))
const _S = (UInt8('s'), UInt8('S'))
const _T = (UInt8('t'), UInt8('T'))
const _U = (UInt8('u'), UInt8('U'))

mutable struct State
    src :: String
    pos :: Int
    lineno :: Int
end

Base.length(s::State) = sizeof(s.src)
Base.@propagate_inbounds Base.getindex(s::State, i::Int) = codeunit(s.src, i)
@inline hasmore(s::State) = s.pos ≤ length(s)
@inline inc!(s::State) = (s.pos += 1; nothing)
@inline curbyte(s::State) = s[s.pos]
@inline maybeskip!(s::State, c::UInt8) = @inbounds (hasmore(s) && curbyte(s) == c ? (inc!(s); true) : false)
@inline maybeskip!(s::State, cs::Tuple{Vararg{UInt8}}) = @inbounds (hasmore(s) && curbyte(s) in cs ? (inc!(s); true) : false)
@inline skip!(s::State, c::UInt8) = @inbounds (hasmore(s) && curbyte(s) == c ? (inc!(s); nothing) : _error_expecting(s, c))
@inline skip!(s::State, cs::Tuple{Vararg{UInt8}}) = @inbounds (hasmore(s) && curbyte(s) in cs ? (inc!(s); nothing) : _error_expecting(s, cs))
@inline skip!(s::State, c, cs...) = (skip!(s, c); skip!(s, cs...))

@noinline _error_expecting(s::State, c::UInt8) = _error(s, "expecting $(repr(Char(c)))")
@noinline _error_expecting(s::State, cs::Tuple{Vararg{UInt8}}) = _error(s, "expecting one of $(join(map(repr∘Char, cs), " "))")
@noinline _error_expecting(s::State, what::String) = _error(s, "expecting $what")
@noinline _error(s::State, msg) = error("line $(s.lineno):$(s.pos): parsing error: $msg")

skipspace!(s::State) =
    @inbounds while maybeskip!(s, _SPACE); end

skipcomment!(s::State) =
    @inbounds if maybeskip!(s, _COMMENT); s.pos = length(s)+1; end

function parse_type(s::State)
    if maybeskip!(s, _N)
        skip!(s, _U, _M, _E, _R, _I, _C)
        return ARFFNumericType()
    elseif maybeskip!(s, _R)
        skip!(s, _E, _A, _L)
        return ARFFNumericType()
    elseif maybeskip!(s, _I)
        skip!(s, _N, _T, _E, _G, _E, _R)
        return ARFFNumericType()
    elseif maybeskip!(s, _S)
        skip!(s, _T, _R, _I, _N, _G)
        return ARFFStringType()
    elseif maybeskip!(s, _D)
        skip!(s, _A, _T, _E)
        skipspace!(s)
        if hasmore(s) && (curbyte(s) in (_SQUO, _DQUO) || curbyte(s) ∉ _ILLEGAL_RAWCHAR)
            fmt = parse_string(s)
            return ARFFDateType(fmt)
        else
            return ARFFDateType()
        end
    elseif maybeskip!(s, _NOMSTART)
        skipspace!(s)
        xs = String[]
        while true
            x = parse_string(s)
            push!(xs, x)
            skipspace!(s)
            if maybeskip!(s, _SEP)
                skipspace!(s)
            elseif maybeskip!(s, _NOMEND)
                break
            else
                _error_expecting(s, (_SEP, _NOMEND))
            end
        end
        return ARFFNominalType(xs)
    else
        _error_expecting(s, "a type")
    end
end

function parse_string(s::State)
    io = IOBuffer()
    if maybeskip!(s, _DQUO)
        @inbounds while hasmore(s)
            c = curbyte(s)
            if c == _DQUO
                inc!(s)
                break
            elseif c == _ESC
                error("escape sequences not supported yet")
            else
                inc!(s)
                write(io, c)
            end
        end
    elseif maybeskip!(s, _SQUO)
        @inbounds while hasmore(s)
            c = curbyte(s)
            if c == _SQUO
                inc!(s)
                break
            elseif c == _ESC
                error("escapes sequences not supported yet")
            else
                inc!(s)
                write(io, c)
            end
        end
    else
        @inbounds while hasmore(s)
            c = curbyte(s)
            if c in _ILLEGAL_RAWCHAR
                break
            else
                write(io, c)
                inc!(s)
            end
        end
        io.size > 0 || _error_expecting(s, "a string")
    end
    String(take!(io))
end

function parse_header_line(s::State)
    skipspace!(s)
    r = nothing
    if maybeskip!(s, _AT)
        if maybeskip!(s, _D)
            skip!(s, _A, _T, _A)
            r = ARFFData()
        elseif maybeskip!(s, _A)
            skip!(s, _T, _T, _R, _I, _B, _U, _T, _E)
            skipspace!(s)
            name = parse_string(s)
            skipspace!(s)
            tp = parse_type(s)
            r = ARFFAttribute(name, tp)
        elseif maybeskip!(s, _R)
            skip!(s, _E, _L, _A, _T, _I, _O, _N)
            skipspace!(s)
            name = parse_string(s)
            r = ARFFRelation(name)
        else
            _error(s, "invalid attribute")
        end
        skipspace!(s)
    end
    skipcomment!(s)
    hasmore(s) && _error_expecting(s, r===nothing ? "command or end of string" : "end of string")
    return r
end

function parse_datum(s::State)
    if maybeskip!(s, _MISSING)
        return missing
    else
        parse_string(s)
    end
end

function parse_data_line(s::State)
    skipspace!(s)
    xs = Union{String, Missing}[]
    while true
        x = parse_datum(s)
        push!(xs, x)
        skipspace!(s)
        if maybeskip!(s, _SEP)
            skipspace!(s)
        else
            break
        end
    end
    skipcomment!(s)
    hasmore(s) && _error_expecting(s, "end of string")
    return xs
end

"""
parse_header(io::IO)
Parse the ARFF header from `io`, stopping after `@data` is seen.
Returns the [`ARFFHeader`](@ref) and the number of lines read.
"""
function parse_header(io::IO)
    relation = missing
    attributes = ARFFAttribute[]
    lineno = 0
    while !eof(io)
        lineno += 1
        h = parse_header_line(State(readline(io), 1, lineno))
        if h === nothing
            # blank line
        elseif h isa ARFFRelation
            relation === missing || error("line $lineno: @relation seen twice")
            relation = h.name
        elseif h isa ARFFAttribute
            relation === missing && error("line $lineno: @relation required before @attribute")
            push!(attributes, h)
        elseif h isa ARFFData
            relation === missing && error("line $lineno: @relation required before @data")
            return ARFFHeader(relation, attributes), lineno
        else
            error()
        end
    end
    return error("reached end of file before seeing @data")
end
