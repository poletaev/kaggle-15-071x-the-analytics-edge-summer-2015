source('transform-data.R')

#newTrain <- newTrain[-c(1338, 146, 930, 1219, 1705, 1804, 1359),]

# build logistic regression model
logRegModel <- glm(formula = sold ~ biddable + startprice + condition_for_parts_or_not_working + 
                     condition_seller_refurbished + cellular_0 + cellular_1 + 
                     carrier_none + carrier_sprint + storage_16 + storage_32 + 
                     productline_unknown + productline_ipad_1 + productline_ipad_2 + 
                     productline_ipad_3 + productline_ipad_4 + productline_ipad_air + 
                     productline_ipad_mini + productline_ipad_mini_2 + productline_ipad_mini_3 + 
                     emptydescription - UniqueID, family = binomial(), data = newTrain)

plot(logRegModel)

# test overdispersion
print("ratio of residual deviance to the residual degreees of freedom for model: ")
print(deviance(logRegModel)/df.residual(logRegModel))

# plot ROC
library(ROCR)
predROCR <- prediction(predict(logRegModel, type="response", newdata=train),
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

# AUC for cross-validated data
cvROCR <- prediction(predict(logRegModel, type="response", newdata = cvTrain),
                     cvTrain$sold)
print("cross-validation train data AUC: ")
print(performance(cvROCR, "auc")@y.values[[1]])

## store result of prediction
test$Probability1 <- predict(logRegModel, type="response", newdata=test)
write.table(format(test[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/logistic-regression-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
