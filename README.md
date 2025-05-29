# Data Science Project

# 📈 Personal Consumption Expenditure Forecasting

This project applies classical time series forecasting techniques to analyse and predict US Personal Consumption Expenditure (PCE) using R.

---

## 📊 Project Overview

- **Data Source**: [FRED Economic Data - PCE](https://fred.stlouisfed.org/)
- **Time Span**: 1959 to 2024
- **Forecast Target**: 2025
- **Approach**: Classical time series models and decomposition
- **Key Models**: Drift, Holt-Winters, and ARIMA

---

## 📦 Features

- Data loading and preprocessing
- Missing value simulation and imputation using:
  - Linear interpolation
  - Exponential moving average
  - Kalman filters (StructTS and ARIMA)
- STL decomposition for trend and seasonality
- Train-test split for model evaluation
- Forecasting with:
  - Drift model (`rwf`)
  - Holt-Winters exponential smoothing
  - ARIMA (`auto.arima`)
- Model comparison using RMSE, MAE, MAPE
- Final 12-month forecast for 2025
- Visualizations with `ggplot2`

---

## 📂 Project Structure

