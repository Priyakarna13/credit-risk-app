library(shiny)
library(xgboost)
library(shinythemes)

# Load trained XGBoost model
xgb_model <- readRDS("model/xgb_model.rds")
model_features <- xgb_model$feature_names  # Extract feature names

# Define UI
ui <- fluidPage(
  theme = shinytheme("darkly"),
  tags$head(tags$style(HTML("  
    .main-container { max-width: 960px; margin: auto; padding: 20px; }
    .form-label { font-weight: bold; }
    .btn-primary { background-color: #1abc9c; border: none; width: 100%; font-size: 16px; }
    .form-group { margin-bottom: 15px; }
    h3 { margin-top: 20px; color: #00ffd0; }
  "))),
  
  div(class = "main-container",
      titlePanel("\U1F4B3 Credit Default Risk Predictor"),
      p("Fill in the details below to predict the likelihood of customer default. The form is responsive and works on both desktop and mobile."),
      br(),
      
      fluidRow(
        column(6,
               numericInput("limit_bal", "\U1F4B0 Credit Limit (NTD):", value = 20000, min = 10000),
               numericInput("age", "\U1F382 Age:", value = 30, min = 18, max = 100),
               selectInput("sex", "\U1F464 Gender:", choices = c("Male" = 1, "Female" = 2)),
               selectInput("education", "\U1F393 Education Level:",
                           choices = c("Graduate School" = 1, "University" = 2,
                                       "High School" = 3, "Others" = 4)),
               selectInput("marriage", "\U1F48D Marital Status:",
                           choices = c("Married" = 1, "Single" = 2, "Others" = 3))
        ),
        column(6,
               selectInput("repay_status", "\U1F4C5 Most Recent Repayment Delay:",
                           choices = c("No Delay" = 0,
                                       "Delay by 1 Month" = 1,
                                       "Delay by 2+ Months" = 2)),
               numericInput("bill_amt1", "\U1F4C4 Recent Bill Amount 1:", value = 10000),
               numericInput("bill_amt2", "\U1F4C4 Recent Bill Amount 2:", value = 8000),
               numericInput("pay_amt1", "\U1F4B8 Recent Payment 1:", value = 5000),
               numericInput("pay_amt2", "\U1F4B8 Recent Payment 2:", value = 3000),
               actionButton("predict_btn", "\U26A1 Predict Default Risk", class = "btn btn-primary")
        )
      ),
      
      br(),
      h3("\U1F50D Prediction Result"),
      verbatimTextOutput("prediction_result")
  )
)

# Define server
server <- function(input, output) {
  observeEvent(input$predict_btn, {
    pay_0 <- as.numeric(input$repay_status)
    pay_2 <- as.numeric(input$repay_status)
    warning_flag <- ifelse(pay_0 >= 2 | pay_2 >= 2, 1, 0)
    
    input_data <- data.frame(
      LIMIT_BAL = input$limit_bal,
      AGE = input$age,
      SEX = as.numeric(input$sex),
      EDUCATION = as.numeric(input$education),
      MARRIAGE = as.numeric(input$marriage),
      PAY_0 = pay_0,
      PAY_2 = pay_2,
      BILL_AMT1 = input$bill_amt1,
      BILL_AMT2 = input$bill_amt2,
      PAY_AMT1 = input$pay_amt1,
      PAY_AMT2 = input$pay_amt2,
      warning_flag = warning_flag
    )
    
    aligned <- as.data.frame(matrix(0, nrow = 1, ncol = length(model_features)))
    colnames(aligned) <- model_features
    for (col in intersect(model_features, names(input_data))) {
      aligned[[col]] <- input_data[[col]]
    }
    
    dmatrix <- xgb.DMatrix(data = as.matrix(aligned))
    pred_prob <- predict(xgb_model, dmatrix)
    
    output$prediction_result <- renderPrint({
      risk <- round(pred_prob * 100, 2)
      if (risk >= 50) {
        paste("\U26A0 HIGH RISK: Default Probability =", risk, "%")
      } else {
        paste("\U2705 LOW RISK: Default Probability =", risk, "%")
      }
    })
  })
}

# Run the app
shinyApp(ui = ui, server = server)
