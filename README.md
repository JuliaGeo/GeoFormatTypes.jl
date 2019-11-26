# GeoFormatTypes

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/dev)
[![Build Status](https://travis-ci.org/JuliaGeo/GeoFormatTypes.jl.svg?branch=master)](https://travis-ci.org/JuliaGeo/GeoFormatTypes.jl)

Geographic data and metadata comes in many formats, such as Proj4 strings and EPSG codes for coordinate reference systems, 
GeoJSON or KML for point data, and Well Known Text for both. These formates are often stored as strings, but may also be represented as integer codes or dictionaries.

GeoFormatTypes defines wrapper types to make it easy to pass these formats between packages while keeping information about what format is contained - instead of passing a `String` or `Int` that could be from any type.

Wrapper types allows the use of base methods such as `convert` to work with data in
multiple formats, instead of defining lists of format-specific handling methods.
