# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyServer(function(input, output) {
  
  nogram <- "the"
  nogramConf <- 0.01
  
  getUnigrams <- function() {
    readRDS("1_unigrams.rds")
  }
  
  getBigrams <- function() {
    readRDS("2_bigrams.rds")
  }
  
  getTrigrams <- function() {
    readRDS("3_trigrams.rds")
  }
  
  sanitize <- function(text) {
    text1 <- tolower(text)
    gsub("[^a-zA-Z' ]+", "", text1)    
  }
  
  predictFromTable <- function(table, key) {
    match = table[table$words == key, ]
    found = nrow(match) > 0
    cat(paste("Found for ",key, " : ", found,"\n"))
    prediction = NULL
    conf = 0.0
    if (found) {      
      prediction = match$prediction
      conf <- match$conf      
      cat(paste("Prediction for ", key, " : ", prediction, "(conf : ",conf,")", "\n"))
    } 
    list (found = found, prediction = prediction, conf = conf)
  }
  
  unigrams <- getUnigrams()
  bigrams <- getBigrams()
  trigrams <- getTrigrams()  
  
  predict <- reactive({
    ngrams <- input$ngram
    cat(paste("NGrams", ngrams,"\n"))
    
    text <- input$text
    cat(paste("Text", text,"\n"))
    
    sanitized <- sanitize(text)
    cat(paste("Sanitized", sanitized,"\n"))
    
    words <- strsplit(sanitized, " ")[[1]]
    nwords <- length(words)
    cat(paste("Word count", nwords,"\n"))
    
    found <- FALSE
    result <- list(found = found)
    
    if (ngrams >= 3 && nwords >= 3) {
      cat("Inside trigrams\n")
      key = paste(words[nwords - 2], words[nwords -1], words[nwords])
      cat(paste(key,"\n"))
      
      result = predictFromTable(trigrams, key)
    } 
    if (!result$found && ngrams >= 2 && nwords >= 2) {
      cat("Inside bigrams\n")
      key = paste(words[nwords -1], words[nwords])
      cat(paste(key,"\n"))
      
      result = predictFromTable(bigrams, key)
    }
    if (!result$found && ngrams >= 1 && nwords >= 1) {
      cat("Inside unigrams\n")
      key = words[nwords]
      cat(paste(key,"\n"))
      
      result = predictFromTable(unigrams, key)
    }
    
    if (!result$found) {
      result$prediction <- nogram
      result$conf <- nogramConf
    }
    
    result    
  })
  
  output$header <- renderText(
    if (input$text != "") {
      paste("Did I guess correctly? (ngrams = ", input$ngram, ")", sep = "")
    } else {
      "Did I guess correctly? (Enter valid input)"
    })
  
  output$prediction <- renderText(
    if (input$text != "") {
      predict()$prediction
    } else {
      ""
    })
  
  output$line <- renderText(
    if (input$text != "") {
      paste(input$text, predict()$prediction)
    } else {
      ""
    })
  
  output$confidence <- renderText(
    if (input$text != "") {
      sprintf("%.1f%%", 100*predict()$conf)
    } else {
      ""
    })
})