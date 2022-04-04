module GeoFormatTypes

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export GeoFormat

export CoordinateReferenceSystemFormat, EPSG, ProjString, CoordSys, GML

export GeometryFormat, GeoJSON, KML

export MixedFormat, GML

export AbstractWellKnownText, WellKnownText, WellKnownText2, ESRIWellKnownText, WellKnownBinary

const PROJ_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"
# TODO more verification that types are wrapping the right format.

"""
    FormatMode

Traits to indicate the format type, such as `Geom`, `CRS` or `MixedFormat`.
"""
abstract type FormatMode end

"""
    Geom <: FormatMode

    Geom()
    
Trait specifying that a mixed format object, like [`WellKnownText`](@ref),
contains geometry data.
"""
struct Geom <: FormatMode end

"""
    CRS <: FormatMode

    CRS()
    
Trait specifying that a mixed format object, like [`WellKnownText`](@ref),
contains only coordinate reference system data.
"""
struct CRS <: FormatMode end

"""
   MixedFormatMode <: FormatMode
    
Abstract supertype for [`FormatMode`](@ref) where both
geometry and coordinate reference system data are or may be present.
"""
abstract type MixedFormatMode <: FormatMode end
"""
    Extended <: MixedFormatMode <: FormatMode

    Extended()
    
Trait specifying that a mixed format object, like [`WellKnownText`](@ref),
contains both geometry and coordinate reference system.
"""
struct Extended <: MixedFormatMode end

"""
    Unknown <: MixedFormatMode <: FormatMode

    Unknown()
    
Trait specifying that a mixed format object, like [`WellKnownText`](@ref),
contains either geometry or coordinate reference system data, or both.
"""
struct Unknown <: MixedFormatMode end

"""
    val(f::GeoFormat)

Get the contained value of a GeoFormat type.
"""
function val end

"""
    GeoFormat

Abstract supertype for geospatial data formats
"""
abstract type GeoFormat end

# Convert from the same type does nothing.
Base.convert(::Type{T1}, source::T2) where {T1<:GeoFormat,T2<:T1} = source
# Convert uses the `mode` trait to distinguish crs form geometry conversion
Base.convert(target::Type{T1}, source::T2; kwargs...) where {T1<:GeoFormat,T2<:GeoFormat} = begin
    sourcemode = mode(source)
    targetmode = mode(target)
    convertmode = if targetmode isa Geom
        if sourcemode isa Union{MixedFormatMode,Geom}
            Geom() # Geom is the default if both formats are mixed
        else
            throw(ArgumentError("cannot convert $(typeof(source)) to $target"))
        end
    elseif targetmode isa CRS
        if sourcemode isa Union{MixedFormatMode,CRS}
            CRS()
        else
            throw(ArgumentError("cannot convert $(typeof(source)) to $target"))
        end
    else # targetmode isa MixedFormatMode
        # MixedFormatMode to MixedFormatMode defaults to Geom
        if sourcemode isa Union{MixedFormatMode,Geom}
            Geom()
        else
            CRS()
        end
    end
    convert(target, convertmode, source; kwargs...)
end


"""
    CoordinateReferenceSystemFormat <: GeoFormat

Formats representing coordinate reference systems
"""
abstract type CoordinateReferenceSystemFormat <: GeoFormat end

"""
    GeometryFormat <: GeoFormat

Formats representing geometries. These wrappers simply mark string
formats that may optionally be converted to Geoetry objects at a later point.
"""
abstract type GeometryFormat <: GeoFormat end

"""
    MixedFormat <: GeoFormat

Formats that may hold either or both coordinate reference systems and geometries.
"""
abstract type MixedFormat{X} <: GeoFormat end

val(x::GeoFormat) = x.val

mode(format::GeoFormat) = mode(typeof(format))
mode(::Type{<:GeometryFormat}) = Geom()
mode(::Type{<:CoordinateReferenceSystemFormat}) = CRS()
mode(::Type{<:MixedFormat}) = Unknown()
mode(::Type{<:MixedFormat{M}}) where M = M()

# Most GeoFormat types wrap String or have a constructor for string inputs
Base.convert(::Type{String}, input::GeoFormat) = val(input)
Base.convert(::Type{T}, input::AbstractString) where T <: GeoFormat = T(convert(String, (input)))

"""
    ProjString <: CoordinateReferenceSystemFormat

    ProjString(x::String)

Wrapper for Proj strings. String input must start with "$PROJ_PREFIX".
"""
struct ProjString <: CoordinateReferenceSystemFormat
    val::String
    ProjString(input::String) = begin
        startswith(input, PROJ_PREFIX) ||
            throw(ArgumentError("Not a Proj string: $input does not start with $PROJ_PREFIX"))
        new(input)
    end
end

"""
    CoordSys <: CoordinateReferenceSystemFormat

    CoordSys(val)

Wrapper for a Mapinfo CoordSys string.
"""
struct CoordSys <: CoordinateReferenceSystemFormat
    val::String
