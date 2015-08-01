source('transform-data.R')

library(randomForest)
# build random forest model
ebayRandomForestModel <- randomForest(sold ~ . - description - UniqueID,
                                      ntree=200,
                                      nodesize=1,
                                      data=train)

plot(ebayRandomForestModel)

# plot ROC
library(ROCR)
predROCR <- prediction(predict(ebayRandomForestModel, type="prob", newdata=train)[,2],
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

## store result of prediction
test$Probability1 <- predict(ebayRandomForestModel, type="prob", newdata=test)[,2]
write.table(format(test[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/random-forest-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
