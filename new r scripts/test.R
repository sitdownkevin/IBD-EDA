# 加载所需的库
library(caret) # 用于数据划分
library(randomForest)
library(dplyr)
library(ggplot2)

# 读取数据
data <- read.csv('./new r scripts/data_norm.csv') %>%
  select(-X)

# 划分数据为训练集和测试集
set.seed(123) # 设置随机种子以确保结果可重复
splitIndex <- createDataPartition(data[,1], p = .8, list = FALSE) # 80% 训练，20% 测试
trainData <- data[splitIndex,]
testData <- data[-splitIndex,]

# 训练随机森林模型
rf_model <- randomForest(x = trainData[,-1], y = trainData[,1], ntree=500, mtry=2, importance=TRUE)

# 使用模型在测试集上进行预测
preds <- predict(rf_model, newdata = testData[,-1])

# 计算测试集的R^2
actuals <- testData[,1] # 测试集的实际值
SST <- sum((actuals - mean(actuals))^2)
SSR <- sum((preds - actuals)^2)
r2_value <- 1 - SSR/SST

print(paste("Test R^2 Value: ", r2_value))
