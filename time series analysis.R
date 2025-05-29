# --- Load Required Libraries ---
library(forecast)
library(imputeTS)
library(tseries)
library(ggplot2)
library(Metrics)
library(scales)
library(zoo)

# --- Step 1: Load and Visualize Data ---
dataset <- read.csv("PCE.csv", header = TRUE)
dataset$observation_date <- as.Date(dataset$observation_date, format = "%Y-%m-%d")

start_year <- as.numeric(format(min(dataset$observation_date), "%Y"))
start_month <- as.numeric(format(min(dataset$observation_date), "%m"))
ts_data <- ts(dataset$PCE, start = c(start_year, start_month), frequency = 12)
pce_clean <- ts_data

# Create plot-friendly DataFrame
pce_df <- data.frame(
  Date = seq.Date(from = as.Date(sprintf("%d-%02d-01", start_year, start_month)), 
                  by = "month", length.out = length(pce_clean)),
  PCE = as.numeric(pce_clean)
)

ggplot(pce_df, aes(x = Date, y = PCE)) +
  geom_line(color = "steelblue", size = 1) +
  scale_x_date(date_labels = "%Y", date_breaks = "5 years", 
               limits = as.Date(c("1959-01-01", "2024-12-31"))) +
  labs(title = "Personal Consumption Expenditures (PCE)", x = "Year", y = "PCE (Billion USD)") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(face = "bold", size = 16))

# --- Step 2: Simulate Missing Values and Impute ---
set.seed(123)
missing_idx <- sample(which(!is.na(pce_clean)), 50)
pce_missing <- pce_clean
pce_missing[missing_idx] <- NA

imp_interp <- na_interpolation(pce_missing)
imp_ma <- na_ma(pce_missing, k = 4, weighting = "exponential")
imp_kalman <- na_kalman(pce_missing)
imp_kalman_arima <- na_kalman(pce_missing, model = "auto.arima")

# RMSE for imputation methods
rmse_values <- data.frame(
  Method = c("Interpolation", "Moving Average", "Kalman StructTS", "Kalman ARIMA"),
  RMSE = c(
    rmse(pce_clean[missing_idx], imp_interp[missing_idx]),
    rmse(pce_clean[missing_idx], imp_ma[missing_idx]),
    rmse(pce_clean[missing_idx], imp_kalman[missing_idx]),
    rmse(pce_clean[missing_idx], imp_kalman_arima[missing_idx])
  )
)
print(rmse_values)

ts_pce <- imp_kalman

# --- Step 3: Decomposition ---
log_pce <- log(ts_pce)
stl_fit <- stl(log_pce, s.window = "periodic")
plot(stl_fit)

# --- Step 4: Train-Test Split ---
train <- window(log_pce, end = c(2011, 12))
test <- window(log_pce, start = c(2012, 1))
train_orig <- window(ts_pce, end = c(2011, 12))
test_orig <- window(ts_pce, start = c(2012, 1))

# --- Step 5: Forecasting Models ---
# Drift
drift_model <- rwf(train_orig, drift = TRUE, h = length(test_orig))

# Holt-Winters
hw_model <- HoltWinters(train)
hw_forecast <- forecast(hw_model, h = length(test))
hw_forecast_exp <- ts(exp(hw_forecast$mean), start = start(test_orig), frequency = 12)

# ARIMA
arima_model <- auto.arima(train)
arima_forecast <- forecast(arima_model, h = length(test))
arima_forecast_exp <- ts(exp(arima_forecast$mean), start = start(test_orig), frequency = 12)

# --- Step 6: Accuracy Comparison ---
accuracy_table <- data.frame(
  Model = c("Drift", "Holt-Winters", "ARIMA"),
  RMSE = c(rmse(test_orig, drift_model$mean), rmse(test_orig, hw_forecast_exp), rmse(test_orig, arima_forecast_exp)),
  MAE  = c(mae(test_orig, drift_model$mean), mae(test_orig, hw_forecast_exp), mae(test_orig, arima_forecast_exp)),
  MAPE = c(mape(test_orig, drift_model$mean), mape(test_orig, hw_forecast_exp), mape(test_orig, arima_forecast_exp)) * 100
)
print(round(accuracy_table, 4))

# --- Step 7: Final Forecast for 2025 using Best Model (Holt-Winters assumed) ---
final_model <- HoltWinters(log_pce)
final_forecast <- forecast(final_model, h = 12)

forecast_df <- data.frame(
  Date = seq(as.Date("2025-01-01"), by = "month", length.out = 12),
  Forecast = round(exp(final_forecast$mean), 2),
  Lower_80 = round(exp(final_forecast$lower[, 1]), 2),
  Upper_80 = round(exp(final_forecast$upper[, 1]), 2),
  Lower_95 = round(exp(final_forecast$lower[, 2]), 2),
  Upper_95 = round(exp(final_forecast$upper[, 2]), 2)
)
print(forecast_df)

# --- Final Forecast Plot ---
ggplot(forecast_df, aes(x = Date)) +
  geom_ribbon(aes(ymin = Lower_95, ymax = Upper_95), fill = "grey80", alpha = 0.6) +
  geom_line(aes(y = Forecast, color = "Forecast"), size = 1.2) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  scale_y_continuous(labels = comma_format(scale = 1e-3, suffix = "B")) +
  labs(title = "Holt-Winters Forecast for 2025",
       subtitle = "Personal Consumption Expenditure (PCE) with 95% Confidence Interval",
       x = "Month", y = "PCE (in Billion USD)") +
  scale_color_manual(values = c("Forecast" = "#0072B2")) +
  theme_minimal(base_family = "Helvetica") +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top",
    legend.title = element_blank()
  )
