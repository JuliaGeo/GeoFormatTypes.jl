module GeoFormatTypes

# Use the README as the module docs
@doc let 
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export WellKnownText, WellKnownBinary, Proj4String, 
       EPSGcode, GML, KML, GeoJSON, GeoJSONdict

const PROJ_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"

val(x::SpatialType) = x.val

"""
Proj4 string
"""
struct Proj4String
    val::String
end
Proj4String(input::AbstractString) = begin
    startswith(input, PROJ_PREFIX) || 
        throw(ArgumentError("String $input does not start with $PROJ_PREFIX"))
    Proj4String(input)
end

Base.show(io::IO, crs::Proj4String) = print(io, "Proj4:\n$(val(x))")

"""
Well known text
"""
struct WellKnownText
    val::String
end

Base.show(io::IO, x::WellKnownText) = print(io, "Well Known Text:\n$(val(x))")

"""
Well known binary
"""
struct WellKnownBinary
    val::String
end

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
    startswith(input, EPSG_PREFIX) || throw(ArgumentError("String $epsg_string does no start with $EPSG_PREFIX"))
    code = parse(Int, input[findlast(EPSG_PREFIX, input).stop+1:end])
    EPSGcode(code)
end

Base.show(io::IO, x::EPSGcode) = print(io, "EPSGcode: $EPSG_PREFIX$(val(x))")

"""
Keyhole Markup Language
"""
struct KML
    val::String
end

Base.show(io::IO, x::KML) = print(io, "KML:\n$(val(x))")

"""
Geography MarkupLanguage
"""
struct GML
    val::String
end

Base.show(io::IO, x::GML) = print(io, "GML:\n$(val(x))")

"""
GeoJSON 
"""
struct GeoJSON
    val::String
end

Base.show(io::IO, x::GeoJSON) = print(io, "GeoJSON:\n$(repr(val(x)))")

"""
GeoJSON 
"""
struct GeoJSONdict <: AbstractDict
    val::Dict{String,Any}
end

Base.show(io::IO, x::GeoJSONdict) = print(io, "GeoJSON Dict:\n$(repr(val(x)))")

values(iterator::GeoJSONdict) = values(val(iterator))
get(collection::GeoJSONdict, key, default)
get(f::Base.Callable, collection::GeoJSONdict, key)
get!(f::Base.Callable, collection::GeoJSONdict, key) = get!(f, val(collection), key)
values(d::GeoJSONdict) = values(val(collection))
getkey(collection::GeoJSONdict, key, default) =  getkey(val(collection), key, default)
delete!(collection::GeoJSONdict, key) =  delete!(val(collection), key)
pop!(collection::GeoJSONdict, key[, default]) = pop!(collection, key[, default])

end # module
