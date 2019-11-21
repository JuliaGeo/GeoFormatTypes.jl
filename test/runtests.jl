using GeoFormatTypes, Test

@test_throws ArgumentError ProjString("+lat_ts=56.5 +ellps=GRS80")
convert(String, ProjString("+proj=merc +lat_ts=56.5 +ellps=GRS80")) == "+proj=merc +lat_ts=56.5 +ellps=GRS80"

@test_throws ArgumentError EPSG("ERROR:4326")
@test convert(String, EPSG("EPSG:4326")) == "EPSG:4326" 
@test convert(String, EPSG(4326)) == "EPSG:4326" 
@test convert(Int, EPSG("EPSG:4326")) == 4326 

@test convert(String, WellKnownText("test")) == "test"
@test convert(String, WellKnownText2("test")) == "test"
@test convert(String, ESRIWellKnownText("test")) == "test"
@test convert(String, GML("test")) == "test"
@test convert(String, KML("test")) == "test"
@test convert(String, GeoJSON("test")) == "test"
