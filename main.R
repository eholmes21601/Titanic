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

use_github(protocol = 'https',auth_token = Sys.getenv("GITHUB_PAT"))
