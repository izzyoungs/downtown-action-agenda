library(tidyverse)
library(glue)
library(lubridate)
library(data.table)
library(zoo)
library(sf)
source("scripts/config.R")


bgs <- c('110010055005',
         '110010055004',
         '110010056003',
         '110010056004',
         '110010055003',
         '110010055001',
         '110010055002',
         '110010106002',
         '110010047012',
         '110010062021',
         '110010059001',
         '110010058001',
         '110010108002',
         '110010108003',
         '110010108001',
         '110010056001',
         '110010047021',
         '110010058002',
         '110010052011',
         '110010053013',
         '110010042022',
         '110010041001',
         '110010107001',
         '110010107002',
         '110010053012',
         '110010101002',
         '110010101001',
         '110010050024',
         '110010050022',
         '110010049022',
         '110010049021',
         '110010048022',
         '110010042021',
         '110010041003',
         '110010052012')

like <- paste0("destination_bgrp LIKE '", bgs, "'", collapse = " OR ") %>%
  glue_sql()

for_bq <- glue_sql("SELECT start_time, end_time, pop.TRACT as home_tract, pop.TRACT_work as work_tract, origin_bgrp, end_lat, end_lng, mode, travel_purpose, activity_id, trips.person_id, 'thursday' as day, '2022' as year
FROM `replica-customer.mid_atlantic.mid_atlantic_2022_Q4_thursday_trip` as trips
LEFT JOIN `replica-customer.mid_atlantic.mid_atlantic_2022_Q4_population` AS pop
         ON trips.person_id = pop.person_id
WHERE {like}
UNION ALL
SELECT start_time, end_time, pop.TRACT as home_tract, pop.TRACT_work as work_tract, origin_bgrp, end_lat, end_lng, mode, travel_purpose, activity_id, trips.person_id, 'saturday' as day, '2022' as year
FROM `replica-customer.mid_atlantic.mid_atlantic_2022_Q4_saturday_trip` as trips
LEFT JOIN `replica-customer.mid_atlantic.mid_atlantic_2022_Q4_population` AS pop
         ON trips.person_id = pop.person_id
WHERE {like}
UNION ALL
SELECT start_time, end_time, pop.TRACT as home_tract, pop.TRACT_work as work_tract, origin_bgrp, end_lat, end_lng, mode, travel_purpose, activity_id, trips.person_id, 'thursday' as day, '2019' as year
FROM `replica-customer.mid_atlantic.mid_atlantic_2019_Q4_thursday_trip` as trips
LEFT JOIN `replica-customer.mid_atlantic.mid_atlantic_2019_Q4_population` AS pop
         ON trips.person_id = pop.person_id
WHERE {like}
UNION ALL
SELECT start_time, end_time, pop.TRACT as home_tract, pop.TRACT_work as work_tract, origin_bgrp, end_lat, end_lng, mode, travel_purpose, activity_id, trips.person_id, 'saturday' as day, '2019' as year
FROM `replica-customer.mid_atlantic.mid_atlantic_2019_Q4_saturday_trip` as trips
LEFT JOIN `replica-customer.mid_atlantic.mid_atlantic_2019_Q4_population` AS pop
         ON trips.person_id = pop.person_id
WHERE {like}")

# read in table
tb <- bq_project_query("replica-customer", for_bq)

# load table to data frame
df <- bq_table_download(tb)

write_rds(df, "data/replica_2019_2022_data.rds")

subareas <- st_read("C:/Users/IYOUNGS/Documents/GitHub/daa/shapefiles/study_subareas/Downtown Action Plan Study Subareas.shp") %>%
  st_transform(4326)

df2 <- df %>%
  st_as_sf(coords = c("end_lng", "end_lat"), remove = FALSE) %>%
  st_set_crs(4326) %>%
  st_join(subareas,
          join = st_intersects,
          left = FALSE)

df2 %>%
  st_drop_geometry() %>%
  mutate(origin_tract = str_sub(origin_bgrp, 1, 11)) %>%
  select(-Shape_Area, -Shape_Leng, -origin_bgrp) %>%
  write_csv("C:/Users/IYOUNGS/Documents/GitHub/daa/data/daa_od_population_subareas_full.csv")

tracts_dc <- tigris::tracts(state = "DC", year = 2010)
tracts_md <- tigris::tracts(state = "MD", year = 2010)
tracts_va <- tigris::tracts(state = "VA", year = 2010)

tracts2 <- rbind(tracts_dc, tracts_md, tracts_va)

st_write(tracts2, "C:/Users/IYOUNGS/Documents/GitHub/daa/shapefiles/tracts/tracts.shp", delete_dsn = TRUE)
