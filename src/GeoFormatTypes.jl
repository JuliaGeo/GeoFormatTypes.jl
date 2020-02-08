module GeoFormatTypes

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export GeoFormat

export CoordinateReferenceSystemFormat, EPSG, ProjString, CoordSys

export GeometryFormat, GeoJSON, KML

export MixedFormat, GML

export AbstractWellKnownText, WellKnownText, WellKnownText2, ESRIWellKnownText, WellKnownBinary

const PROJ_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"
# TODO more verification that types are wrapping the right format.

# Traits for mixed crs/geometry formats.
abstract type FormatMode end
struct Geom <: FormatMode end
struct CRS <: FormatMode end
struct Mixed <: FormatMode end

"""
    val(f::GeoFormat)

Get the contained value of a GeoFormat type.
"""
function val end

"""
Abstract supertype for geospatial data formats
"""
abstract type GeoFormat end

# Convert from the same type does nothing.
Base.convert(::T, source::S) where {T<:GeoFormat,S<:T} = source
# Convert uses the `mode` trait to distinguish crs form geometry conversion
Base.convert(target::Type{<:GeoFormat}, input::GeoFormat) = begin
    inputmode = mode(input)
    targetmode = mode(target)
    convertmode = if inputmode isa Mixed
        if targetmode isa Mixed
            Geom() # Geom is the default if both formats are mixed
        else
            targetmode
        end
    elseif targetmode isa typeof(inputmode)
        inputmode
    else
        throw(ArgumentError("cannot convert $(typeof(input)) to $target"))
    end
    convert(target, convertmode, input)
end

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
abstract type MixedFormat{X} <: GeoFormat end

val(x::GeoFormat) = x.val

mode(format::GeoFormat) = mode(typeof(format))
mode(::Type{<:GeometryFormat}) = Geom()
mode(::Type{<:CoordinateReferenceSystemFormat}) = CRS()
mode(::Type{<:MixedFormat}) = Mixed()
mode(::Type{<:MixedFormat{M}}) where M = M()

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
Mapinfo CoordSys string
"""
struct CoordSys <: CoordinateReferenceSystemFormat
    val::String
end

"""
Well known text has a number of versions and standards, and can
represent coordinate reference systems or geometric data.
"""
abstract type AbstractWellKnownText{X} <: MixedFormat{X} end

"""
Well known text v1 following the OGC standard
"""
struct WellKnownText{X,T<:String} <: AbstractWellKnownText{X}
    mode::X
    val::T
end

"""
Well known text v2 following the new OGC standard
"""
struct WellKnownText2{X,T<:String} <: AbstractWellKnownText{X}
    mode::X
    val::T
end

"""
Well known text following the ESRI standard
"""
struct ESRIWellKnownText{X,T<:String} <: AbstractWellKnownText{X}
    mode::X
    val::T
end

"""
Well known binary
"""
struct WellKnownBinary{X,T} <: MixedFormat{X}
    mode::X
    val::T
end

Base.convert(::Type{String}, input::WellKnownBinary) =
    error("`convert` to `String` is not defined for `WellKnownBinary`")


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
struct GML{X,T<:String} <: MixedFormat{X}
    mode::X
    val::T
end

"""
GeoJSON String or Dict
"""
struct GeoJSON{T} <: GeometryFormat
    val::T
end

end # module