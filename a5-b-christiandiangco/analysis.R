library(dplyr)
library(tidyr)
library(leaflet)
library(ggplot2)
mass_shootings <- read.csv("data/shootings-2018.csv", stringsAsFactors = F)

# ------------Summary information---------------
num_shootings <- nrow(mass_shootings)
lives_lost <- sum(mass_shootings$num_killed)
# City with the most shootings
city_biggest_impact <- mass_shootings %>%
  group_by(city) %>%
  summarize(shootings = n()) %>%
  filter(shootings == max(shootings)) %>%
  pull(city)
month_most_shootings <- mass_shootings %>%
  mutate(month = format(as.Date(date, "%B %d, %Y"), "%B")) %>%
  group_by(month) %>%
  summarize(shootings = n()) %>%
  filter(shootings == max(shootings)) %>%
  pull(month)
# Returns state, city, and address of the shooting with the most victims
# as well as the number of victims
shooting_most_victims <- mass_shootings %>%
  mutate(total_victims = num_killed + num_injured) %>%
  filter(total_victims == max(total_victims)) %>%
  select(state, city, address, total_victims)

# -----------Summary Table------------------
shootings_per_state <- mass_shootings %>%
  group_by(state) %>%
  summarize(
    shootings = n(),
    injured = sum(num_injured),
    killed = sum(num_killed)
  ) %>%
  arrange(-shootings)
colnames(shootings_per_state) <- c(
  "State", "Number of shootings", "People injured", "People killed"
)

# ------------Description of a particular incident--------------
seattle_shooting <- mass_shootings %>%
  filter(city == "Seattle (Skyway)")
seattle_shooting_date <- pull(seattle_shooting, date)
seattle_shooting_state <- pull(seattle_shooting, state)
seattle_shooting_city <- pull(seattle_shooting, city)
seattle_shooting_address <- pull(seattle_shooting, address)
seattle_shooting_killed <- pull(seattle_shooting, num_killed)
seattle_shooting_injured <- pull(seattle_shooting, num_injured)

# ------------An interactive map-------------------
mass_shooting_map <- leaflet(data = mass_shootings) %>%
  addTiles() %>%
  addCircleMarkers(
    lat = ~lat,
    lng = ~long,
    radius = ~ num_killed * 3,
    color = "red",
    popup = ~ paste(
      "Date:", date, "<br> People killed:", num_killed, "<br> People injured:",
      num_injured
    )
  )

#-------------A plot of your choice--------------------
mass_shootings_month <- mass_shootings %>%
  mutate(dummy_date = paste(
    format(as.Date(date, "%B %d, %Y"), "%B"), "1, 2018"
  ))
mass_shootings_month <- mass_shootings_month %>%
  select(num_killed, num_injured, dummy_date) %>%
  group_by(dummy_date) %>%
  summarize(num_injured = sum(num_injured), num_killed = sum(num_killed)) %>%
  gather(key = "status", value = "num_people", -dummy_date)


ggplot(data = mass_shootings_month) +
  geom_col(
    mapping = aes(
      x = as.Date(dummy_date, "%B %d, %Y"),
      y = num_people,
      fill = status
    ),
    position = "dodge",
  ) +
  scale_x_date(date_breaks = "month", date_labels = "%b") +
  labs(
    x = "Month",
    y = "Number of Mass Shooting Victims",
    title = "Number of People Killed and Injured in Mass Shootings by Month"
  ) +
  scale_fill_brewer(
    palette = "Set1",
    name = "Status",
    labels = c("Injured", "Killed")
  )
