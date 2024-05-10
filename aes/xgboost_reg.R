rm(list=ls(all=TRUE))
setwd('C:/Users/sitdo/Documents/GitHub/IBD-EDA/aes/')

library(xgboost)
library(caret)
library(dplyr)

read.csv('data_processed/data_first_record_with_commorbidities.csv') %>%
  select(-X) ->
  df

set.seed(123)

trainIndex <- createDataPartition(df$los, p = .9, 
                                  list = FALSE, 
                                  times = 1)
trainData <- df[trainIndex,]
testData <- df[-trainIndex,]

# 准备训练和测试数据
trainX <- data.matrix(trainData[, -which(names(trainData) == "los")])
trainY <- trainData$los
testX <- data.matrix(testData[, -which(names(testData) == "los")])
testY <- testData$los

grid <- expand.grid(
  nrounds = 100,
  lambda = c(0, 0.001, 0.01, 0.1),  # L2正则化项
  alpha = c(0, 0.001, 0.01, 0.1),   # L1正则化项
  eta = c(0.01, 0.05, 0.1)          # 学习率
)

trainControl <- trainControl(method = "cv", number = 5)
model <- train(x = trainX, y = trainY, 
               method = "xgbLinear", 
               trControl = trainControl, 
               tuneGrid = grid,
               metric = "Rsquared")


pred <- predict(model, testX)

# 使用postResample计算R²
R2_value <- postResample(pred, testY)[["Rsquared"]]
print(R2_value)
