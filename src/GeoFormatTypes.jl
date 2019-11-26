module GeoFormatTypes

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export GeoFormat

export CoordinateReferenceSystemFormat, EPSG, ProjString 

export GeometryFormat, GeoJSON, KML

export MixedFormat, GML 

export AbstractWellKnownText, WellKnownText, WellKnownText2, ESRIWellKnownText, WellKnownBinary

const PROJ_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"
# TODO more verification that types are wrapping the right format.



"""
    val(f::GeoFormat)

Get the contained value of a GeoFormat type.
"""
function val end

"""
Abstract supertype for geospatial data formats
"""
abstract type GeoFormat end

"""
Formats representing coordinate reference systems
"""
abstract type CoordinateReferenceSystemFormat <: GeoFormat end

"""
Formats representing geometries. These wrappers simply mark string
formats that may optionally be converted to Geoetry objects at a later point.
"""
abstract type GeometryFormat <: GeoFormat end

"""
Formats that may hold either or both coordinate reference systems and geometries.
"""
abstract type MixedFormat <: GeoFormat end

val(x::GeoFormat) = x.val

# Most GeoFormat types wrap String or have a constructor for string inputs
Base.convert(::Type{String}, input::GeoFormat) = val(input)
Base.convert(::Type{T}, input::AbstractString) where T <: GeoFormat = T(input)

"""
Proj string
"""
struct ProjString <: CoordinateReferenceSystemFormat
    val::String
    ProjString(input::String) = begin
        startswith(input, PROJ_PREFIX) ||
            throw(ArgumentError("String $input does not start with $PROJ_PREFIX"))
        new(input)
    end
end

"""
Well known text has a number of versions and standards, and can 
represent coordinate reference systems or geometric data.
"""
abstract type AbstractWellKnownText <: MixedFormat end

"""
Well known text v1 following the OGC standard
"""
struct WellKnownText <: AbstractWellKnownText
    val::String
end

"""
Well known text v2 following the new OGC standard
"""
struct WellKnownText2 <: AbstractWellKnownText
    val::String
end

"""
Well known text following the ESRI standard
"""
struct ESRIWellKnownText <: AbstractWellKnownText
    val::String
end

"""
Well known binary
"""
struct WellKnownBinary{T} <: AbstractWellKnownText
    val::T
end

Base.convert(::Type{String}, input::WellKnownBinary) = error("`convert` is not defined for `WellKnownBinary`")


"""
EPSG code representing a coordinate reference system from the 
EPSG spatial reference system registry.
"""
struct EPSG <: CoordinateReferenceSystemFormat
    val::Int
end

"""
Constructor for "EPSG:1234" string input
"""
EPSG(input::AbstractString) = begin
    startswith(input, EPSG_PREFIX) || throw(ArgumentError("String $input does no start with $EPSG_PREFIX"))
    code = parse(Int, input[findlast(EPSG_PREFIX, input).stop+1:end])
    EPSG(code)
end

Base.convert(::Type{Int}, input::EPSG) = val(input)
Base.convert(::Type{String}, input::EPSG) = string(EPSG_PREFIX, val(input))
Base.convert(::Type{EPSG}, input::Int) = EPSG(input)

"""
Keyhole Markup Language
"""
struct KML <: GeometryFormat
    val::String
end

"""
Geography Markup Language
"""
struct GML <: MixedFormat
    val::String
end

"""
GeoJSON String or Dict
"""
struct GeoJSON{T} <: GeometryFormat
    val::T
end

end # module
