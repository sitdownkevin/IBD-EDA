rm(list=ls(all=TRUE))
setwd('C:/Users/kexu/Documents/GitHub/IBD-EDA/aes/')

library(dplyr)
library(caret)
library(pROC)

# Loading Data
## Plan A
dfA <- read.csv('./data_processed/data_first_record_with_commorbidities_.csv') %>%
  select(-X) %>%
  subset(die_in_icu == 0) %>%
  mutate(los = ifelse(los >= mean(los), 1, 0)) %>%
  select(-die_in_icu)

## Plan B
dfB <- read.csv('./data_processed/data_first_record_with_commorbidities_.csv') %>%
  select(-X) %>%
  mutate(los = ifelse(los >= mean(los), 1, 0)) %>%
  subset(die_in_icu == 1) %>%
  select(-die_in_icu)

## Plan C
dfC <- read.csv('./data_processed/data_first_record_with_commorbidities.csv') %>%
  select(-X) %>%
  mutate(los = ifelse(los >= mean(los), 1, 0)) %>%
  select(-c(die_in_icu, icu_count))

data <- dfC

# Fill missing values
for (var in names(data)) {
  if (is.numeric(data[[var]])) {
    data[[var]][is.na(data[[var]])] <- mean(data[[var]], na.rm = T)
  }
}

outcome_var <- 'los'
predictors <- setdiff(names(data), outcome_var)

data[[outcome_var]] <- as.factor(data[[outcome_var]])
levels(data[[outcome_var]]) <- make.names(levels(data[[outcome_var]]))

# 10-fold
train_control <- trainControl(method = 'cv', number = 10, classProbs = TRUE)

# XGBoost Model
model <- train(
  as.formula(
    paste(outcome_var, '~', paste(predictors, collapse = '+'))
  ),
  data = data,
  method = 'xgbTree',
  trControl = train_control,
  tuneLength = 5
)
print(model)

# Feature importance
cat("Feature importance:\n")
print(varImp(model))

# Predictions
data$predictions <- predict(model, data, type = 'raw')

# Confusion Matrix
confusion_matix <- confusionMatrix(data$predictions, data[[outcome_var]])
print(confusion_matix)

# ROC
data$predictions_prob <- predict(
  model,
  data,
  type = 'prob'
)[, 2]
roc_curve <- roc(data[[outcome_var]], data$predictions_prob)
plot(roc_curve, main="ROC Curve")
auc <- auc(roc_curve)
cat("AUC:", auc, "\n")
