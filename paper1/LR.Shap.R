library(dplyr)
# library(shapr)
library(fastshap)

rm(list=ls(all=TRUE))
setwd('/Volumes/Disk/Project/IBD-EDA/paper1/')

final_model <- readRDS('./final_model.rds')
new_formula <- readRDS('./new_formula.rds')
train_data <- readRDS('./train_data.rds')

feature_names <- attr(terms(new_formula), "term.labels")
feature_names <- c("", feature_names) # 添加空字符串到开头
feature_names <- feature_names[-1]
feature_names

selected_data <- dplyr::select(train_data, all_of(feature_names))
selected_data


# 计算 SHAP 值
shap_values <- explain(
  model = final_model,
  X = selected_data,
  nsim = 100,
  pred_wrapper = function(model, newdata) predict(model, newdata, type = "response")
)
