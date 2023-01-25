library(tidyverse)
#numbers_eu <- read_csv("https://usegalaxy.eu/tiaas/numbers.csv")
#numbers_eu$site = 'eu'
#
#numbers_us <- read_csv("https://usegalaxy.org/tiaas/numbers.csv")
#numbers_us$site = 'us'
#
#numbers_fr <- read_csv("https://usegalaxy.fr/tiaas/numbers.csv")
#numbers_fr$site = 'fr'
#
#numbers_au <- read_csv("https://usegalaxy.org.au/tiaas/numbers.csv")
#numbers_au$site = 'au'
#numbers <- do.call(rbind, list(numbers_au, numbers_eu, numbers_us, numbers_fr))

#write_csv(numbers, "numbers.csv")
numbers = read_csv("numbers.csv")

if(TRUE){
st <- numbers %>% group_by(site) %>% summarize(attendance=sum(attendance),events=n())

write(round(numbers %>% select(attendance) %>% sum, -3), "inc.learners.tex")
write((numbers %>% select(attendance) %>% count)$n, "inc.events.tex")

sumstats = numbers %>% select(attendance) %>% summarize(median=median(attendance), std=sd(attendance), max=max(attendance))
write(sumstats$median, "inc.attend.median.tex")
write(round(sumstats$std,0), "inc.attend.sd.tex")
write(sumstats$max, "inc.attend.max.tex")

ggplot(numbers, aes(start, fill=site)) +
  geom_histogram(position="stack") +
  xlab("Start Date") + ylab("Number of Events") +
  ggtitle("Events over time") +
  scale_fill_manual(values=c("#D52D00", "#EF7627", "#FF9A56", "#FFCC56")) + facet_grid(rows=vars(site)) +  theme(legend.position="none") #+ scale_y_sqrt()
ggsave("images/event-starts.png", width=5, height=3)
system(paste("optipng ", "images/event-starts.png"))

ggplot(numbers, aes(end-start, fill=site)) + 
  geom_histogram(position="stack") +
  xlab("Event Length (Days)") + ylab("Number of Events") + 
  ggtitle("Event Lengths") +
  scale_fill_manual(values=c("#F9A9D9", "#ED71BB", "#B55690", "#A30262")) + facet_grid(rows=vars(site)) +  theme(legend.position="none") + scale_y_sqrt()

ggsave("images/event-lengths.png", width=5, height=3)
system(paste("optipng ", "images/event-lengths.png"))
}




library(tidyverse)
library(cowplot)   # for theme_minimal_grid()
library(sf)        # for manipulation of simple features objects
library(rworldmap) # for getMap()

world_sf <- st_as_sf(getMap(resolution = "low"))


# Link up our data
countries = numbers %>% select(location, attendance) %>% separate_rows(location, sep="\\|") %>% group_by(location) %>% summarize(events=n(), attendance=sum(attendance))
countries_annotated = full_join(world_sf, countries, by=c("ISO_A2"="location"))



crs_goode <- "+proj=igh"
# projection outline in long-lat coordinates
lats <- c(
  90:-90, # right side down
  -90:0, 0:-90, # third cut bottom
  -90:0, 0:-90, # second cut bottom
  -90:0, 0:-90, # first cut bottom
  -90:90, # left side up
  90:0, 0:90, # cut top
  90 # close
)
longs <- c(
  rep(180, 181), # right side down
  rep(c(80.01, 79.99), each = 91), # third cut bottom
  rep(c(-19.99, -20.01), each = 91), # second cut bottom
  rep(c(-99.99, -100.01), each = 91), # first cut bottom
  rep(-180, 181), # left side up
  rep(c(-40.01, -39.99), each = 91), # cut top
  180 # close
)

goode_outline <-
  list(cbind(longs, lats)) %>%
  st_polygon() %>%
  st_sfc(
    crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  )

# now we need to work in transformed coordinates, not in long-lat coordinates
goode_outline <- st_transform(goode_outline, crs = crs_goode)

# get the bounding box in transformed coordinates and expand by 10%
xlim <- st_bbox(goode_outline)[c("xmin", "xmax")]*1.1
ylim <- st_bbox(goode_outline)[c("ymin", "ymax")]*1.1

# turn into enclosing rectangle
goode_encl_rect <-
  list(
    cbind(
      c(xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]),
      c(ylim[1], ylim[1], ylim[2], ylim[2], ylim[1])
    )
  ) %>%
  st_polygon() %>%
  st_sfc(crs = crs_goode)

# calculate the area outside the earth outline as the difference
# between the enclosing rectangle and the earth outline
goode_without <- st_difference(goode_encl_rect, goode_outline)

library(devtools)
# devtools::install_github("kevinsblake/NatParksPalettes")
library(NatParksPalettes)

ggplot(countries_annotated, aes(fill=as.factor(events))) +
  geom_sf(color = "black", size = 0.5/.pt) +
  geom_sf(data = goode_without, fill = "white", color = "NA") +
  geom_sf(data = goode_outline, fill = NA, color = "gray30", size = 0.5/.pt) +
  coord_sf(crs = crs_goode, xlim = 0.95*xlim, ylim = 0.95*ylim, expand = FALSE) +
  theme_minimal_grid() +
  theme(
    panel.background = element_rect(color = "white", size = 1),
  ) + scale_fill_manual(values=rev(natparks.pals("Arches2", 20))) + labs(fill="Number of Events")
ggsave("images/map.png", width=11, height=5)
system(paste("optipng ", "images/map.png"))
