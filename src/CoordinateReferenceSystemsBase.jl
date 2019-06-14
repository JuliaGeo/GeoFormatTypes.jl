"""
This package is an interface that simply defines types and 
functions for coordinate reference systems, to avoid dependencies. 

Methods are found in `CoordinateReferenceSystems.jl`.
"""
module CoordinateReferenceSystemsBase

const PROJ4_PREFIX = "+proj="
const EPSG_PREFIX = "EPSG:"

export AbstractCRSdefinition, Proj4string, WellKnownText, EPSGcode, GeoJSONdictCRS

"""
Abstract type for all coordinate reference system definitions.
"""
abstract type AbstractCRSdefinition end

"""
Proj4 crs string
"""
struct Proj4string <: AbstractCRSdefinition
    data::String
end

Proj4string(input::AbstractString) = begin
    startswith(input, PROJ4_PREFIX) || throw(ArgumentError("String $input does not start with $PROJ4_PREFIX"))
    Proj4string(input)
end


"""
Well known text CRS string
"""
struct WellKnownText <: AbstractCRSdefinition
    data::String
end

"""
EPSG integer code
"""
struct EPSGcode <: AbstractCRSdefinition
    data::Int
end

"""
Constructor for EPSG:1234 style strings
"""
EPSGcode(input::AbstractString) = begin
    startswith(input, EPSG_PREFIX) || throw(ArgumentError("String $epsg_string does no start with $EPSG_PREFIX"))
    code = parse(Int, input[findlast(EPSG_PREFIX, input).stop+1:end])
    EPSGcode(code)
end

"""
geoJSON CRS, as from GeoJSON.jl
"""
struct GeoJSONdictCRS <: AbstractCRSdefinition
    data::Dict{String,Any}
end


end # module