end

"""
    AbstractWellKnownText <: MixedFormat

Well known text has a number of versions and standards, and can hold
either coordinate reference systems or geometric data in string format.
"""
abstract type AbstractWellKnownText{X} <: MixedFormat{X} end

"""
    WellKnownText <: AbstractWellKnownText

    WellKnownText(val)
    WellKnownText(mode, val)
    
Weapper for Well-Known-Text v1, following the OGC standard.
These may hold CRS or geometry data.

These may hold CRS or geometry data. The default mode is `Mixed()`,
and conversions to either type will be attempted where possible.
A specific type can be specified if it is known, e.g.:

```julia
geom = WellKnownText(Geom(), geom_string)
```
"""
struct WellKnownText{X} <: AbstractWellKnownText{X}
    mode::X
    val::String
end
WellKnownText(val) = WellKnownText(Unknown(), val)

"""
    WellKnownText2 <: AbstractWellKnownText

    WellKnownText2(val)
    WellKnownText2(mode, val)

Weapper for Well-Known-Text v2 objects, following the new OGC standard.

These may hold CRS or geometry data. The default mode is `Unknown()`,
and conversions to either type will be attempted where possible.
A specific type can be specified if it is known, e.g.:

```julia
crs = WellKnownText2(CRS(), crs_string)
```
"""
struct WellKnownText2{X} <: AbstractWellKnownText{X}
    mode::X
    val::String
end
WellKnownText2(val) = WellKnownText2(Unknown(), val)

"""
    ESRIWellKnownText <: AbstractWellKnownText

    ESRIWellKnownText(x::String)
    ESRIWellKnownText(::CRS, x::String)
    ESRIWellKnownText(::Geom, x::String)

Wrapper for Well-Known-Text strings, following the ESRI standard.

These may hold CRS or geometry data. The default mode is `Unknown`,
and conversions to either type will be attempted where possible.
A specific type can be specified if it is known, e.g:

```julia
crs = ESRIWellKnownText(CRS(), crs_string)
```
"""
struct ESRIWellKnownText{X} <: AbstractWellKnownText{X}
    mode::X
    val::String
end
ESRIWellKnownText(val) = ESRIWellKnownText(Unknown(), val)

"""
    WellKnownBinary <: MixedFormat

Wrapper for Well-Known-Binary objects.

These may hold CRS or geometry data. The default mode is `Unknown`,
and conversions to either type will be attempted where possible.
A specific type can be specified if it is known, e.g:

```julia
crs = WellKnownBinary(CRS(), crs_blob)
```
"""
struct WellKnownBinary{X,T} <: MixedFormat{X}
    mode::X
    val::T
end
WellKnownBinary(val) = WellKnownBinary(Unknown(), val)

Base.convert(::Type{String}, input::WellKnownBinary) =
    error("`convert` to `String` is not defined for `WellKnownBinary`")


"""
    EPSG <: CoordinateReferenceSystemFormat

    EPSG(input)

EPSG code representing a coordinate reference system from the
EPSG spatial reference system registry.

String input must start with "$EPSG_PREFIX". `EPSG` can be converted to an `Int` or `String`
using `convert`, or another `CoordinateReferenceSystemFormat` when ArchGDAL.jl is loaded.
"""
struct EPSG <: CoordinateReferenceSystemFormat
    val::Int
end
function EPSG(input::AbstractString)
    startswith(input, EPSG_PREFIX) || throw(ArgumentError("String $input does no start with $EPSG_PREFIX"))
    code = parse(Int, input[findlast(EPSG_PREFIX, input).stop+1:end])
    EPSG(code)
end

Base.convert(::Type{Int}, input::EPSG) = val(input)
Base.convert(::Type{String}, input::EPSG) = string(EPSG_PREFIX, val(input))
Base.convert(::Type{EPSG}, input::Int) = EPSG(input)

"""
    KML <: GeometryFormat

Wrapper object for "Keyhole Markup Language" (KML) strings.

See: https://www.ogc.org/standards/kml/

Can be converted to a `String`. Conversion to crs will convert from EPSG(4326),
which is the default for KML.
"""
struct KML <: GeometryFormat
    val::String
end
# We know KML always has a crs of EPSG(4326)
Base.convert(::Type{T}, ::KML) where T<:CoordinateReferenceSystemFormat = convert(T, EPSG(4326))

"""
    GML <: MixedFormat

Wrapper for Geography Markup Language string.

These contain geometry data, but may also have embedded crs information.
`GML` can be converted to either a `GeometryFormat` or `CoordinateReferenceSystemFormat`.
"""
struct GML{X} <: MixedFormat{X}
    mode::X
    val::String
end
GML(val) = GML(Unknown(), val)

"""
    GeoJSON <: GeometryFormat

Wrapper for a GeoJSON `String` or `Dict`.

Conversion between `Dict` and `String` values is not yet handles.
"""
struct GeoJSON{T} <: GeometryFormat
    val::T
end

end # module
