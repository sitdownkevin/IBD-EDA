# 加载数据
X <- read.csv("./data/X.csv", header = TRUE)
y <- read.csv("./data/y.csv", header = TRUE)

# 划分训练集和测试集
data <- cbind(X, y)

indices <- 1:nrow(data)
set.seed(123) # <= 
shuffled_indices <- sample(indices) 
train_size <- floor(0.7 * length(indices)) # <=

train_indices <- shuffled_indices[1:train_size]
test_indices <- shuffled_indices[(train_size + 1):length(indices)]
train_data <- data[train_indices, ]
test_data <- data[test_indices, ]

# Logistic Regression using stepAIC
library('MASS')
library('caret')

logit_model <- glm(dod ~ ., data = train_data, family = binomial)
step_model <- stepAIC(logit_model, direction = "both")
summary.glm(step_model)

ci <- confint(step_model)
exp(cbind(OR <- coef(step_model), ci))

predictions <- predict(step_model, test_data, type="response")


# Performance
confusion_matrix <- table(test_data[, ncol(test_data)], ifelse(predictions > 0.5, 1, 0))
## 计算准确率
accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
cat("Accuracy:", accuracy, "\n")

## 计算召回率
recall <- diag(confusion_matrix) / rowSums(confusion_matrix)
cat("Recall:", recall, "\n")

## 计算F1分数
precision <- diag(confusion_matrix) / colSums(confusion_matrix)
f1_score <- 2 * (precision * recall) / (precision + recall)
cat("F1 Score:", f1_score, "\n")


 
# ROC Curve
library(pROC)
roc_obj <- roc(test_data[, ncol(test_data)], predictions)

plot(
  roc_obj,
  col = "red", 
  main = "ROC Curve - Logistic Regression",
  legacy.axes = T, # y轴格式更改
  print.auc = TRUE, # 显示AUC面积
  print.thres = TRUE, # 添加截点和95%CI
  grid=c(0.2,0.2),
  grid.col=c("blue","yellow")
)


