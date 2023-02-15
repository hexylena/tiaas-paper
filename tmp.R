library(tidyverse)
library(maps)

numbers = read_csv("numbers.csv")

countries = numbers %>% select(location, attendance) %>% separate_rows(location, sep="\\|") %>% group_by(location) %>% summarize(n=n(), at=sum(attendance))
head(countries)

# Remove things that go across the IDL
world_map = map_data("world") %>% 
  filter(! long > 180)

# Merge the data sets together
countries_annotated = full_join(countries, iso3166, by=c("location"="a2"))

countries_annotated %>% ggplot(aes(fill=n, map_id=mapname)) + geom_map(map = world_map) +
  expand_limits(x = world_map$long, y = world_map$lat) +
  coord_map("mercator")
ggsave("images/map-events.png")

countries_annotated %>% ggplot(aes(fill=at, map_id=mapname)) + geom_map(map = world_map) +
  expand_limits(x = world_map$long, y = world_map$lat) +
  coord_map("mercator")
ggsave("map-attendance.png")
