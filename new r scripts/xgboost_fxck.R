# 清除变量
# 设置工作环境
rm(list=ls(all=TRUE))
setwd('~/GitHub/IBD-EDA')

# 加载软件包
library(dplyr)
library(xgboost)
library(performance)
library(ggplot2)
library(corrplot)
library(DALEX)

# 读取数据
read.csv('./new r scripts/data_norm.csv') %>%
  select(-X) -> data

data %>% str

# 设置数据和参数
dtrain <- xgb.DMatrix(data = as.matrix(data[,-1]), label = data[,1])


# 设置参数 (已经选出了 XGBoost 的最佳参数)
params <- list(
  objective = "reg:squarederror",
  max_depth = 4,
  min_child_weight = 2,
  eta = 0.1,
  gamma = 0,
  subsample = 0.8,
  colsample_bytree = 0.8
)


# 使用xgb.cv进行交叉验证
# xgb.cv(params = params, 
#        data = dtrain, 
#        nrounds = 100, 
#        nfold = 10, 
#        metrics = list("rmse"), 
#        print_every_n = 10, 
#        early_stopping_rounds = 10, 
#        maximize = FALSE) -> 
#   cv.result


# 查看交叉验证的结果
# print(cv.result)


# 使用全部数据训练最终模型
xgboost(data = dtrain, 
        params = params,               
        nrounds = 100, 
        print_every_n = 10, 
        early_stopping_rounds = 10) -> 
  final_model


# 计算R^2
actuals <- data[, 1] # 实际值
preds <- predict(final_model, newdata = as.matrix(data[,-1])) # 预测值

SST <- sum((actuals - mean(actuals))^2)
SSR <- sum((preds - actuals)^2)

r2_value <- 1 - SSR/SST

print(paste("R^2 Value: ", r2_value))



# 计算特征重要性
importance_matrix <- xgb.importance(feature_names = colnames(data[,-1]), model = final_model)
importance_plot <- xgb.plot.importance(importance_matrix)