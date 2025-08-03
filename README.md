## Credit Risk Prediction App

This is an interactive Shiny web app that predicts whether a customer poses a **credit risk** based on their input financial behavior. It uses a trained **XGBoost model** built on real-world credit card data.

---

### Features
- Predict customer credit risk with high accuracy
- Clean, responsive UI (mobile & desktop)
- Real-time prediction using XGBoost model
- Built in R + Shiny, deployed via ShinyApps.io

---

### Try the Live App
👉 [Click here to try it out!](https://priyakarna.shinyapps.io/credit-risk-ml-finbench/)

### 📂 Project Structure
   ```bash
credit-risk-app/
├── app.R                  # Shiny UI + server script
├── credit-risk-ml-finbench.Rproj  # RStudio project file (optional)
├── .gitignore             # Git ignore rules (optional)
├── README.md              # Project description and usage instructions
├── model/
│   └── xgb_model.rds      # Trained XGBoost model
├── outputs/               # Saved plots, AUC summary, etc.
```
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
3. Run the app:
```bash
shiny::runApp("credit-risk-app")
   ```

---

## How to Deploy on shinyapps.io

### One-time setup:
```bash
rsconnect::setAccountInfo(name='yourname',
                          token='abc123',
                          secret='secret456')
   ```
### Deploy:
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
