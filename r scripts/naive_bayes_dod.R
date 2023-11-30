# 加载数据
X <- read.csv("./data/X.csv", header = TRUE)
y <- read.csv("./data/y.csv", header = TRUE)

# 划分训练集和测试集
data <- cbind(X, y)

indices <- 1:nrow(data)
set.seed(123)
shuffled_indices <- sample(indices) 
train_size <- floor(0.8 * length(indices))

train_indices <- shuffled_indices[1:train_size]
test_indices <- shuffled_indices[(train_size + 1):length(indices)]
train_data <- data[train_indices, ]
test_data <- data[test_indices, ]

# 贝叶斯分类器
library('e1071') # 导入e1071包，其中包含贝叶斯分类器函数naiveBayes()

bayes_model <- naiveBayes(dod ~ ., data = train_data)
summary(bayes_model)

# 在测试数据集上进行预测
predictions <- predict(bayes_model, test_data[, -ncol(test_data)])

# Performance
confusion_matrix <- table(test_data[, ncol(test_data)], predictions)
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
