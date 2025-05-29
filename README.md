# 📈 Personal Consumption Expenditure Forecasting

This project applies classical time series forecasting techniques to analyze and predict US Personal Consumption Expenditure (PCE) using R. It demonstrates key steps in time series modeling: imputation, decomposition, forecasting, and evaluation.

---

## 📊 Project Overview

- **Data Source**: [FRED Economic Data – PCE](https://fred.stlouisfed.org/)
- **Time Range**: January 1959 to December 2024
- **Forecast Target**: January–December 2025
- **Objective**: To build and compare forecasting models for PCE
- **Techniques**: Classical time series models with log-transformation and STL decomposition
- **Models Used**: Drift, Holt-Winters Exponential Smoothing, ARIMA

---

## 📦 Features

- 📥 Data import and preprocessing
- 🧹 Missing value simulation and imputation using:
  - Linear interpolation
  - Exponential moving average
  - Kalman filtering (StructTS and ARIMA)
- 🔍 STL decomposition for trend/seasonality analysis
- 🧪 Train-test split for model validation
- 📈 Forecasting with:
  - Drift model (`rwf`)
  - Holt-Winters (`HoltWinters`)
  - ARIMA (`auto.arima`)
- 📊 Forecast accuracy using RMSE, MAE, and MAPE
- 📅 Final forecast for 2025 with 80% and 95% confidence intervals
- 🖼 Clean visualizations using `ggplot2`

---

## 📂 Project Structure

```text
data_science_project/
│
├── PCE.csv                  # Input dataset (from FRED)
├── pce_forecasting.R        # Main R script for time series analysis
└── README.md                # Project documentation
