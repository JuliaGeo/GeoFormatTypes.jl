using Documenter, GeoFormatTypes

makedocs(;
    modules = [GeoFormatTypes],
    sitename = "GeoFormatTypes.jl",
)

deploydocs(;
    repo="github.com/rafaqz/GeoFormatTypes.jl",
)
