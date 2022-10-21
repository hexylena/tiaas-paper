library(tidyverse)
numbers_eu <- read_csv("https://usegalaxy.eu/tiaas/numbers.csv")
numbers_eu$site = 'eu'
numbers_au <- read_csv("https://usegalaxy.org.au/tiaas/numbers.csv")
numbers_au$site = 'au'
numbers <- do.call(rbind, list(numbers_au, numbers_eu))

ggplot(numbers, aes(start, fill=site)) + 
  geom_histogram(position="stack") +
  xlab("Start Date") + ylab("Number of Events") + 
  ggtitle("Events over time") +
  scale_fill_manual(values=c("#D52D00", "#FF9A56"))
ggsave("event-starts.png", width=5, height=2)
system(paste("optipng ", getwd(), "event-starts.png"))

ggplot(numbers, aes(end-start, fill=site)) + 
  geom_histogram(position="stack") +
  xlab("Event Length") + ylab("Number of Events") + 
  ggtitle("Event Lengths") +
  scale_fill_manual(values=c("#D162A4", "#A30262"))
ggsave("event-lengths.png", width=5, height=2)
system(paste("optipng ", getwd(), "event-lengths.png"))
