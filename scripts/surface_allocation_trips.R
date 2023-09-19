library(tidyverse)
library(sf)

dat1 <- read_csv("C:/Users/IYOUNGS/Documents/GitHub/dcap/data/daa_od_population_surfaces_pivot.csv")

dat2 <- st_read("C:/Users/IYOUNGS/Documents/GitHub/dcap/shapefiles/surface_allocation/surfaces.shp")

dat3 <- dat1 %>% 
  mutate(NEAR_FID = as.character(NEAR_FID)) %>%
  filter(year == 2022) %>%
  group_by(NEAR_FID, day) %>%
  count(mode) %>%
  group_by(NEAR_FID, mode) %>%
  summarize(trips = round(mean(n)))
  
dat2 %>% 
  rename(NEAR_FID = FID_) %>%
  left_join(dat3) %>%
  st_write(., "C:/Users/IYOUNGS/Documents/GitHub/dcap/shapefiles/surfaces/surface_allocation.shp")

dat2 %>% 
  rename(NEAR_FID = FID_) %>%
  left_join(dat3) %>%
  st_drop_geometry() %>%
  group_by(NEAR_FID) %>%
  slice(1L) %>%
  group_by(DESCRIPTIO) %>%
  summarize(acres = sum(Acres))
  
