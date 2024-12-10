# server.R

library(shiny)
library(dplyr)
library(tidyr)
library(data.table)
library(stringr)

# Load the saved models
unigram_probs <- readRDS("unigram_probs.rds")
bigram_probs <- readRDS("bigram_probs_filtered.rds")
trigram_probs <- readRDS("trigram_probs_filtered.rds")
fourgram_probs <- readRDS("fourgram_probs_filtered.rds")

server <- function(input, output, session) {
  
  generate_predictions <- function(input, fourgram_probs, trigram_probs, bigram_probs, unigram_probs) {
    lambda = c(0.4, 0.3, 0.2, 0.1)
    
    # Tokenization
    tokens <- str_split(input, "\\s+")[[1]]
    n_tokens <- length(tokens)
    
    # Initialize the result list
    result_list <- list()
    
    # Prediction using backoff strategy
    if (n_tokens >= 3) {
      fourgram_prob <- fourgram_probs %>%
        filter(w1 == tokens[n_tokens - 2], w2 == tokens[n_tokens - 1], w3 == tokens[n_tokens]) %>%
        transmute(w3 = w4, prob, level = "fourgram")
      if (nrow(fourgram_prob) > 0) result_list[[length(result_list) + 1]] <- fourgram_prob
    }
    
    if (n_tokens >= 2) {
      trigram_prob <- trigram_probs %>%
        filter(w1 == tokens[n_tokens - 1], w2 == tokens[n_tokens]) %>%
        transmute(w3, prob, level = "trigram")
      if (nrow(trigram_prob) > 0) result_list[[length(result_list) + 1]] <- trigram_prob
    }
    
    if (n_tokens >= 1) {
      bigram_prob <- bigram_probs %>%
        filter(w1 == tokens[n_tokens]) %>%
        transmute(w3 = w2, prob, level = "bigram")
      if (nrow(bigram_prob) > 0) result_list[[length(result_list) + 1]] <- bigram_prob
    }
    
    # Unigram prediction (for any input)
    unigram_prob <- unigram_probs %>%
      transmute(w3 = word, prob = prob * lambda[4], level = "unigram")
    result_list[[length(result_list) + 1]] <- unigram_prob
    
    # Combine all predictions
    combined <- bind_rows(result_list) %>%
      group_by(w3) %>%
      summarise(prob = sum(prob, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(prob))
    
    # Return the 3 words with the highest combined probability
    return(head(combined$w3, 3))
  }
  
  # Reactive value to store predictions
  predictions <- reactiveVal(c())
  
  # Reactive value to store the updated input text
  updated_text <- reactiveVal("")
  
  # Observe both button click and Enter key (input text changes)
  observeEvent(input$predict_btn, {
    user_input <- tolower(trimws(input$input_ngram))
    
    # Generate predictions
    new_predictions <- generate_predictions(user_input, fourgram_probs, trigram_probs, bigram_probs, unigram_probs)
    
    if (length(new_predictions) == 0) {
      new_predictions <- c("No prediction available", "", "")
    }
    
    # Update reactive predictions
    predictions(new_predictions)
    
    # Dynamically create buttons for predictions
    output$prediction_buttons <- renderUI({
      tagList(
        lapply(1:length(new_predictions), function(i) {
          actionButton(
            inputId = paste0("prediction_", i),
            label = new_predictions[i]
          )
        })
      )
    })
  }, ignoreInit = TRUE)
  
  # Append clicked prediction to the input text
  observeEvent(input$prediction_1, {
    updated_text(paste(input$input_ngram, predictions()[1]))
    updateTextInput(session, "input_ngram", value = updated_text())
  })
  
  observeEvent(input$prediction_2, {
    updated_text(paste(input$input_ngram, predictions()[2]))
    updateTextInput(session, "input_ngram", value = updated_text())
  })
  
  observeEvent(input$prediction_3, {
    updated_text(paste(input$input_ngram, predictions()[3]))
    updateTextInput(session, "input_ngram", value = updated_text())
  })
  
  # Display the updated input text
  output$updated_input <- renderText({
    updated_text()
  })
}
