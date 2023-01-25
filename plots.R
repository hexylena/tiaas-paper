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

st <- numbers %>% group_by(site) %>% summarize(attendance=sum(attendance),events=n())
write_csv(numbers, "numbers.csv")

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
system(paste("optipng ", getwd(), "images/event-starts.png"))

ggplot(numbers, aes(end-start, fill=site)) + 
  geom_histogram(position="stack") +
  xlab("Event Length (Days)") + ylab("Number of Events") + 
  ggtitle("Event Lengths") +
  scale_fill_manual(values=c("#F9A9D9", "#ED71BB", "#B55690", "#A30262")) + facet_grid(rows=vars(site)) +  theme(legend.position="none") + scale_y_sqrt()

ggsave("images/event-lengths.png", width=5, height=3)
system(paste("optipng ", getwd(), "images/event-lengths.png"))
