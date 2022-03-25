using GeoFormatTypes, Test
using GeoFormatTypes: Geom, CRS, Mixed

@testset "Test construcors" begin
    @test_throws ArgumentError ProjString("+lat_ts=56.5 +ellps=GRS80")
    @test_throws ArgumentError EPSG("ERROR:4326")
    @test EPSG("EPSG:4326") == EPSG(4326)
end

@testset "Test constructors" begin
    @test ProjString("+proj=test") isa ProjString{String}
    @test EPSG(4326) isa EPSG
    @test WellKnownText("test") isa WellKnownText{Mixed,String}
    @test WellKnownText2("test") isa WellKnownText2{Mixed,String}
    @test ESRIWellKnownText("test") isa ESRIWellKnownText{Mixed,String}
    @test GML("test") isa GML{Mixed}
    @test GML(Geom(), "test") isa GML{Geom}
    @test GML(CRS(), "test") isa GML{CRS} # Probably doesn't actually exist
    @test KML("test") isa KML
    @test GeoJSON("test") isa "test"
end


@testset "Test conversion to string or int" begin
    @test convert(String, ProjString("+proj=test")) == "+proj=test"
    @test convert(String, EPSG(4326)) == "EPSG:4326"
    @test convert(Int, EPSG(4326)) == 4326
    @test convert(String, WellKnownText("test")) == "test"
    @test convert(String, WellKnownText2("test")) == "test"
    @test convert(String, ESRIWellKnownText("test")) == "test"
    @test convert(String, GML("test")) == "test"
    @test convert(String, KML("test")) == "test"
    @test convert(String, GeoJSON("test")) == "test"
end


# `convert` placeholder methods
Base.convert(target::Type{<:GeoFormat}, mode::Union{Geom,Type{Geom}}, source::GeoFormat; kwargs...) =
    (:geom, kwargs...)
Base.convert(target::Type{<:GeoFormat}, mode::Union{CRS,Type{CRS}}, source::GeoFormat; kwargs...) =
    (:crs, kwargs...)

@testset "Test convert mode allocation" begin
    @testset "Test identical type is passed through unchanged" begin
        @test convert(WellKnownText, WellKnownText(Mixed(), "test")) == WellKnownText(Mixed(), "test")
        @test convert(ProjString, ProjString("+proj=test")) == ProjString("+proj=test")
    end
    @testset "Test conversions are assigned to crs or geom correctly" begin
        @test convert(WellKnownText, WellKnownText2(CRS(), "test")) == (:crs,)
        @test convert(WellKnownText2, WellKnownText(CRS(), "test")) == (:crs,)
        @test convert(WellKnownBinary, WellKnownText(CRS(), "test")) == (:crs,)
        @test convert(ProjString, WellKnownText(CRS(), "test")) == (:crs,)
        @test convert(EPSG, ProjString("+proj=test")) == (:crs,)
        @test convert(CoordSys, ProjString("+proj=test")) == (:crs,)

        @test convert(GeoJSON, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(KML, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(GML, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(ESRIWellKnownText, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownBinary, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Geom(), "test")) == (:geom,)
        @test convert(WellKnownText, WellKnownText2(Geom(), "test")) == (:geom,)

        @test convert(GeoJSON, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(KML, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(GML, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(ESRIWellKnownText, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(WellKnownBinary, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(WellKnownText2, WellKnownText(Mixed(), "test")) == (:geom,)
        @test convert(WellKnownText, WellKnownText2(Mixed(), "test")) == (:geom,)
    end
    @testset "Test kargs pass through convert" begin
        @test convert(WellKnownText, WellKnownText2(CRS(), "test"); order=:trad) == (:crs, :order=>:trad,)
        @test convert(GML, WellKnownText(Mixed(), "test"); order=:custom) == (:geom, :order=>:custom)
    end
    @testset "Test conversions that are not possible throw an error" begin
        @test_throws ArgumentError convert(KML, ProjString("+proj=test"))
        @test_throws ArgumentError convert(GeoJSON, ProjString("+proj=test"))
        @test_throws ArgumentError convert(ProjString, WellKnownText(Geom(), "test"))
        @test_throws ArgumentError convert(CoordSys, WellKnownText(Geom(), "test"))
        @test_throws ArgumentError convert(EPSG, WellKnownText(Geom(), "test"))
    end
end
