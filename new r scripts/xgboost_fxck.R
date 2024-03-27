rm(list=ls(all=TRUE))
setwd('~/GitHub/IBD-EDA')


library(dplyr)
library(xgboost)
library(performance)
library(ggplot2)
library(corrplot)
library(DALEX)


read.csv('./new r scripts/data_norm.csv') %>%
  select(-X) -> data

data %>% str

# 设置数据和参数
dtrain <- xgb.DMatrix(data = as.matrix(data[,-1]), label = data[,1])

# 设置参数，这里参数和您之前设置的一样
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
cv.nfold <- 8
cv.result <- xgb.cv(params = params, data = dtrain, nrounds = 100, nfold = cv.nfold, 
                    metrics = list("rmse"), 
                    print_every_n = 10, early_stopping_rounds = 10, 
                    maximize = FALSE)

# 查看交叉验证的结果
print(cv.result)

# 使用全部数据训练最终模型
final_model <- xgboost(data = dtrain, params = params, nrounds = 100, 
                     print_every_n = 10, early_stopping_rounds = 10)


# 计算特征重要性
importance_matrix <- xgb.importance(feature_names = colnames(data[,-1]), model = final_model)
importance_plot <- xgb.plot.importance(importance_matrix)
# ggsave("feature_importance.pdf", importance_plot)


# 计算R^2
actuals <- data[,1] # 实际值
preds <- predict(final_model, newdata = as.matrix(data[,-1])) # 预测值

SST <- sum((actuals - mean(actuals))^2)
SSR <- sum((preds - actuals)^2)
r2_value <- 1 - SSR/SST

print(paste("R^2 Value: ", r2_value))