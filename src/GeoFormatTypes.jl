module GeoFormatTypes

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoFormatTypes

export GeoFormat, EPSGcode, ESRI, GML, GeoJSON, KML,
       ProjString, WellKnownText, WellKnownBinary

const PROJ_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"

"""
Abstract supertype for all formats
"""
abstract type GeoFormat end

val(x::GeoFormat) = x.val

# Most GeoFormat types wrap String or have a constructor for string inputs
Base.convert(::Type{String}, input::GeoFormat) = val(input)
Base.convert(::Type{T}, input::AbstractString) where T <: GeoFormat = T(input)

"""
Proj string
"""
struct ProjString <: GeoFormat
    val::String
    ProjString(input::String) = begin
        startswith(input, PROJ_PREFIX) ||
            throw(ArgumentError("String $input does not start with $PROJ_PREFIX"))
        new(input)
    end
end

Base.show(io::IO, x::ProjString) = print(io, "Proj:\n$(val(x))")

"""
Well known text
"""
struct WellKnownText <: GeoFormat
    val::String
end

Base.show(io::IO, x::WellKnownText) = print(io, "Well Known Text:\n$(val(x))")


"""
Well known binary
"""
struct WellKnownBinary{T} <: GeoFormat
    val::T
end

Base.show(io::IO, x::WellKnownBinary) = print(io, "Well Known Binary")

"""
EPSG code
"""
struct EPSGcode <: GeoFormat
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

Base.convert(::Type{Int}, input::EPSGcode) = val(input)
Base.convert(::Type{String}, input::EPSGcode) = string(EPSG_PREFIX, val(input))
Base.convert(::Type{EPSGcode}, input::Int) = EPSGcode(input)

Base.show(io::IO, x::EPSGcode) = print(io, "EPSGcode: $EPSG_PREFIX$(val(x))")

"""
ESRI code
"""
struct ESRI <: GeoFormat
    val::String
end

Base.show(io::IO, x::ESRI) = print(io, "ESRI: $(val(x))")

"""
Keyhole Markup Language
"""
struct KML <: GeoFormat
    val::String
end

Base.show(io::IO, x::KML) = print(io, "KML:\n$(val(x))")

"""
Geography Markup Language
"""
struct GML <: GeoFormat
    val::String
end

Base.show(io::IO, x::GML) = print(io, "GML:\n$(val(x))")

"""
GeoJSON

Can be a string or a Dict? Will need to handle convert for Dict.
"""
struct GeoJSON{T} <: GeoFormat
    val::T
end

Base.show(io::IO, x::GeoJSON) = print(io, "GeoJSON:\n$(repr(val(x)))")

end # module
