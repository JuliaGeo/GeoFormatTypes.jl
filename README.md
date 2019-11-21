# GeoFormatTypes

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://rafaqz.github.io/GeoJS.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://rafaqz.github.io/GeoFormatTypes.jl/dev)
[![Build Status](https://travis-ci.org/rafaqz/GeoFormatTypes.jl.svg?branch=master)](https://travis-ci.org/rafaqz/GeoFormatTypes.jl)

Geographic data and metadata often has multiple formats that can represent the
same informations, such as Well Known Text, Proj4 strings, EPSG codes, GeoJSON
or KML. This data may be in the form of strings, integer codes, or dictionaries.
GeoFormatTypes defines wrapper types to make it easy to pass these formats
between packages while keeping information about what format is contained,
instead of passing a `String` or `Int` that could be from any type.

This allows the use of base methods such as `convert` to work with data in
multiple formats, instead of long lists of format specific handling methods.
