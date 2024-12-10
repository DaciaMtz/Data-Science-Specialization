# ui.R

library(shiny)
library(shinythemes)

ui <- fluidPage(
  
  theme = shinythemes::shinytheme("cerulean"),  # Try "cerulean", "cosmo", "flatly", etc.
  
  titlePanel("Next Word Predictor"),
  sidebarLayout(
    sidebarPanel(
      h3("Instructions"),
      p("1. Type a phrase or a sentence in the text box."),
      p("2. Click the 'Predict Next Word' button to see suggestions. It may take a couple of seconds, please be patient"),
      p("You can select one of the suggested words to append it to your input."),
      p("You can continue typing or selecting predictions to form a complete sentence.")
    ),
    mainPanel(
      textInput("input_ngram", "Enter text:", value = "", width = "100%"),
      actionButton("predict_btn", "Predict Next Word"),
      
      h3("Predictions"),
      uiOutput("prediction_buttons"),  # Dynamic buttons will appear here
      
    )
  )
)
