#source('transform-data.R')

# build classification and regression tree model
library(rpart)
library(rpart.plot)

# choose complexity parameter
library(caret)
library(e1071)

# # Define cross-validation experiment
# numFolds = trainControl(method = "cv", number = 10)
# cpGrid = expand.grid(.cp = seq(0.0000001,0.5,0.0001))
# 
# # Perform the cross validation
# ebayTreeCV <- train(sold ~ . - UniqueID,
#                     data = newTrain,
#                     method = "rpart",
#                     trControl = numFolds,
#                     tuneGrid = cpGrid )

ebayTreeModel <- rpart(sold ~ . - UniqueID,
                       method="class",
                       #cp = 0.0057001,
                       cp=0.00005,
                       data=newTrain)
prp(ebayTreeModel)

# plot ROC
library(ROCR)
predROCR <- prediction(predict(ebayTreeModel, type="prob", newdata=train)[,2],
                      train$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7))

# Compute Accuracy
print("train data Accuracy: ")
print(mean(performance(predROCR, "acc")@y.values[[1]]))

# Compute Accuracy
print("train data Sensitivity (true posititive rate): ")
print(mean(performance(predROCR, "sens")@y.values[[1]]))

# Compute Accuracy
print("train data Specificity (true negative rate): ")
print(mean(performance(predROCR, "spec")@y.values[[1]]))

# Compute AUC
print("train data AUC: ")
print(performance(predROCR, "auc")@y.values[[1]])

newTrain$CART <- predict(ebayTreeModel, type="prob", newdata = newTrain)[,2]
cvTrain$CART <- predict(ebayTreeModel, type="prob", newdata = cvTrain)[,2]
# AUC for cross-validated data
cvROCR <- prediction(cvTrain$CART,
                     cvTrain$sold)
print("cross-validation train data AUC: ")
print(performance(cvROCR, "auc")@y.values[[1]])

## store result of prediction
test1 <- test
test$CART <- predict(ebayTreeModel, type="prob", newdata=test)[,2]
test1$Probability1 <- test$CART
write.table(format(test1[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/cart-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
