using GeoFormatTypes, Test

WellKnownText("")
# WellKnownBinary
ProjString("+proj=merc +lat_ts=56.5 +ellps=GRS80")
@test_throws ArgumentError ProjString("+lat_ts=56.5 +ellps=GRS80")

@test EPSGcode(4326) == EPSGcode("EPSG:4326")
@test_throws ArgumentError EPSGcode("TEST:4326")

GML("")
KML("")
GeoJSON("")
GeoJSONdict(Dict());
