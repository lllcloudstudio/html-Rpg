# Install required packages if not already installed
# install.packages(c("shiny", "shiny.router", "ggplot2"))

library(shiny)
library(shiny.router)
library(ggplot2)

# ---- PAGE 1: Form ----
page_form <- div(
  h2("Form Page"),
  numericInput("n_points", "Number of Points:", value = 50, min = 1, max = 1000),
  actionButton("go_plot", "Generate Plot")
)

# ---- PAGE 2: Plot + Download ----
page_plot <- div(
  h2("Generated Plot"),
  plotOutput("myplot"),
  downloadButton("download_plot", "Download Plot"),
  br(),
  actionButton("back_home", "Back to Form")
)

# ---- Router Setup ----
router <- router_ui( # make_router
  route("form", page_form),
  route("plot", page_plot)
)

# ---- UI ----
ui <- fluidPage(
  router_ui()
)

# ---- Server ----
server <- function(input, output, session) {
  
  # Store plot data in a reactive value
  plot_data <- reactiveVal(NULL)
  
  # Navigate to plot page when button clicked
  observeEvent(input$go_plot, {
    # Generate data based on form input
    df <- data.frame(
      x = rnorm(input$n_points),
      y = rnorm(input$n_points)
    )
    plot_data(df)
    change_page("plot") # Navigate to plot page
  })
  
  # Render plot on plot page
  output$myplot <- renderPlot({
    req(plot_data()) # Ensure data exists
    ggplot(plot_data(), aes(x, y)) +
      geom_point(color = "blue") +
      theme_minimal() +
      labs(title = paste("Scatter Plot with", nrow(plot_data()), "Points"))
  })
  
  # Download handler for plot
  output$download_plot <- downloadHandler(
    filename = function() {
      paste0("scatter_plot_", Sys.Date(), ".png")
    },
    content = function(file) {
      ggsave(file, plot = ggplot(plot_data(), aes(x, y)) +
               geom_point(color = "blue") +
               theme_minimal(),
             device = "png", width = 6, height = 4)
    }
  )
  
  # Back button to return to form
  observeEvent(input$back_home, {
    change_page("form")
  })
}

# ---- Run App ----
shinyApp(ui, server)
