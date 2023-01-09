library(tidyverse)
numbers_eu <- read_csv("https://usegalaxy.eu/tiaas/numbers.csv")
numbers_eu$site = 'eu'

numbers_us <- read_csv("https://usegalaxy.org/tiaas/numbers.csv")
numbers_us$site = 'us'

numbers_fr <- read_csv("https://usegalaxy.fr/tiaas/numbers.csv")
numbers_fr$site = 'fr'

numbers_au <- read_csv("https://usegalaxy.org.au/tiaas/numbers.csv")
numbers_au$site = 'au'
numbers <- do.call(rbind, list(numbers_au, numbers_eu, numbers_us, numbers_fr))

ggplot(numbers, aes(start, fill=site)) +
  geom_histogram(position="stack") +
  xlab("Start Date") + ylab("Number of Events") +
  ggtitle("Events over time") +
  scale_fill_manual(values=c("#D52D00", "#EF7627", "#FF9A56", "#FFCC56"))
ggsave("images/event-starts.png", width=5, height=2)
system(paste("optipng ", getwd(), "images/event-starts.png"))

ggplot(numbers, aes(end-start, fill=site)) + 
  geom_histogram(position="stack") +
  xlab("Event Length (Days)") + ylab("Number of Events") + 
  ggtitle("Event Lengths") +
  scale_fill_manual(values=c("#F9A9D9", "#ED71BB", "#B55690", "#A30262"))
ggsave("images/event-lengths.png", width=5, height=2)
system(paste("optipng ", getwd(), "images/event-lengths.png"))
