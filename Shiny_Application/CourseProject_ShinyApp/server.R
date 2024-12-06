library(shiny)

shinyServer(function(input, output) {
  # Linear model using the iris dataset
  linearModel <- lm(Petal.Length ~ Sepal.Length, data = iris)
  
  # Polynomial regression model (quadratic)
  polyModel <- lm(Petal.Length ~ poly(Sepal.Length, 2, raw = TRUE), data = iris)
  
  # Reactive expression for predictions from the linear model
  linearPred <- reactive({
    sepalLengthInput <- input$sliderSepalLength
    predict(linearModel, newdata = data.frame(Sepal.Length = sepalLengthInput))
  })
  
  # Reactive expression for predictions from the polynomial model
  polyPred <- reactive({
    sepalLengthInput <- input$sliderSepalLength
    predict(polyModel, newdata = data.frame(Sepal.Length = sepalLengthInput))
  })
  
  # Render the plot
  output$irisPlot <- renderPlot({
    sepalLengthInput <- input$sliderSepalLength
    
    plot(iris$Sepal.Length, iris$Petal.Length, 
         xlab = "Sepal Length", ylab = "Petal Length", 
         pch = 16, col = "lightblue",
         main = "Prediction of Petal Length Based on Sepal Length")
    
    # Add linear model line
    if (input$showLinearModel) {
      abline(linearModel, col = "red", lwd = 2)
    }
    
    # Add polynomial model line
    if (input$showPolyModel) {
      sepalRange <- seq(min(iris$Sepal.Length), max(iris$Sepal.Length), length.out = 100)
      polyLines <- predict(polyModel, newdata = data.frame(Sepal.Length = sepalRange))
      lines(sepalRange, polyLines, col = "blue", lwd = 2)
    }
    
    # Highlight the predictions
    points(sepalLengthInput, linearPred(), col = "red", pch = 16, cex = 2)
    points(sepalLengthInput, polyPred(), col = "blue", pch = 16, cex = 2)
    
    legend("topright", legend = c("Linear Model", "Polynomial Model"), 
           col = c("red", "blue"), lwd = 2, bty = "n")
  })
  
  # Render the predicted value from the linear model
  output$linearPrediction <- renderText({
    round(linearPred(), 2)
  })
  
  # Render the predicted value from the polynomial model
  output$polyPrediction <- renderText({
    round(polyPred(), 2)
  })
})
