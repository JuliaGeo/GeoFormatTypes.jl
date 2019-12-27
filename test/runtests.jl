using GeoFormatTypes, Test
using GeoFormatTypes: Geom, CRS, Mixed

@test_throws ArgumentError ProjString("+lat_ts=56.5 +ellps=GRS80")
convert(String, ProjString("+proj=merc +lat_ts=56.5 +ellps=GRS80")) == "+proj=merc +lat_ts=56.5 +ellps=GRS80"

@test_throws ArgumentError EPSG("ERROR:4326")
@test convert(String, EPSG("EPSG:4326")) == "EPSG:4326" 
@test convert(String, EPSG(4326)) == "EPSG:4326" 
@test convert(Int, EPSG("EPSG:4326")) == 4326 

@test convert(String, WellKnownText(Geom(), "test")) == "test"
@test convert(String, WellKnownText2(CRS(), "test")) == "test"
@test convert(String, ESRIWellKnownText(Geom(), "test")) == "test"
@test convert(String, GML(Mixed(), "test")) == "test"
@test convert(String, KML("test")) == "test"
@test convert(String, GeoJSON("test")) == "test"

@test_throws ArgumentError convert(KML, ProjString("+proj=test"))
