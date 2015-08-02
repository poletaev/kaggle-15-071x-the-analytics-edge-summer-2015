#source('transform-data.R')

#newTrain <- newTrain[-c(1338, 146, 930, 1219, 1705, 1804, 1359),]

# build logistic regression model
logRegModel <- glm(formula = sold ~ biddable + startprice + cellular + storage + productline + 
                     emptydescription,
                   family = binomial(),
                   data = newTrain)

plot(logRegModel)
step(logRegModel)

# test overdispersion
print("ratio of residual deviance to the residual degreees of freedom for model: ")
print(deviance(logRegModel)/df.residual(logRegModel))

# plot ROC
library(ROCR)
predROCR <- prediction(predict(logRegModel, type="response", newdata=train),
                      train$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="train data ROC")

predROCR <- prediction(predict(logRegModel, type="response", newdata=cvTrain),
                       cvTrain$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="cross-validation train data ROC")

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

## store result of prediction
test1 <- test
newTrain$LR <- predict(logRegModel, type="response", newdata=newTrain)
cvTrain$LR <- predict(logRegModel, type="response", newdata=cvTrain)
test$LR <- predict(logRegModel, type="response", newdata=test)
test1$Probability1 <- test$LR
write.table(format(test1[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/logistic-regression-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
