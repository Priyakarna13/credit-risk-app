# 🧠 Credit Default Risk Predictor

This is an interactive **Shiny web application** that predicts the risk of credit card default based on user input.  
It uses a pre-trained **XGBoost model** trained on the UCI Credit Card dataset.

---

## 🚀 Features

- Predict default probability based on user-entered financial & demographic details
- Clean UI with risk labels ("High Risk" / "Low Risk")
- Mobile-friendly and responsive layout
- Built with R + Shiny + XGBoost

---

## 📦 Folder Structure

credit-risk-app/
├── app.R                  # Shiny UI + server script
├── credit-risk-ml-finbench.Rproj  # RStudio project file (optional)
├── .gitignore             # Git ignore rules (optional)
├── README.md              # Project description and usage instructions
├── model/
│   └── xgb_model.rds      # Trained XGBoost model
├── outputs/               # Saved plots, AUC summary, etc.

---

## How to Run Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/credit-risk-app.git
   ```
2. Open R or RStudio, install packages:
```bash
install.packages(c("shiny", "xgboost"))
   ```
Run the app:
```bash
shiny::runApp("credit-risk-app")
   ```

---

## How to Deploy on shinyapps.io

# One-time setup:
```bash
rsconnect::setAccountInfo(name='yourname',
                          token='abc123',
                          secret='secret456')
   ```
# Deploy:
```bash
rsconnect::deployApp('credit-risk-app')
   ```
---

##  Model Details
 - Dataset: UCI Credit Card dataset
 - SMOTE applied to balance classes
 - Features used: Credit limit, age, education, repayment history, bill amount, and payment amount
 - Model: XGBoost binary classifier (with early warning flags)

## Author
Made with ❤️ by Sri
