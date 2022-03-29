# GeoFormatTypes

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/dev)
[![CI](https://github.com/JuliaGeo/GeoFormatTypes.jl/workflows/CI/badge.svg)](https://github.com/JuliaGeo/GeoFormatTypes.jl/actions?query=workflow%3ACI)

GeoFormatTypes defines wrapper types to make it easy to pass and dispatch on geographic formats
like Well Known Text or GeoJSON between packages. This way information about
what format is contained is kept for later use, - instead of passing a `String`
or `Int` that could mean anything.

Wrapper types also allow methods such as `convert` to work with data in multiple
formats, instead of defining lists of format-specific handling methods.
Currently ArchGDAL.jl is priveledged to define `convert` methods for
GeoFormatTypes.jl objects, using GDAL. When it is loaded, objects can be
converted from one format to another:

```julia
julia> using GeoFormatTypes, ArchGDAL

julia> convert(WellKnownText, EPSG(4326))
WellKnownText{GeoFormatTypes.CRS, String}(GeoFormatTypes.CRS(), "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]")
```

ArchGDAL.jl is not a direct dependency of GeoFormatTypes.jl, so small packages
that handle geospatial formats in some way can depend on GeoFormatTypes.jl
without worry about large dependencies.


One complexity of `GeoFormat` objects is that some formats can hold either CRS
(Coordinate Reference System) or geometric data, or even both at the same time.

This is handled using the `CRS`, `Geom` and `Mixed` traits. When the contents
are explicitly known to be e.g. crs data, then `CRS` can be used, for example
with all types of well known text:

```julia
crs = WellKnownText2(CRS(), crs_string)
```

If the contents are not known, the default `Mixed()` will mostly do the right
thing anyway - it can be converted to either CRS or geometry formats using
`convert`, given that it is actually possible to do with the contained data.
