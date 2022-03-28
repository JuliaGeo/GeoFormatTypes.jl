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
Base.convert(::Type{T1}, source::T2) where {T1<:GeoFormat,T2<:T1} = source
# Convert uses the `mode` trait to distinguish crs form geometry conversion
Base.convert(target::Type{T1}, source::T2; kwargs...) where {T1<:GeoFormat,T2<:GeoFormat} = begin
    sourcemode = mode(source)
    targetmode = mode(target)
    convertmode = if targetmode isa Geom
        if sourcemode isa Union{Mixed,Geom}
            Geom() # Geom is the default if both formats are mixed
        else
            throw(ArgumentError("cannot convert $(typeof(source)) to $target"))
        end
    elseif targetmode isa CRS
        if sourcemode isa Union{Mixed,CRS}
            CRS()
        else
            throw(ArgumentError("cannot convert $(typeof(source)) to $target"))
        end
    else # targetmode isa Mixed
        # Mixed to Mixed defaults to Geom
        if sourcemode isa Union{Mixed,Geom}
            Geom()
        else
            CRS()
        end
    end
    convert(target, convertmode, source; kwargs...)
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
Base.convert(::Type{T}, input::AbstractString) where T <: GeoFormat = T(convert(String, (input)))

"""
Proj string
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
struct WellKnownText{X} <: AbstractWellKnownText{X}
    mode::X
    val::String
end
WellKnownText(val) = WellKnownText(Mixed(), val)

"""
Well known text v2 following the new OGC standard
"""
struct WellKnownText2{X} <: AbstractWellKnownText{X}
    mode::X
    val::String
end
WellKnownText2(val) = WellKnownText2(Mixed(), val)

"""
Well known text following the ESRI standard
"""
struct ESRIWellKnownText{X} <: AbstractWellKnownText{X}
    mode::X
    val::String
end
ESRIWellKnownText(val) = ESRIWellKnownText(Mixed(), val)

"""
Well known binary
"""
struct WellKnownBinary{X,T} <: MixedFormat{X}
    mode::X
    val::T
end
WellKnownBinary(val) = WellKnownBinary(Mixed(), val)

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
function EPSG(input::AbstractString)
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
convert(::Type{T}, ::KML) where T<:CoordinateReferenceSystemFormat = convert(T, EPSG(4326))

"""
Geography Markup Language
"""
struct GML{X} <: MixedFormat{X}
    mode::X
    val::String
end
GML(val) = GML(Mixed(), val)

"""
GeoJSON String or Dict
"""
struct GeoJSON{T} <: GeometryFormat
    val::T
end

end # module
