library('MASS')
library('caret')

# 加载数据
X <- read.csv("X.csv", header = TRUE)
y <- read.csv("y.csv", header = TRUE)

# 合并数据集并划分
data <- cbind(X, y)

set.seed(123) # 123
indices <- 1:nrow(data)
shuffled_indices <- sample(indices)
train_size <- floor(0.8 * length(indices)) # 修改比例
train_indices <- shuffled_indices[1:train_size]
test_indices <- shuffled_indices[(train_size + 1):length(indices)]

train_data <- data[train_indices, ]
test_data <- data[test_indices, ]

# Logistic Regression using stepAIC
logit_model <- glm(dod ~ ., data = train_data, family = binomial)
step_model <- stepAIC(logit_model, direction = "both")
summary.glm(step_model)

# test_predictions <- predict(step_model, newdata = test_data, type = "response")
# threshold <- 0.5
# test_predictions_binary <- ifelse(test_predictions > threshold, 1, 0)

ci <- confint(step_model)
print(ci)
exp(coef(step_model))
exp(cbind(OR <- coef(step_model), ci))

predictions <- predict(step_model, test_data)


# 模型评价
library(pROC)
roc_obj <- roc(test_data[, ncol(test_data)], predictions)

plot(roc_obj,col="red",#颜色
     main="ROC Curve - Logistic Regression",
     legacy.axes=T,#y轴格式更改
     print.auc=TRUE,#显示AUC面积
     print.thres=TRUE,#添加截点和95%CI
     grid=c(0.2,0.2),grid.col=c("blue","yellow"))#网格线设置


