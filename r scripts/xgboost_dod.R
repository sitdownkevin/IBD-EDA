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
library(xgboost)

train_X <- as.matrix(train_data[, -ncol(train_data)])
train_y <- train_data[, ncol(train_data)]
dtrain <- xgb.DMatrix(data = train_X, label = train_y)

test_X <- as.matrix(test_data[, -ncol(test_data)])
test_y <- test_data[, ncol(test_data)]
dtest <- xgb.DMatrix(data = test_X, label = test_y)

xgb_model <- xgboost(data = dtrain, nrounds = 10, objective = "binary:logistic")

predictions <- predict(xgb_model, dtest)


# 模型评价
library(pROC)
roc_obj <- roc(test_y, predictions)

plot(
  roc_obj,
  col = "red", 
  main = "ROC Curve - XGBoost",
  legacy.axes = T, # y轴格式更改
  print.auc = TRUE, # 显示AUC面积
  print.thres = TRUE, # 添加截点和95%CI
  grid=c(0.2,0.2),
  grid.col=c("blue","yellow")
)
