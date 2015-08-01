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

# compute accuracy on train data:
trainTable <- table(train$sold,
                    predict(logRegModel, type="response", newdata = train) > 0.5)
print("test data accuracy: ")
print((trainTable[1, 1] + trainTable[2, 2]) / nrow(train))

# accuracy of cross-validation data:
cvTrainTable <- table(cvTrain$sold,
                    predict(logRegModel, type="response", newdata = cvTrain) > 0.5)
print("cross-validation train data accuracy: ")
print((cvTrainTable[1, 1] + cvTrainTable[2, 2]) / nrow(cvTrain))

# plot ROC
library(ROCR)
predROCR <- prediction(predict(logRegModel, type="response", newdata=train),
                      train$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7))

# Compute AUC
print("train data AUC: ")
print(performance(predROCR, "auc")@y.values)

# AUC for cross-validated data
cvROCR <- prediction(predict(logRegModel, type="response", newdata = cvTrain),
                     cvTrain$sold)
print("cross-validation train data AUC: ")
print(performance(cvROCR, "auc")@y.values)

## store result of prediction
test$Probability1 <- predict(logRegModel, type="response", newdata=test)
write.table(format(test[, c("UniqueID", "Probability1")], digits=9),
            file="../submissions/logistic-regression-model.csv",
            sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
