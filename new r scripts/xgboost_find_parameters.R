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
set.seed(123) # 设置随机种子以确保结果可重复
# 计算训练数据集的索引，假设我们分割80%为训练集，20%为测试集
train_indices <- sample(1:nrow(data), size = floor(0.8 * nrow(data)))

# 根据索引创建训练集和测试集
train_data <- data[train_indices, ]
test_data <- data[-train_indices, ]

# 安装必要的包
if (!requireNamespace("caret", quietly = TRUE)) install.packages("caret")
library(caret)

# 定义参数的网格
# 注意：我们必须包含nrounds，这是xgboost中的一个重要参数（训练轮数）
grid <- expand.grid(
  nrounds = c(50, 100, 150), # 添加nrounds参数
  max_depth = c(3, 4, 5, 6),
  min_child_weight = c(1, 2, 3),
  eta = c(0.05, 0.1, 0.3),
  gamma = c(0, 0.1, 0.2),
  subsample = c(0.7, 0.8, 0.9),
  colsample_bytree = c(0.7, 0.8, 0.9)
)

# 训练控制
trainControl <- trainControl(
  method = "cv", 
  number = 5,
  allowParallel = TRUE, # 允许并行处理
  verboseIter = FALSE # 减少训练过程中的输出，使输出更清晰
)

# 训练模型
model <- train(
  x = as.matrix(train_data[,-1]), y = train_data[,1],
  method = "xgbTree",
  trControl = trainControl,
  tuneGrid = grid,
  metric = "RMSE"
)

# 查看最佳模型的参数
print(model$bestTune)
