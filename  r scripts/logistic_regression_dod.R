library('MASS')
library('caret')

X <- read.csv("X.csv", header = TRUE)
y <- read.csv("y.csv", header = TRUE)

data <- cbind(X, y)
set.seed(123)
indices <- 1:nrow(data)

shuffled_indices <- sample(indices)
train_size <- floor(0.7 * length(indices))
train_indices <- shuffled_indices[1:train_size]
test_indices <- shuffled_indices[(train_size + 1):length(indices)]

train_data <- data[train_indices, ]
test_data <- data[test_indices, ]


logit_model <- glm(dod ~ ., data = train_data, family = binomial)
step_model <- stepAIC(logit_model, direction = "both")
summary(step_model)

test_predictions <- predict(step_model, newdata = test_data, type = "response")
threshold <- 0.5
test_predictions_binary <- ifelse(test_predictions > threshold, 1, 0)