rm(list=ls(all=TRUE))
setwd('C:/Users/kexu/Documents/GitHub/IBD-EDA/aes/')
# setwd('/home/kexu/Documents/GitHub/IBD-EDA/aes/')


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
  select(-c(die_in_icu, icu_count)) ->
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

summary_model <- summary(model$finalModel)

# Coeff
coefficients <- summary_model$coefficients
# print(coefficients)

# Odds Ratio
odds_ratios <- exp(coefficients[,1])
# print(odds_ratios)

# 95%CI
conf_int <- exp(confint(model$finalModel))
# print(conf_int)

# Result
result <- data.frame(
  # Parameter = rownames(summary_model$coefficients),
  Estimate = summary_model$coefficients[,1],
  S.E. = summary_model$coefficients[,2],
  PValue = summary_model$coefficients[,4],
  OR1 = odds_ratios, OR2 = conf_int[,1], OR3 = conf_int[,2]
)

write.csv(result, file = "result_temp.csv")


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

library(ggplot2)
# Create a data frame for plotting
roc_df <- data.frame(
  fpr = 1 - roc_curve$specificities,
  tpr = roc_curve$sensitivities
)
library(extrafont)
loadfonts(device = 'win')

# Plot the ROC curve using ggplot2
ggplot(roc_df, aes(x = fpr, y = tpr)) +
  geom_area(fill = "gray", alpha = 0.2) +       # Fill the area under the curve
  geom_line(color = "blue", size = 1.2) +       # Add the ROC curve line
  geom_abline(linetype = "dashed", color = "red") +
  labs(x = "1 - Specificity", y = "Sensitivity") +
  annotate("text", x = 0.75, y = 0.25, label = paste("AUC:", round(auc, 3)), size = 5, color = "black", family = "Times New Roman") +
  theme_minimal(base_family = 'Times New Roman') +
  coord_fixed(ratio = 1)  # Ensures the aspect ratio is square