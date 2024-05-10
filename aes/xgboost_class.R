rm(list=ls(all=TRUE))
setwd('C:/Users/sitdo/Documents/GitHub/IBD-EDA/aes/')

library(xgboost)
library(caret)
library(pROC)
library(dplyr)

read.csv('data_processed/data_first_record_with_commorbidities.csv') %>%
  select(-X) %>%
  mutate(los = if_else(los >= 4, 1, 0)) ->
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
trainY <- factor(trainY, levels = c("0", "1"))
testX <- data.matrix(testData[, -which(names(testData) == "los")])
testY <- testData$los
testY <- factor(testY, levels = c("0", "1"))

grid <- expand.grid(nrounds = 100,
                    max_depth = c(3, 4, 5),
                    eta = c(0.01, 0.05, 0.1),
                    gamma = 0,
                    colsample_bytree = 0.6,
                    min_child_weight = 1,
                    subsample = c(0.8, 0.9, 1.0))


trainControl <- trainControl(method = "cv", number = 5)
model <- train(x = trainX, y = trainY, 
               method = "xgbTree", 
               trControl = trainControl, 
               tuneGrid = grid,
               metric = "Accuracy")


pred <- predict(model, testX)
confusionMatrix(pred, testY)


rocResult <- roc(predictor = as.numeric(pred), response = testY)
plot(rocResult, main="ROC Curve")
