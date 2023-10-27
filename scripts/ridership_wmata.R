library(tidyverse)
library(readxl)
library(stringr)

stations <- c("Dupont Circle", "Farragut West", "Farragut North", "Federal Triangle", "Archives", 
              "Gallery Place", "Mt Vernon Sq", "Judiciary Square", "McPherson Sq", "Metro Center", 
              "Foggy Bottom-GWU")

# dat <- read_excel("C:/Users/IYOUNGS/Downloads/station_avgdaily_servicetype_202301-202306-v1.xlsx") %>%
#   janitor::clean_names() %>%
#   fill(station_name, month) %>%
#   filter(station_name %in% stations) %>%
#   mutate(service_type = ifelse(service_type == "Weekday", "Weekday", "Weekend")) %>%
#   group_by(station_name, service_type) %>%
#   summarize(average_total_ridership = mean(average_total_ridership)) %>%
#   pivot_wider(names_from = service_type, values_from = average_total_ridership)
# 
# dat %>%
#   write_csv("C:/Users/IYOUNGS/Documents/GitHub/daa/data/station_ridership.csv")



trains_2022 <- read_csv("C:/Users/IYOUNGS/Downloads/Total Entries and Exits_Full Data_data (6).csv") %>%
  janitor::clean_names() %>%
  filter(station %in% stations) %>%
  mutate(station = case_when(station == "McPherson Sq" ~ "McPherson Square", 
                             station == "Foggy Bottom-GWU" ~ "Foggy Bottom",
                             .default = station)) %>%
  mutate(servicetype = ifelse(servicetype == "Weekday", "Weekday", "Weekend")) %>%
  group_by(station, day_of_date_range, servicetype) %>%
  summarize(entries = sum(entries),
            exits = sum(exits)) %>%
  group_by(station, servicetype) %>%
  summarize(entries = mean(entries),
            exits = mean(exits)) %>%
  mutate(year = "2022")


trains_2019 <- read_csv("C:/Users/IYOUNGS/Downloads/Total Entries and Exits_Full Data_data (4).csv") %>%
  janitor::clean_names() %>%
  filter(station %in% stations) %>%
  mutate(station = case_when(station == "McPherson Sq" ~ "McPherson Square", 
                             station == "Foggy Bottom-GWU" ~ "Foggy Bottom",
                             .default = station)) %>%
  mutate(servicetype = ifelse(servicetype == "Weekday", "Weekday", "Weekend")) %>%
  group_by(station, day_of_date_range, servicetype) %>%
  summarize(entries = sum(entries),
            exits = sum(exits)) %>%
  group_by(station, servicetype) %>%
  summarize(entries = mean(entries),
            exits = mean(exits)) %>%
  mutate(year = "2019")


rbind(trains_2019, trains_2022) %>%
write_csv("C:/Users/IYOUNGS/Documents/GitHub/daa/data/station_ridership.csv")

rbind(trains_2019, trains_2022) %>%
  filter(year == "2022")


# Metrobus ----------------------------------------------------------------

routes <- read_csv("C:/Users/IYOUNGS/Documents/GitHub/daa/data/boardings_by_route.csv") %>%
  distinct(Route) %>%
  pull()

weekend <- read_csv("C:/Users/IYOUNGS/Downloads/Boardings by Route Table_Full Data_data.csv") %>% 
  janitor::clean_names() %>%
  filter(route %in% routes) %>%
  group_by(route, date_range) %>%
  summarize(entries = sum(entries)) %>%
  group_by(route) %>%
  summarize(entries = mean(entries)) %>%
  transmute(Route = route, Weekday = "Weekend", Rider = entries, year = "2022")


weekday <- read_csv("C:/Users/IYOUNGS/Downloads/Boardings by Route Table_Full Data_data (1).csv") %>% 
  janitor::clean_names() %>%
  filter(route %in% routes) %>%
  group_by(route, date_range) %>%
  summarize(entries = sum(entries)) %>%
  group_by(route) %>%
  summarize(entries = mean(entries)) %>%
  transmute(Route = route, Weekday = "Weekday", Rider = entries, year = "2022")

rbind(weekend, weekday) %>%
  write_csv("C:/Users/IYOUNGS/Documents/GitHub/daa/data/boardings_by_route.csv")

