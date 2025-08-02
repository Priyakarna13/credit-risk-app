# Load Libraries
library(data.table)
library(ggplot2)
library(corrplot)
library(caret)
library(pROC)
library(broom)
library(dplyr)
library(smotefamily)
library(e1071)
library(DescTools)
library(cluster)
library(factoextra)
library(psych)
library(randomForest)
library(xgboost)
library(car)
library(fastshap)

# Load and Prepare Dataset
credit_data <- fread("data/UCI_Credit_Card.csv")
credit_data$ID <- NULL
if ("default.payment.next.month" %in% colnames(credit_data)) {
  setnames(credit_data, "default.payment.next.month", "default")
}
credit_data$default <- as.factor(credit_data$default)
credit_data$default <- as.numeric(as.character(credit_data$default))

# SMOTE Balancing
X <- as.data.frame(credit_data[, !names(credit_data) %in% "default", with = FALSE])
y <- credit_data$default
set.seed(123)
smote_output <- SMOTE(X, y, K = 5, dup_size = 1)
credit_data_balanced <- smote_output$data
names(credit_data_balanced)[ncol(credit_data_balanced)] <- "default"
credit_data_balanced$default <- as.factor(credit_data_balanced$default)


# Rule-Augmented Feature
credit_data_balanced$warning_flag <- ifelse(credit_data_balanced$PAY_0 >= 2 | credit_data_balanced$PAY_2 >= 2, 1, 0)
credit_data_balanced$warning_flag <- as.factor(credit_data_balanced$warning_flag)


# Train-Test Split
set.seed(123)
index <- createDataPartition(credit_data_balanced$default, p = 0.7, list = FALSE)
train <- credit_data_balanced[index, ]
test <- credit_data_balanced[-index, ]


# Logistic Regression
log_model <- glm(default ~ LIMIT_BAL + AGE + SEX + EDUCATION + MARRIAGE +
                   PAY_0 + PAY_2 + BILL_AMT1 + BILL_AMT2 + PAY_AMT1 + PAY_AMT2 + warning_flag,
                 data = train, family = "binomial")
log_probs <- predict(log_model, newdata = test, type = "response")
log_pred <- ifelse(log_probs > 0.5, "1", "0") %>% as.factor()
log_roc <- roc(as.numeric(as.character(test$default)), as.numeric(log_probs))


# Random Forest with warning_flag
rf_model <- randomForest(default ~ ., data = train, ntree = 100)
rf_pred <- predict(rf_model, test)
rf_probs <- as.numeric(predict(rf_model, test, type = "prob")[,2])
rf_roc <- roc(as.numeric(as.character(test$default)), rf_probs)
rf_importance <- importance(rf_model)



# XGBoost with warning_flag
features_train <- train[, -which(names(train) == "default")]
features_test  <- test[, -which(names(test) == "default")]
features_train_num <- data.frame(lapply(features_train, function(x) as.numeric(as.character(x))))
features_test_num  <- data.frame(lapply(features_test, function(x) as.numeric(as.character(x))))
train_matrix <- xgb.DMatrix(data = as.matrix(features_train_num), label = as.numeric(as.character(train$default)))
test_matrix  <- xgb.DMatrix(data = as.matrix(features_test_num), label = as.numeric(as.character(test$default)))

# XGBoost Tuning
set.seed(123)
xgb_cv <- xgb.cv(
  data = train_matrix,
  nrounds = 100,
  nfold = 5,
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = 6,
  eta = 0.1,
  early_stopping_rounds = 10,
  verbose = 0
)
best_nrounds <- xgb_cv$best_iteration
xgb_model <- xgboost(data = train_matrix, objective = "binary:logistic", nrounds = best_nrounds, verbose = 0)
xgb_probs <- predict(xgb_model, newdata = test_matrix)
xgb_pred <- ifelse(xgb_probs > 0.5, "1", "0") %>% factor(levels = c("0","1"))
xgb_roc <- roc(as.numeric(as.character(test$default)), xgb_probs)


# Final Business Summary
auc_summary <- data.frame(
  Model = c("Logistic Regression", "Random Forest", "XGBoost"),
  AUC = c(auc(log_roc), auc(rf_roc), auc(xgb_roc))
)
print(auc_summary)


#Save Outputs to Folder
# Save ROC Curves
png("outputs/roc_logistic.png"); plot(log_roc, main = paste("Logistic ROC - AUC:", round(auc(log_roc), 3))); dev.off()
png("outputs/roc_rf.png"); plot(rf_roc, main = paste("Random Forest ROC - AUC:", round(auc(rf_roc), 3))); dev.off()
png("outputs/roc_xgb.png"); plot(xgb_roc, main = paste("XGBoost ROC - AUC:", round(auc(xgb_roc), 3))); dev.off()

# Save AUC summary table
write.csv(auc_summary, "outputs/model_auc_summary.csv", row.names = FALSE)

print("All outputs saved to /output:")
print(list.files("outputs", full.names = TRUE))
