#****************************************************
#   Created  by: Elton Holmes                       
#   Created for: Titanic mL Project
#   Topic      : Machine Learning
#   Date       : 04-12-2020
#****************************************************

library(usethis)
rm(list=ls())
library(caret)
library(doSNOW)
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







