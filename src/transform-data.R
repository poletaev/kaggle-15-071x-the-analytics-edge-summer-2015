library(caTools)

## load data
trainData <- read.csv('../data/eBayiPadTrain.csv', stringsAsFactors=FALSE)
testData <- read.csv('../data/eBayiPadTest.csv', stringsAsFactors=FALSE)

## combine train and test data
testData$train <- 0
trainData$train <- 1
testData$sold <- 0
data <- rbind(trainData, testData)

library(stringr)
extractFeatures <- function(data, cols_to_modify) {
  for (col in cols_to_modify){
    new_col <- as.factor(data[,col])
    levels(new_col) <- str_replace_all(tolower(levels(new_col)),
                                       "[[:punct:]\\s]+","_")
    for (level in levels(new_col)){
      data[paste(col, level, sep="_")] <- as.factor(new_col == level)
    }
    data[col] <- NULL
  }
  return(data)
}

## modify independent variables
# is an auction or a sale with a fixed price
data$biddable <- as.factor(data$biddable)

## create new features
data <- extractFeatures(data,
                        c("condition", "cellular", "carrier", "color",
                          "storage", "productline"))

# dependent variable
data$sold <- as.factor(data$sold)

## scale startprice
data$startprice <- scale(data$startprice)

# add new variable (empty description)
data$emptydescription <- factor(data$description == "")

## split data back into train and test
train <- subset(data, data$train == 1)
test <- subset(data, data$train == 0)
test$sold <- NULL

# split train data into those used for training and for cross-validation
set.seed(144)
spl <- sample.split(trainData$sold, 0.9)
newTrain <- subset(train, spl == TRUE)
cvTrain <- subset(train, spl == FALSE)

rm(trainData, testData, data, spl)