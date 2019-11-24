using Documenter, GeoFormatTypes

makedocs(;
    modules = [GeoFormatTypes],
    sitename = "GeoFormatTypes.jl",
)

deploydocs(;
    repo="github.com/JuliaGeo/GeoFormatTypes.jl",
)
