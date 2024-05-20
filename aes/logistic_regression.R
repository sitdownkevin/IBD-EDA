rm(list=ls(all=TRUE))
setwd('C:/Users/kexu/Documents/GitHub/IBD-EDA/aes/')


library(dplyr)

# Loading Data
## Plan A
read.csv('./data_processed/data_first_record_with_commorbidities_.csv') %>%
  select(-X) %>%
  subset(die_in_icu == 0) %>%
  mutate(los = ifelse(los >= mean(los), 1, 0)) %>%
  select(-die_in_icu) ->
  dfA


## Plan B
read.csv('./data_processed/data_first_record_with_commorbidities_.csv') %>%
  select(-X) %>%
  mutate(los = ifelse(los >= mean(los), 1, 0)) %>%
  subset(die_in_icu == 1) %>%
  select(-die_in_icu) ->
  dfB


## Plan C
read.csv('./data_processed/data_first_record_with_commorbidities.csv') %>%
  select(-X) %>%
  mutate(los = ifelse(los >= mean(los), 1, 0)) %>%
  select(-c(die_in_icu, icu_count)) ->
  dfC

# ------------------------------------------------------------------------------

library(caret)
library(pROC)

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

# 10-fold
train_control <- trainControl(method = 'cv', number = 10)

# LR Model
model <- train(
  as.formula(
    paste(outcome_var, '~', paste(predictors, collapse = '+'))
  ),
  data = data,
  method = 'glm',
  family = 'binomial',
  trControl = train_control,
)
print(model)
print(summary(model$finalModel))

# Coeff
model_coefficients <- coef(model$finalModel)
cat("Coefficients:\n")
print(model_coefficients)

# Odds Ratio
odds_ratios <- exp(model_coefficients)
cat("\nOdds Ratios:\n")
print(odds_ratios)

# 95%CI
conf_int <- exp(confint(model$finalModel))
cat("\n95% Confidence Intervals for Odds Ratios:\n")
print(conf_int)

# P Value
summary_model <- summary(model$finalModel)
cat("\nP-values:\n")
print(summary_model$coefficients[, 4])

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
