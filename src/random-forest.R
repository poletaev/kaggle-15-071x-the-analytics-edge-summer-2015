source('transform-data.R')

## build random forest model
library(randomForest)
ntree <- 4000
nodesize <- 2

tuneRF(newTrain[,-c(9, 10)], newTrain[,9],ntreeTry=ntree, stepFactor=1.5,
       improve=0.05, trace=TRUE, plot=TRUE, doBest=FALSE,
       nodesize=nodesize)

ebayRandomForestModel <- randomForest(sold ~ . - UniqueID,
                                      ntree=ntree,
                                      mtry = 4,
                                      nodesize=nodesize,
                                      data=newTrain)
plot(ebayRandomForestModel)

# plot ROC
library(ROCR)
predROCR <- prediction(predict(ebayRandomForestModel, type="prob", newdata=cvTrain)[,2],
                       cvTrain$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="ROC curve for random-forest model on CV set")

# Compute Accuracy
print("cross-validation train data Accuracy: ")
print(mean(performance(predROCR, "acc")@y.values[[1]]))

# Compute Accuracy
print("cross-validation train data Sensitivity (true posititive rate): ")
print(mean(performance(predROCR, "sens")@y.values[[1]]))

# Compute Accuracy
print("cross-validation train data Specificity (true negative rate): ")
print(mean(performance(predROCR, "spec")@y.values[[1]]))

# Compute AUC
print("cross-validation train data AUC: ")
print(performance(predROCR, "auc")@y.values[[1]])

predROCR <- prediction(predict(ebayRandomForestModel, type="prob", newdata=newTrain)[,2],
                       newTrain$sold)
print("train data AUC: ")
print(performance(predROCR, "auc")@y.values[[1]])


## store result of prediction
test1 <- test
newTrain$RF <- predict(ebayRandomForestModel, type="prob", newdata=newTrain)[,2]
cvTrain$RF <- predict(ebayRandomForestModel, type="prob", newdata=cvTrain)[,2]
test$RF <- predict(ebayRandomForestModel, type="prob", newdata=test)[,2]
test1$Probability1 <- test$RF
write.table(format(test1[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/random-forest-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
