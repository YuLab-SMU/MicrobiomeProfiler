ui <- fluidPage(
  # ======== Modules ========
  # exampleModuleUI is defined in R/example-module.R
  wellPanel(
    h2("Modules example"),
    exampleModuleUI("examplemodule1", "Click counter #1"),
    exampleModuleUI("examplemodule2", "Click counter #2")
  ),
  # =========================

  wellPanel(
    h2("Sorting example"),
    sliderInput("size", "Data size", min = 5, max = 20, value = 10),
    div("Lexically sorted sequence:"),
    verbatimTextOutput("sequence")
  )
)

server <- function(input, output, session) {
  # ======== Modules ========
  # exampleModuleServer is defined in R/example-module.R
  exampleModuleServer("examplemodule1")
  exampleModuleServer("examplemodule2")
  # =========================

  data <- reactive({
    # lexical_sort from R/example.R
    lexical_sort(seq_len(input$size))
  })
  output$sequence <- renderText({
    paste(data(), collapse = " ")
  })
}

shinyApp(ui, server)
