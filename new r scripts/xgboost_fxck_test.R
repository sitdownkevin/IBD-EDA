rm(list=ls(all=TRUE))
setwd('~/GitHub/IBD-EDA')


library(dplyr)
library(xgboost)
library(performance)
library(ggplot2)
library(corrplot)
library(DALEX)
library(caret)



# 加载和预处理数据
load_and_preprocess_data <- function(file_path) {
  data <- read.csv(file_path) %>%
    select(-X)
  return(data)
}

# 分割数据集
split_data <- function(data, train_ratio = 0.8) {
  set.seed(1123)
  train_indices <- sample(1:nrow(data), size = floor(train_ratio * nrow(data)))
  train_data <- data[train_indices, ]
  test_data <- data[-train_indices, ]
  return(list(train_data = train_data, test_data = test_data))
}

# 训练模型并评估
train_and_evaluate <- function(train_data, test_data, params, nrounds = 50) {
  dtrain <- xgb.DMatrix(data = as.matrix(train_data[,-1]), label = train_data[,1])
  dtest <- xgb.DMatrix(data = as.matrix(test_data[,-1]), label = test_data[,1])
  
  final_model <- xgboost(data = dtrain, params = params, nrounds = nrounds, 
                         print_every_n = 10, early_stopping_rounds = 10, 
                         eval_metric = "rmse", evals = list(validation = dtest))
  
  
  # 使用测试集评估R²
  actuals_test <- test_data[,1]
  preds_test <- predict(final_model, newdata = as.matrix(test_data[,-1]))
  
  results <- postResample(pred = preds_test, obs = actuals_test)
  r2_value <- results[3]  # postResample返回的第三个值是R^2
  print(paste("RMSE on Test Set: ", results[1]))
  print(paste("MAE on Test Set: ", results[2]))
  print(paste("R2 on Test Set: ", r2_value))
  
  SST_test <- sum((actuals_test - mean(actuals_test))^2)
  SSR_test <- sum((preds_test - actuals_test)^2)
  # r2_value_test <- 1 - SSR_test/SST_test
  r2_value_test <- SSR_test / SST_test
  # 
  # # 计算测试集RMSE
  # rmse_test <- sqrt(mean((preds_test - actuals_test)^2))
  # 
  print(paste("R^2 Value on Test Set: ", r2_value_test))
  # print(paste("RMSE on Test Set: ", rmse_test))
}

# 主函数
main <- function() {
  data <- load_and_preprocess_data('./new r scripts/data_norm.csv')
  splits <- split_data(data)
  
  params <- list(
    objective = "reg:squarederror",
    max_depth = 3,
    min_child_weight = 2,
    eta = 0.05,
    gamma = 0.1,
    subsample = 0.7,
    colsample_bytree = 0.8
  )
  train_and_evaluate(splits$train_data, splits$test_data, params)
}

# 运行主函数
main()

