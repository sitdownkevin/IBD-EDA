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
train_size <- floor(0.7 * length(indices)) # 修改比例
train_indices <- shuffled_indices[1:train_size]
test_indices <- shuffled_indices[(train_size + 1):length(indices)]

train_data <- data[train_indices, ]
test_data <- data[test_indices, ]

# xgboost 只接受 matrix 先转化为matrix
train_data <- as.matrix(train_data[, 1:ncol(train_data)-1])
train_labels <- train_data[, ncol(train_data):ncol(train_data)]

test_data <- as.matrix(test_data[, 1:ncol(test_data)-1])
test_labels <- test_data[, ncol(test_data):ncol(test_data)]

# xgboost 模型
library(xgboost)
model <- xgboost(data = train_data, label = train_labels, nrounds = 10, objective = "reg:squarederror")
predictions <- predict(model, test_data)


# 模型评价
library(pROC)
roc_obj <- roc(test_labels, predictions)
plot(roc_obj, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate")


plot(roc_obj,col="red",#颜色
     main="ROC Curve - XGBoost",
     legacy.axes=T,#y轴格式更改
     print.auc=TRUE,#显示AUC面积
     print.thres=TRUE,#添加截点和95%CI
     grid=c(0.2,0.2),grid.col=c("blue","yellow"))#网格线设置

