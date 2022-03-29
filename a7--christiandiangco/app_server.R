source("propublica.R")
library(dplyr)
library(ggplot2)

server <- function(input, output) {
  # main table of representatives
  output$table <- renderDataTable({
    members <- get_members(input$chamber, input$state)
    members$age <- sapply(members$id, get_age)
    select(members, name, party, age, twitter_id, facebook_account)
  })
  
  # makes a select box with all of the representatives' names
  output$ui <- renderUI({
    members <- get_members(input$chamber, input$state)
    selectInput("rep", "Get details about this representative", members$name)
  })
  
  # displays details for a selected representative
  observeEvent(input$details, {
    members <- get_members(input$chamber, input$state)
    members <- filter(members, input$rep == name)
    id <- pull(members, id)
    website <- pull(members, times_topics_url)
    details <- head(get_details(id), 1)
    phone <- pull(details, phone)
    fax <- pull(details, fax)
    office <- pull(details, office)
    
    showModal(modalDialog(
      title = input$rep,
      HTML(
        paste(
          "Website: ", website, "<br/>",
          "Phone: ", phone, "<br/>",
          "Fax: ", fax, "<br/>",
          "Office Address: ", office
        )
      )
    ))
  })
  
  # creates the party distribution plot for a specific state
  output$party <- renderPlot({
   ggplot(data = party_summary(input$summary_state)) +
      geom_bar(
        mapping = aes(x = party, y = representatives, fill = party),
        stat = "identity"
      ) +
      coord_flip() +
      scale_fill_manual(values = c("R" = "red", "D" = "blue"),
                        labels = c("Democrat", "Republican")
      ) +
      labs(title = "Party distribution",
           x = "Party",
           y = "Number of Representatives"
      )
  })
  
  # creates the gender distribution plot for a specific state
  output$gender <- renderPlot({
    ggplot(data = gender_summary(input$summary_state)) +
      geom_bar(
        mapping = aes(x = gender, y = representatives, fill = gender),
        stat = "identity"
      ) +
      coord_flip() +
      scale_fill_manual(values = c("F" = "red", "M" = "blue"),
                        labels = c("Female", "Male")
      ) +
      labs(title = "Gender distribution",
           x = "Gender",
           y = "Number of Representatives"
      )
  })
}
