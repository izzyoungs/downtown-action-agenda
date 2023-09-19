library(gtfstools)
library(tidyverse)
library(sf)

gtfs <- read_gtfs("C:/Users/IYOUNGS/Downloads/e037d9cd3ac171acd7ab909ed6ba6bd0acd3ed7b.zip")

study_area <- st_read("C:/Users/IYOUNGS/Documents/GitHub/dcap/shapefiles/study_area/Downtown Action Plan Study Area.shp") %>%
  st_transform(4326)

routes_in_study_area <- filter_by_sf(gtfs, study_area)

route_geom <- convert_shapes_to_sf(routes_in_study_area)
stops_geom <- convert_stops_to_sf(routes_in_study_area)

mapview::mapview(stops_geom)

routes_in_study_area$trips %>%
  count(route_id, direction_id)

routes_in_study_area$trips %>%
  select()

routes_in_study_area$trips %>% glimpse
