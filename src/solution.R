library(caTools)

## load data
trainData <- read.csv('../data/eBayiPadTrain.csv', stringsAsFactors=FALSE)
testData <- read.csv('../data/eBayiPadTest.csv', stringsAsFactors=FALSE)

## combine train and test data
testData$train <- 0
trainData$train <- 1
testData$sold <- 0
data <- rbind(trainData, testData)

## modify independent variables
# is an auction or a sale with a fixed price
data$biddable <- as.factor(data$biddable)

# condition of the product 
condition <- as.factor(data$condition)
condition <- factor(condition, levels=c("New", "New other (see details)", "Manufacturer refurbished", "Seller refurbished", "Used", "For parts or not working"))
data$condition <- condition
rm(condition)

# whether the iPad has cellular connectivity
data$cellular <- as.factor(data$cellular)

# the cellular carrier for which the iPad is equipped
data$carrier <- as.factor(data$carrier)

# the color of the iPad
data$color <- as.factor(data$color)

# the iPad's storage capacity (in gigabytes)
data$storage <- as.factor(data$storage)

# dependent variable
data$sold <- as.factor(data$sold)

# order product line according to date of release
# it might be not accurate
# sorce of dates is https://en.wikipedia.org/wiki/IPad#iPad_series
prodline <- as.factor(data$productline)
prodline <- factor(prodline, levels=c("Unknown", "iPad 1", "iPad 2", "iPad 3", "iPad mini", "iPad 4", "iPad mini 2", "iPad Air", "iPad 5", "iPad mini 3", "iPad Air 2", "iPad mini Retina"))
data$productline <- prodline
rm(prodline)

## split data back into train and test
train <- subset(data, data$train == 1)
test <- subset(data, data$train == 0)

# split train data into those used for training and for cross-validation
set.seed(144)
spl <- sample.split(trainData, 0.8)
cvTrain <- subset(train, spl == TRUE)
newTrain <- subset(train, spl == FALSE)

# build logistic regression model
logRegModel.sub <- glm(sold ~ biddable + startprice + condition + storage + productline, family=binomial(), data=newTrain)
table(newTrain$sold, predict(logRegModel.sub, type="response") > 0.5)
#table(cvTrain$sold, predict(logRegModel.sub, type="response", newdata = cvTrain) > 0.5)

## store result of prediction
test$Probability1 <- predict(logRegModel.sub, type="response", newdata=test)
prediction <- test[, c("UniqueID", "Probability1")]
write.table(prediction, file="../submissions/logistic-regression-model.csv", sep=",", row.names=FALSE, col.names = TRUE, quote = FALSE)
