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
condition <- factor(condition,
                    levels=c("New",
                             "New other (see details)",
                             "Manufacturer refurbished",
                             "Seller refurbished",
                             "Used",
                             "For parts or not working"),
                    ordered=TRUE)
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
prodline <- factor(prodline,
                   levels=c("Unknown",
                            "iPad 1",           # April 30, 2010
                            "iPad 2",           # March 25, 2011
                            "iPad 3",           # March 23, 2012
                            "iPad mini",        # November 2, 2012
                            "iPad 4",           # ??
                            "iPad mini 2",      # November 12, 2013
                            "iPad Air",         # November 1, 2013
                            "iPad 5",           # ?? October 24, 2014
                            "iPad mini Retina", # ??
                            "iPad mini 3",      # October 24, 2014
                            "iPad Air 2"),      # October 24, 2014
                   ordered=FALSE)
data$productline <- prodline
rm(prodline)

## scale startprice
data$startprice <- scale(data$startprice)

# add new variable (empty description)
data$emptydescription <- factor(data$description == "")

data$description <- NULL

## split data back into train and test
train <- subset(data, data$train == 1)
test <- subset(data, data$train == 0)

train$train <- NULL
test$sold <- NULL
test$train <- NULL

# split train data into those used for training and for cross-validation
set.seed(144)
spl <- sample.split(trainData, 0.8)
newTrain <- subset(train, spl == TRUE)
cvTrain <- subset(train, spl == FALSE)

rm(trainData, testData, data, spl)