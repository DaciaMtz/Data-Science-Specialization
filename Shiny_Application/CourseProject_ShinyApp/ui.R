library(shiny)

shinyUI(fluidPage(
  titlePanel("Predict Petal Length from Sepal Length"),
  sidebarLayout(
    sidebarPanel(
      h4("Documentation"),
      p("This application predicts the petal length of a flower based on its sepal length using two models:"),
      tags$ul(
        tags$li("A Linear Model: Assumes a straight-line relationship."),
        tags$li("A Polynomial Model: Captures non-linear trends.")
      ),
      p("To use the application:"),
      tags$ol(
        tags$li("Adjust the slider to select a Sepal Length."),
        tags$li("Toggle the checkboxes to show/hide prediction models."),
      ),
      sliderInput("sliderSepalLength", "Select Sepal Length:", 
                  min = min(iris$Sepal.Length), max = max(iris$Sepal.Length), 
                  value = mean(iris$Sepal.Length), step = 0.1),
      checkboxInput("showLinearModel", "Show/Hide Linear Model", value = TRUE),
      checkboxInput("showPolyModel", "Show/Hide Polynomial Model", value = TRUE),
    ),
    mainPanel(
      plotOutput("irisPlot"),
      h4("Predicted Petal Length from Linear Model:"),
      div(style = "color: red; font-size: 20px;", textOutput("linearPrediction")),
      h4("Predicted Petal Length from Polynomial Model:"),
      div(style = "color: blue; font-size: 20px;", textOutput("polyPrediction"))
    )
  )
))

