module GeoFormatTypes

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export GeoFormat

export CoordinateReferenceSystemFormat, EPSG, ProjString, ProjJSON, CoordSys, GML

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

Trait specifying that a format object, like [`WellKnownText`](@ref),
contains geometry data.
"""
struct Geom <: FormatMode end
Base.show(io::IO, ::MIME"text/plain", ::Type{Geom}) = print(io, "Geometry mode")

"""
    CRS <: FormatMode

    CRS()

Trait specifying that a format object, like [`WellKnownText`](@ref),
contains only coordinate reference system data.
"""
struct CRS <: FormatMode end
Base.show(io::IO, ::MIME"text/plain", ::Type{CRS}) = print(io, "CRS mode")

"""
   MixedFormatMode <: FormatMode

Abstract subtype of [`FormatMode`](@ref) where both
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
Base.show(io::IO, ::MIME"text/plain", ::Type{Extended}) = print(io, "Extended mode")

"""
    Unknown <: MixedFormatMode <: FormatMode

    Unknown()

Trait specifying that for a mixed format object, like [`WellKnownText`](@ref),
it is unknown whether it stores geometry or coordinate reference system data, or both.
"""
struct Unknown <: MixedFormatMode end
Base.show(io::IO, ::MIME"text/plain", ::Type{Unknown}) = print(io, "Unknown mode")

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

function Base.show(io::IO, m::MIME"text/plain", gf::GeoFormat)
    compact = get(io, :compact, false)
    print(io, nameof(typeof(gf)))
    if !compact
        print(io, ": ")
        print(io, val(gf))
    end
end

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
Base.:(==)(x::CoordinateReferenceSystemFormat, y::CoordinateReferenceSystemFormat) = val(x) == val(y)

"""
    GeometryFormat <: GeoFormat

Formats representing geometries. These wrappers simply mark string
formats that may optionally be converted to Geometry objects at a later point.
"""
abstract type GeometryFormat <: GeoFormat end
Base.:(==)(x::GeometryFormat, y::GeometryFormat) = val(x) == val(y)

"""
    MixedFormat <: GeoFormat

Formats that may hold either or both coordinate reference systems and geometries.
"""
abstract type MixedFormat{X} <: GeoFormat end
Base.:(==)(x::MixedFormat, y::MixedFormat) = x.mode == y.mode && val(x) == val(y)

val(x::GeoFormat) = x.val

mode(format::GeoFormat) = mode(typeof(format))
mode(::Type{<:GeometryFormat}) = Geom()
mode(::Type{<:CoordinateReferenceSystemFormat}) = CRS()
mode(::Type{<:MixedFormat}) = Unknown()
mode(::Type{<:MixedFormat{M}}) where {M} = M()

# Most GeoFormat types wrap String or have a constructor for string inputs
Base.convert(::Type{String}, input::GeoFormat) = val(input)
Base.convert(::Type{T}, input::AbstractString) where {T<:GeoFormat} = T(convert(String, (input)))

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
function Base.show(io::IO, m::MIME"text/plain", proj::ProjString)
    compact = get(io, :compact, false)
    print(io, "ProjString")
    if !compact
        print(io, ": ")
        print(io, val(proj))
    end
end

"""
    ProjJSON <: CoordinateReferenceSystemFormat

    ProjJSON(x::Dict{String,<:Any})
    ProjJSON(x::String)

Wrapper for [PROJJSON](https://proj.org/specifications/projjson.html).
"""
struct ProjJSON <: CoordinateReferenceSystemFormat
    val::Union{String,Dict{String,<:Any}}
    ProjJSON(input::Dict{String,<:Any}) = begin
        haskey(input, "type") ||
        throw(ArgumentError("Not a ProjJSON: $input does not have the required key 'type'"))
        new(input)
    end
    ProjJSON(input::String) = begin
        occursin("type", input) ||
        throw(ArgumentError("Not a ProjJSON: $input does not have the required key 'type'"))
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

function Base.show(io::IO, m::MIME"text/plain", mf::MixedFormat{X}) where {X}
    compact = get(io, :compact, false)
    print(io, nameof(typeof(mf)))
    if !compact
        print(io, " with ")
        show(io, m, X)
        print(io, ": ")
        print(io, val(mf))
    end
end

"""
    WellKnownText <: AbstractWellKnownText

    WellKnownText(val)
    WellKnownText(mode, val)

Wrapper for Well-known text (WKT) v1, following the OGC standard.
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

Wrapper for Well-known text v2 objects, following the new OGC standard.

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

Wrapper for Well-known text strings, following the ESRI standard.

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

Wrapper for Well-known binary (WKB) objects.

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
struct EPSG{N} <: CoordinateReferenceSystemFormat
    val::NTuple{N,Int}
end
EPSG(input::Vararg{Integer}) = EPSG(input)
EPSG(input::NTuple{N,Integer}) where {N} = EPSG(convert(NTuple{N,Int}, input))
function EPSG(input::AbstractString)
    startswith(input, EPSG_PREFIX) || throw(ArgumentError("String $input does no start with $EPSG_PREFIX"))
    code = Tuple(parse.(Int, split(input[findlast(EPSG_PREFIX, input).stop+1:end], "+")))
    EPSG(code)
end

val(input::EPSG{1}) = input.val[1]  # backwards compatible
Base.convert(::Type{T}, input::EPSG{1}) where {T<:Integer} = convert(T, val(input))
Base.convert(::Type{String}, input::EPSG) = string(EPSG_PREFIX, join(input.val, "+"))
Base.convert(::Type{EPSG}, input::Integer) = EPSG((input,))

function Base.show(io::IO, ::MIME"text/plain", epsg::EPSG)
    compact = get(io, :compact, false)
    print(io, "EPSG")
    if !compact
        print(io, ":")
        print(io, join(val(epsg), "+"))
    end
end


"""
    KML <: GeometryFormat

Wrapper object for "Keyhole Markup Language" (KML) strings.

See: https://www.ogc.org/standards/kml/

Can be converted to a `String`. Conversion to crs will convert from `EPSG(4326)`,
which is the default for KML.
"""
struct KML <: GeometryFormat
    val::String
end
# We know KML always has a crs of EPSG(4326)
Base.convert(::Type{T}, ::KML) where {T<:CoordinateReferenceSystemFormat} = convert(T, EPSG(4326))

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

function Base.show(io::IO, m::MIME"text/plain", gml::GML{T}) where {T}
    compact = get(io, :compact, false)
    print(io, "GML")
    if !compact
        print(io, " with ")
        show(io, m, T)
        print(io, ": ")
        print(io, val(gml))
    end
end

"""
    GeoJSON <: GeometryFormat

Wrapper for a GeoJSON `String` or `Dict`.

Conversion between `Dict` and `String` values is not yet handled.
"""
struct GeoJSON{T} <: GeometryFormat
    val::T
end

function Base.show(io::IO, m::MIME"text/plain", json::GeoJSON{T}) where {T}
    compact = get(io, :compact, false)
    print(io, "GeoJSON $T")
    if !compact
        print(io, ": ")
        print(io, val(json))
    end
end

end # module
