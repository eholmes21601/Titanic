#****************************************************
#   Created  by: Elton Holmes                       
#   Created for: Titanic mL Project
#   Topic      : Machine Learning
#   Date       : 04-12-2020
#****************************************************
rm(list=ls())
library(usethis)
library(caret)
library(doSNOW)
library(parallel)
setwd("/Users/eltonholmes/Titanic/data")
test <- read.csv("test.csv",stringsAsFactors = FALSE)
train <- read.csv("train.csv",stringsAsFactors = FALSE)

table(train$Embarked)
train$Embarked[train$Embarked ==""]  <- "S"

summary(train$Age)
train$MissingAge <- ifelse(is.na(train$Age), "Y", "N")

## Calculate family size
train$FamilySize <- 1 + train$SibSp + train$Parch

train$Survived <- as.factor(train$Survived)
train$Pclass <- as.factor(train$Pclass)
train$Sex <- as.factor(train$Sex)
train$Embarked <- as.factor(train$Embarked)
train$MissingAge <- as.factor(train$MissingAge)

features <- c("Survived", "Pclass", "Sex", "Age","SibSp", "Parch", 
              "Fare", "Embarked", "MissingAge", "FamilySize")
train <- train[,features]
str(train)

## Imputation
## Caret supports a number of mechanism for imputing (i.e., 
#  predicting) missing values.  Leverage bagged decision trees
#  to impute missing values for the Age feature.

#  First, transform all feature to dummy variables

dummy.vars <- dummyVars(~ ., data = train[,-1])
train.dummy <- predict(dummy.vars, train[,-1])

pre.process <- preProcess(train.dummy, method = "bagImpute")
imputed.data <- predict(pre.process, train.dummy)
imputed.data <- as.data.frame(imputed.data)
train$Age <- imputed.data$Age

#Train/test
set.seed(54321)
indexes <- createDataPartition(train$Survived,
                               times = 1,
                               p = 0.7,
                               list = FALSE)
titanic.train <- train[indexes,]
titanic.test <- train[-indexes,]

prop.table(table(train$Survived))
prop.table(table(titanic.train$Survived))
prop.table(table(titanic.test$Survived))

#Model

#10-fild cross validation repeated 3 times and to use a grid search for 
#optimal model hyperparameter values.
train.control <- trainControl(method = "repeatedcv",
                              number = 10,
                              repeats = 3,
                              search = "grid")
tune.grid <- expand.grid(eta = c(0.05, 0.075, 0.1),
                         nrounds = c(50, 75, 100),
                         max_depth = 6:8,
                         min_child_weight = c(2.0, 2.25, 2.5 ),
                         colsample_bytree = c(0.3, 0.4, 0.5),
                         gamma = 0,
                         subsample = 1)
#c1 <- makeCluster(10, type = "SOCK")

cl <- makeCluster(3, type = "SOCK")

registerDoSNOW(cl)
caret.cv <- train(Survived ~.,
                  data = titanic.train,
                  method = "xgbTree",
                  tuneGrid = tune.grid,
                  trControl = train.control)
stopCluster(cl)
caret.cv
  
preds <- predict(caret.cv, titanic.test)
confusionMatrix(preds, titanic.test$Survived)

