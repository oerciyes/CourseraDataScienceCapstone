
library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("I will read your mind!"),
  
  # Sidebar with input and prediction algo configuration
  sidebarPanel(
    h1("Write a word.."),
    
    h3("..and I will guess the next word in your mind!"),
    
    # Provide the text input
    textInput(inputId="text", 
              label="Text",
              value=""),
    
    h3("Select ngram complexity"),
    
    # Filter dataset by am=0,1 or both
    radioButtons(inputId="ngram",
                 label="Prediction NGrams",
                 choices=c("All (Unigrams, Bigrams, Trigrams) (default)"=3,
                           "Unigrams & Bigrams only"=2,
                           "Unigrams only"=1),
                 selected="3"),
    
    submitButton(text="Predict")
  ),
  
  # Show the output
  mainPanel(
    h3(textOutput("header")),
    
    h5("Prediction : "),
    textOutput("prediction"),
    
    h5("Full sentence : "),
    textOutput("line"),
    
    h5("Confidence : "),
    textOutput("confidence")
  )
))