using Documenter, CoordinateReferenceSystemsBase

makedocs(;
    modules=[CoordinateReferenceSystemsBase],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/rafaqz/CoordinateReferenceSystemsBase.jl/blob/{commit}{path}#L{line}",
    sitename="CoordinateReferenceSystemsBase.jl",
    authors="Rafael Schouten <rafaelschouten@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/rafaqz/CoordinateReferenceSystemsBase.jl",
)
