setwd('~/GitHub/IBD-EDA')

library(dplyr)

read.csv('./new r scripts/data.csv') %>%
  select(-X) -> data


data %>%
  colnames() -> variable_names
  

variable_names[variable_names != "los"] ->
  variable_names


as.formula(paste("los ~", paste(variable_names, collapse = " + "))) -> new_formula
glm(formula = new_formula, family = binomial, data = data) -> new_model
new_model %>%
  summary() -> summary_model
summary_model$coefficients[, "Pr(>|z|)"] ->
  p_values

while (max(p_values) > 0.05) {
  max_p_value_index <- which.max(p_values)
  max_p_value_attribute <- names(p_values)[max_p_value_index]
  print(max_p_value_attribute)
  
  variable_names <- variable_names[variable_names != max_p_value_attribute]
  new_formula <- as.formula(paste("los ~", paste(variable_names, collapse = " + ")))

  new_model <- glm(formula = new_formula, family = binomial, data = data)
  summary_model <- summary(new_model)
  
  p_values <- summary_model$coefficients[, "Pr(>|z|)"]
  # break
}


new_formula -> final_formula

final_formula

summary.glm(new_model)
ci <- confint(new_model)
exp(cbind(OR <- coef(new_model), ci))
predictions <- predict(new_model, test_data, type="response")