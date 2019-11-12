module GeoFormatTypes

# Use the README as the module docs
@doc let 
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export WellKnownText, WellKnownBinary, ProjString, 
       EPSGcode, GML, KML, GeoJSON, GeoJSONdict

const PROJ_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"

"""
Proj string
"""
struct ProjString
    val::String
    ProjString(input::String) = begin
        startswith(input, PROJ_PREFIX) || 
            throw(ArgumentError("String $input does not start with $PROJ_PREFIX"))
        new(input)
    end
end

val(x::ProjString) = x.val

Base.show(io::IO, x::ProjString) = print(io, "Proj:\n$(val(x))")

struct NetCDF_CRS
    val::Dict{String,Any}
end

"""
Well known text
"""
struct WellKnownText
    val::String
end

val(x::WellKnownText) = x.val

Base.show(io::IO, x::WellKnownText) = print(io, "Well Known Text:\n$(val(x))")

"""
Well known binary
"""
struct WellKnownBinary
    val::String
end

val(x::WellKnownBinary) = x.val

Base.show(io::IO, x::WellKnownBinary) = print(io, "Well Known Binary")

"""
EPSG code
"""
struct EPSGcode
    val::Int
end
"""
Constructor for EPSG:1234 style strings
"""
EPSGcode(input::AbstractString) = begin
    startswith(input, EPSG_PREFIX) || throw(ArgumentError("String $input does no start with $EPSG_PREFIX"))
    code = parse(Int, input[findlast(EPSG_PREFIX, input).stop+1:end])
    EPSGcode(code)
end

val(x::EPSGcode) = x.val

Base.show(io::IO, x::EPSGcode) = print(io, "EPSGcode: $EPSG_PREFIX$(val(x))")

"""
ESRI code
"""
struct ESRI
    val::String
end

val(x::ESRI) = x.val

Base.show(io::IO, x::ESRI) = print(io, "ESRI: $(val(x))")

"""
Keyhole Markup Language
"""
struct KML
    val::String
end

val(x::KML) = x.val

Base.show(io::IO, x::KML) = print(io, "KML:\n$(val(x))")

"""
Geography MarkupLanguage
"""
struct GML
    val::String
end

val(x::GML) = x.val

Base.show(io::IO, x::GML) = print(io, "GML:\n$(val(x))")

"""
GeoJSON 
"""
struct GeoJSON
    val::String
end

val(x::GeoJSON) = x.val

Base.show(io::IO, x::GeoJSON) = print(io, "GeoJSON:\n$(repr(val(x)))")

"""
GeoJSON 
"""
struct GeoJSONdict{String,V} <: AbstractDict{String,V}
    val::Dict{String,V}
end

val(x::GeoJSONdict) = x.val

Base.show(io::IO, x::GeoJSONdict) = print(io, "GeoJSON Dict:\n$(val(x))")

getindex(collection::GeoJSONdict, key) = getindex(val(collection), key)
setindex!(collection::GeoJSONdict, x, key) = setindex!(val(collection), x, key)
get(collection::GeoJSONdict, key, default) = get(val(collection), key, default)
get(f::Base.Callable, collection::GeoJSONdict, key) = get(f, val(collection), key)
get!(f::Base.Callable, collection::GeoJSONdict, key) = get!(f, val(collection), key)
keys(collection::GeoJSONdict) = keys(val(collection))
values(collection::GeoJSONdict) = values(val(collection))
getkey(collection::GeoJSONdict, key, default) = getkey(val(collection), key, default)
delete!(collection::GeoJSONdict, key) = delete!(val(collection), key)
pop!(collection::GeoJSONdict, key, args...) = pop!(collection, key, args...)

end # module
