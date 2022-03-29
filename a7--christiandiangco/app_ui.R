about_page <- tabPanel(
  title = "About",
  HTML(
    paste(
      h2("Affiliation"),
      "Christian Diangco <br/>",
      "INFO-201A: Technical Foundations of Informatics <br/>",
      "The Information School <br/>",
      "University of Washington <br/>",
      "Autumn 2019 <br/> <br/>",
      h2("Overview"),
      "This assignment tasked me with creating a Shiny App in R by using data
      from the <a href=https://projects.propublica.org/api-docs/congress-api/>ProPublica API</a>. 
      As you can see, the app has an <em> About,
      Representatives, and Summary </em> page. <br/> <br/>",
      "The <em> Representatives </em> page allows the user to view 
      a table displaying information for the congressional representatives 
      for each US state. They can specify to see either House or Senate 
      members. They can also view detailed information for each member by
      selecting their name from a select box. <br/> <br/>",
      "The <em> Summary </em> page displays two graphs for each US state. The
      top graph displays the party distribution for the state while the bottom
      graph displays the gender distribution for the state. The user selects
      which state to view in the same fashion as the <em> Representatives </em>
      page.",
      h2("Reflective Statement"),
      "One of the challenges I faced when making this Shiny application was
      implenting the details on demand feature for each representative.
      I wasn't sure where to find the detailed information I needed
      (e.g. address, phone) for each member until I explored the data I got.
      I found that the data was in its own data frame called roles inside the
      original data frame. I then had to figure out how to implement the pop up
      feature for displaying the detailed information. After looking around, I
      found that I was able to accomplish this using modalDialog() and
      showModal()."
    )
  )
)

state_reps <- tabPanel(
  title = "Representatives",
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "state",
        "State",
        state.abb,
        selected = "WA"
      ),
      radioButtons(
        "chamber",
        "Chamber",
        c("house", "senate"),
        selected = "house"
      ),
      # makes the select box of representative names
      uiOutput("ui"),
      actionButton("details", "Get details")
    ),
    mainPanel(
      dataTableOutput("table")
    )
  )
)

summary_page <- tabPanel(
  title = "Summary Page",
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "summary_state",
        "State",
        state.abb,
        selected = "WA"
      )
    ),
    mainPanel(
      plotOutput("party"),
      plotOutput("gender")
    )
  )
)

ui <- navbarPage(
  title = "Congressional Representative Information Lookup",
  about_page,
  state_reps,
  summary_page
)
