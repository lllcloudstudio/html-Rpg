library(shiny)
library(ggplot2)

canvas_w <- 600
canvas_h <- 400
class_cols <- c(A = "blue", B = "green", C = "red", D = "orange")

ui <- fluidPage(
  tags$h3("Draw Points for Multiple Classes"),
  
  fluidRow(
    column(3,
           radioButtons("class", "Select Class",
                        choices = names(class_cols),
                        selected = "A")
    ),
    column(3,
           actionButton("clear", "Clear Canvas")
    ),
    column(3,
           downloadButton("downloadData", "Download CSV")
    ),
    column(3,
           actionButton("plot", "Render Plots")
    )
  ),
  
  fluidRow(
    column(12, align = "center",
           tags$canvas(
             id = "drawCanvas",
             width = canvas_w, height = canvas_h,
             style = "border:1px solid #000; background-color:white;"
           )
    )
  ),
  br(),
  
  fluidRow(
    column(12, align = "center",
           splitLayout(
             cellWidths = c("50%", "50%"),
             plotOutput("xDensity", width = "100%", height = "250px"),
             plotOutput("yDensity", width = "100%", height = "250px")
           )
    )
  ),
  br(),
  
  fluidRow(
    column(12, align = "center",
           tableOutput("pointsTable")
    )
  ),
  
  tags$script(HTML("
$(document).ready(function() {
  var canvas  = document.getElementById('drawCanvas');
  var ctx     = canvas.getContext('2d');
  var drawing = false;

  canvas.addEventListener('mousedown', function(e) {
    drawing = true;
    drawPoint(e.offsetX, e.offsetY);
  });
  canvas.addEventListener('mousemove', function(e) {
    if (drawing) {
      drawPoint(e.offsetX, e.offsetY);
    }
  });
  canvas.addEventListener('mouseup', function(e) {
    drawing = false;
  });

  function drawPoint(x, y) {
    var cls    = $('input[name=class]:checked').val();
    var colour = 'blue';
    if (cls === 'B') colour = 'green';
    if (cls === 'C') colour = 'red';
    if (cls === 'D') colour = 'orange';

    ctx.fillStyle = colour;
    ctx.beginPath();
    ctx.arc(x, y, 3, 0, Math.PI * 2, true);
    ctx.fill();

    Shiny.setInputValue('newPoint',
      { x: x, y: y, cls: cls },
      { priority: 'event' }
    );
  }

  Shiny.addCustomMessageHandler('clearCanvas', function(msg) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
  });
});
"))
)

server <- function(input, output, session) {
  values <- reactiveVal(data.frame(
    x     = numeric(),
    y     = numeric(),
    class = character(),
    stringsAsFactors = FALSE
  ))
  
  observeEvent(input$newPoint, {
    df <- values()
    new <- data.frame(
      x     = input$newPoint$x / canvas_w * 100,
      y     = input$newPoint$y / canvas_h * 100,
      class = input$newPoint$cls,
      stringsAsFactors = FALSE
    )
    values(rbind(df, new))
  })
  
  observeEvent(input$clear, {
    values(data.frame(
      x     = numeric(),
      y     = numeric(),
      class = character(),
      stringsAsFactors = FALSE
    ))
    session$sendCustomMessage('clearCanvas', list())
  })
  
  plotData <- eventReactive(input$plot, {
    values()
  })
  
  output$pointsTable <- renderTable({
    values()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() paste0('drawn_points-', Sys.Date(), '.csv'),
    content  = function(file) write.csv(values(), file, row.names = FALSE)
  )
  
  output$xDensity <- renderPlot({
    df <- plotData()
    req(nrow(df) > 1)
    ggplot(df, aes(x = x, colour = class)) +
      geom_density() +
      scale_colour_manual(values = class_cols) +
      coord_cartesian(xlim = c(0, 100)) +
      labs(title = 'Density of X (0–100)', x = NULL, y = 'Density') +
      theme_minimal()
  })
  
  output$yDensity <- renderPlot({
    df <- plotData()
    req(nrow(df) > 1)
    ggplot(df, aes(x = y, colour = class)) +
      geom_density() +
      scale_colour_manual(values = class_cols) +
      coord_cartesian(xlim = c(0, 100)) +
      labs(title = 'Density of Y (0–100)', x = NULL, y = 'Density') +
      theme_minimal()
  })
}

shinyApp(ui, server)

#shiny::runApp("C:\Users\aflac\Documents\GitHub\html-Rpg\plumber-Rshiny\app.R",port=8081,launch.browser=FALSE)
