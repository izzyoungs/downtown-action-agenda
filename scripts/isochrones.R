library(mapboxapi)
library(mapview)
library(tidyverse)
library(sf)
library(tidygeocoder)
library(writexl)
source("scripts/config.R")

mb_access_token("pk.eyJ1IjoiaXp6eW91bmdzIiwiYSI6ImNrODI3MHgzbjBqZXkzaHBxdGpxZDh5dWYifQ.H95COOShNs0hOU2d8wuSdg")


# Metro -------------------------------------------------------------------


metro <- st_read(dsn = "C:/Users/IYOUNGS/Documents/ArcGIS/Projects/DCAP/DCAP.gdb", layer = "MetroStationEntrances_CopyFeatures")

metro_iso <- mb_isochrone(
  metro,
  profile = "walking",
  time = 1:15,
  id_column = "GIS_ID"
)%>%
  st_make_valid()

arc.write("C:/Users/IYOUNGS/Documents/ArcGIS/Projects/DCAP/DCAP.gdb/metro_iso_updated", metro_iso)


# Parks -------------------------------------------------------------------



parks <- st_read(dsn = "C:/Users/IYOUNGS/Documents/ArcGIS/Projects/DCAP/DCAP.gdb", layer = "parks_poly_FeaturetoPoint")

parks_iso <- mb_isochrone(
  parks,
  profile = "walking",
  time = 1:15,
  id_column = "osm_id2"
)

arc.write("C:/Users/IYOUNGS/Documents/ArcGIS/Projects/DCAP/DCAP.gdb/parks_iso", parks_iso, overwrite = TRUE)



# Groceries ---------------------------------------------------------------


groceries <- st_read(dsn = "C:/Users/IYOUNGS/Documents/ArcGIS/Projects/DCAP/DCAP.gdb", layer = "grocery_stores_ExportFeature")


groceries_iso <- mb_isochrone(
  groceries,
  profile = "walking",
  time = 1:15,
  id_column = "GIS_ID"
) %>%
  st_make_valid()

groceries_iso <- groceries_iso %>%
  st_make_valid()

arc.write("C:/Users/IYOUNGS/Documents/ArcGIS/Projects/DCAP/DCAP.gdb/groceries_iso_updated2", groceries_iso)
