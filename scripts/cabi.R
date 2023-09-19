library(tidyverse)
library(lubridate)
library(sf)

subareas <- st_read("C:/Users/IYOUNGS/Documents/GitHub/dcap/shapefiles/study_subareas/Downtown Action Plan Study Subareas.shp") %>%
  st_transform(4326)

cabi <- read_csv("C:/Users/IYOUNGS/Documents/GitHub/dcap/data/cabi_081623.csv") %>%
  drop_na(date_time)

cabi %>%
  mutate(day = wday(date_time),
         time = hour(date_time),
         utilization = num_bikes_available/capacity) %>%
  filter(day == 6 | day == 4) %>%
  group_by(name, time, day) %>%
  summarize(utilization = mean(utilization),
            lon = min(lon),
            lat = min(lat)) %>%
  st_as_sf(coords = c("lon", "lat"), remove = FALSE) %>%
  st_set_crs(4326) %>%
  st_join(subareas, join = st_intersects) %>%
  write_csv("C:/Users/IYOUNGS/Documents/GitHub/dcap/data/cabi_transformed_081623.csv")



