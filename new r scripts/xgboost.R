rm(list=ls(all=TRUE))
setwd('~/GitHub/IBD-EDA')

library(dplyr)
library(xgboost)
library(Metrics)


read.csv('./new r scripts/data_norm.csv') %>%
  select(-X) -> data

data %>% str


# Perform 10-fold cross-validation
num_folds <- 10
folds <- cut(seq(1, nrow(data)), breaks = num_folds, labels = FALSE)

# Create empty vectors to store the predictions and actual values
all_predictions <- vector()
all_actuals <- vector()



# Train process
for (i in 1:num_folds) {
  train_data <- data[folds != i, ]
  test_data <- data[folds == i, ]
  
  train_X <- as.matrix(train_data[, -1])
  train_y <- train_data[, 1]
  dtrain <- xgb.DMatrix(data = train_X, label = train_y)
  
  test_X <- as.matrix(test_data[, -1])
  test_y <- test_data[, 1]
  dtest <- xgb.DMatrix(data = test_X, label = test_y)
  
  # Train the XGBoost model
  # xgb_model <- xgboost(data = dtrain, nrounds = 100, objective = "reg:squarederror")
  

  # 设置最佳参数
  best_params <- list(
    objective = "reg:squarederror",
    max_depth = 4,
    min_child_weight = 2,
    eta = 0.1,
    gamma = 0,
    subsample = 0.8,
    colsample_bytree = 0.8
  )
  
  # 训练模型
  xgb_model <- xgboost(data = dtrain, 
                       params = best_params, 
                       nrounds = 100,
                       # watchlist = list(eval = dtrain, train = dtrain),
                       print_every_n = 10,
                       early_stopping_rounds = 10)  

  
  # Make predictions on the test set
  predictions <- predict(xgb_model, dtest)
  
  # Append the predictions and actual values to the vectors
  all_predictions <- c(all_predictions, predictions)
  all_actuals <- c(all_actuals, test_y)
  
  
  mse <- mse(test_y, predictions)
  rmse <- sqrt(mse)  # 或者直接使用 
  # rmse <- rmse(all_actuals, all_predictions)
  mae <- mae(test_y, predictions)
  r_squared <- cor(test_y, predictions)^2
  
  print(paste("MSE: ", mse))
  print(paste("RMSE: ", rmse))
  print(paste("MAE: ", mae))
  print(paste("R²: ", r_squared))
  
  # 计算特征重要性
  importance_matrix <- xgb.importance(feature_names = colnames(train_X), model = xgb_model)
  
  # 打印特征重要性
  print(importance_matrix)
  
  # 绘制特征重要性
  xgb.plot.importance(importance_matrix)
}


