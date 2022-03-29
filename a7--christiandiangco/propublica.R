library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)
source("propublica_key.R")

# get table of representatives for specific chamber and state
get_members <- function(chamber = "house", state = "WA") {
  uri <- sprintf(
    "https://api.propublica.org/congress/v1/members/%s/%s/current.json",
    chamber,
    state
  )
  members <- GET(uri, add_headers("X-API-Key" = propublica_key)) %>% 
    content(type = "text") %>% 
    fromJSON()
  flatten(members$results)
}

# get detailed information about a specific representative
get_details <- function(member_id) {
  uri <- sprintf("https://api.propublica.org/congress/v1/members/%s.json", member_id)
  details <- GET(uri, add_headers("X-API-Key" = propublica_key)) %>% 
    content(type ="text") %>% 
    fromJSON()
  details <- flatten(details$results)
  as.data.frame(details$roles)
}

# get the age of a specific representative
get_age <- function(member_id) {
  uri <- sprintf("https://api.propublica.org/congress/v1/members/%s.json", member_id)
  info <- GET(uri, add_headers("X-API-Key" = propublica_key)) %>% 
    content(type ="text") %>% 
    fromJSON()
  info <- flatten(info$results)
  birthday <- as.Date(info$date_of_birth)
  time_length(difftime(Sys.Date(), birthday), "years") %>% 
       floor()
}

# summarize the gender distribution of representatives for a specific state
gender_summary <- function(state) {
  house <- get_members("house", state)
  senate <- get_members("senate", state)
  all_members <- bind_rows(house, senate) %>% 
    group_by(gender) %>% 
    summarize("representatives" = n())
}

# summarize the party distribution of representatives for a specific state
party_summary <- function(state) {
  house <- get_members("house", state)
  senate <- get_members("senate", state)
  all_members <- bind_rows(house, senate) %>% 
    group_by(party) %>% 
    summarize("representatives" = n())
}
