source('transform-data.R')
source('cart.R')
source('logistic-regression.R')
source('random-forest.R')

# build logistic regression model
metaLogRegModel <- glm(formula = sold ~ LR + CART + RF,
                   family = binomial(), data = newTrain)

plot(metaLogRegModel)

# test overdispersion
print("ratio of residual deviance to the residual degreees of freedom for model: ")
print(deviance(metaLogRegModel)/df.residual(metaLogRegModel))

# plot ROC
library(ROCR)
predROCR <- prediction(predict(metaLogRegModel, type="response", newdata=cvTrain),
                       cvTrain$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="ROC for meta model on CV set")

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
test$Probability1 <- predict(metaLogRegModel, type="response", newdata=test)
write.table(format(test[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/meta-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
