# GeoFormatTypes

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/GeoFormatTypes.jl/dev)
[![Build Status](https://travis-ci.org/JuliaGeo/GeoFormatTypes.jl.svg?branch=master)](https://travis-ci.org/JuliaGeo/GeoFormatTypes.jl)

Geographic data and metadata usch as geometry data and coordinate reference systems are used and distributed in multiple
multiple formats that represent similar information, such as Well Known Text, Proj4 strings, EPSG codes, GeoJSON
or KML. This data may be stored in the form of strings, integer codes, or dictionaries.

GeoFormatTypes defines wrapper types to make it easy to pass these formats
between packages while keeping information about what format is contained -
instead of passing a `String` or `Int` that could be from any type.

Wrapper types allows the use of base methods such as `convert` to work with data in
multiple formats, instead of defining lists of format-specific handling methods.
