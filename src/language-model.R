## load data
trainData <- read.csv('../data/eBayiPadTrain.csv', stringsAsFactors=FALSE)
testData <- read.csv('../data/eBayiPadTest.csv', stringsAsFactors=FALSE)

trainData$sold <- as.factor(trainData$sold)
data <- rbind(c(trainData$description, testData$description))

###

library(tm)
library(SnowballC)

# Create corpus
corpus = Corpus(VectorSource(data))

# Convert to lower-case
corpus = tm_map(corpus, tolower)
print(corpus[[1]])
corpus = tm_map(corpus, PlainTextDocument)
print(corpus[[1]])
corpus = tm_map(corpus, removePunctuation)
print(corpus[[1]])
corpus = tm_map(corpus, removeNumbers)
print(corpus[[1]])
corpus = tm_map(corpus, removeWords, c("sold", "ipad", "appl",
                                       stopwords("english")))
print(corpus[[1]])
corpus = tm_map(corpus, stemDocument)
print(corpus[[1]])

# Create matrix
frequencies = DocumentTermMatrix(corpus)
findFreqTerms(frequencies, lowfreq=10)

# Remove sparse terms
sparse <- removeSparseTerms(frequencies, 0.995)

# Convert to a data frame

termSparse = as.data.frame(as.matrix(sparse))

# Make all variable names R-friendly
colnames(termSparse) = make.names(colnames(termSparse))

# Add dependent variable
test <- termSparse[1862:2659,]
termSparse <- termSparse[1:1861,]
termSparse$sold <- as.factor(trainData$sold)

# Split the data
library(caTools)
set.seed(144)
split = sample.split(termSparse$sold, SplitRatio = 0.8)
trainSparse = subset(termSparse, split==TRUE)
cvSparse = subset(termSparse, split==FALSE)

### RANDOM FOREST MODEL ###

library(randomForest)
ntree <- 400
nodesize <- 2

# tuneRF(trainSparse[,!colnames(trainSparse) %in% c("sold") ],
#        trainSparse$sold,ntreeTry=ntree, stepFactor=1.5,
#        improve=0.05, trace=TRUE, plot=TRUE, doBest=FALSE,
#        nodesize=nodesize)

ebayRandomForestModel <- randomForest(sold ~ .,
                                      ntree=ntree,
                                      mtry = 12,
                                      nodesize=nodesize,
                                      data=trainSparse)
plot(ebayRandomForestModel)

# plot ROC
library(ROCR)
predROCR <- prediction(predict(ebayRandomForestModel, type="prob", newdata=cvSparse)[,2],
                       cvSparse$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="ROC curve for random-forest model on CV set")

# Compute Accuracy
print("RF cross-validation train data Accuracy: ")
print(mean(performance(predROCR, "acc")@y.values[[1]]))

# Compute Accuracy
print("RF cross-validation train data Sensitivity (true posititive rate): ")
print(mean(performance(predROCR, "sens")@y.values[[1]]))

# Compute Accuracy
print("RF cross-validation train data Specificity (true negative rate): ")
print(mean(performance(predROCR, "spec")@y.values[[1]]))

# Compute AUC
print("RF cross-validation train data AUC: ")
print(performance(predROCR, "auc")@y.values[[1]])

predROCR <- prediction(predict(ebayRandomForestModel, type="prob", newdata=trainSparse)[,2],
                       trainSparse$sold)
print("RF train data AUC: ")
print(performance(predROCR, "auc")@y.values[[1]])

### CART MODEL ###

library(rpart)
library(rpart.plot)
# choose complexity parameter
library(caret)
library(e1071)

# Define cross-validation experiment
numFolds = trainControl(method = "cv", number = 10)
cpGrid = expand.grid(.cp = seq(0.0001,0.008,0.0001))

# Perform the cross validation
# ebayTreeCV <- train(sold ~ .,
#                     data = trainSparse,
#                     method = "rpart",
#                     trControl = numFolds,
#                     tuneGrid = cpGrid )

ebayTreeModel <- rpart(sold ~ . ,
                       method="class",
                       #cp = 0.0057001,
                       cp = 4e-04,
                       data=trainSparse)
prp(ebayTreeModel)

# plot ROC
library(ROCR)
predROCR <- prediction(predict(ebayTreeModel, type="prob", newdata=trainSparse)[,2],
                      trainSparse$sold)
perfROCR <- performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="CART train data ROC")

# Compute Accuracy
print("CART train data Accuracy: ")
print(mean(performance(predROCR, "acc")@y.values[[1]]))

# Compute Accuracy
print("CART train data Sensitivity (true posititive rate): ")
print(mean(performance(predROCR, "sens")@y.values[[1]]))

# Compute Accuracy
print("CART train data Specificity (true negative rate): ")
print(mean(performance(predROCR, "spec")@y.values[[1]]))

# Compute AUC
print("CART train data AUC: ")
print(performance(predROCR, "auc")@y.values[[1]])

cvROCR <- prediction(predict(ebayTreeModel, type="prob", newdata = cvSparse)[,2],
                     cvSparse$sold)
print("CART cross-validation train data AUC: ")
print(performance(cvROCR, "auc")@y.values[[1]])

perfROCR <- performance(cvROCR, "tpr", "fpr")
plot(perfROCR, colorize=TRUE, print.cutoffs.at=seq(0,1,0.1),
     text.adj=c(-0.2, 1.7), main="cross-validation train data ROC for CART")
