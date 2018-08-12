## Load dplyr Library

library(dplyr)

## Load the Data

xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
trainsubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
testsubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")

## Merge train and test data

traindata <- cbind(trainsubjects, ytrain, xtrain)
testdata <- cbind(testsubjects, ytest, xtest)
mydata <- rbind(traindata, testdata)
names(mydata) <- c("Subject", "Activity", as.character(features$V2))

## Extract mean and std columns

means <- grep("mean()", as.character(names(mydata)))
stds <- grep("std()", as.character(names(mydata)))
index <- sort(c(means, stds))
mydata2 <- mydata[,c(1,2,index)]

#Give descriptive activity names

actNames <- c()
for (i in mydata2$Activity) {
    if (i == 1) {
      actNames <- c(actNames, "Walking")
    }
    else if (i == 2) {
      actNames <- c(actNames, "Walking Upstairs")
    }
    else if (i == 3) {
      actNames <- c(actNames, "Walking Downstairs")
    }
    else if (i == 4) {
      actNames <- c(actNames, "Sitting")
    }
    else if (i == 5) {
      actNames <- c(actNames, "Standing")
    }
    else if (i == 6) {
      actNames <- c(actNames, "Laying")
    }
}

mydata2 <- mutate(mydata2, Activity = actNames)

##Create dataset with average of each variable for each subject for each activity

#Define function that finds mean for each variable for a given Subject and Activity
Means <- function(data, subject, activity) {
  bySubject <- filter(data, Subject == subject, Activity == activity)
  means <- c()
  for (i in 3:81) {
    temp <- mean(bySubject[,i])
    means <- cbind(means, temp)
  }
  means
}

#Use Means function to calculate variable means for each Subject and Activity, and bind them together into the final tidy dataset
actLabels <- c("Walking", "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying")
finaldata <- data.frame()

for (sub in 1:30) {
  subMeans <- c()
  for (act in actLabels) {
    actMeans <- Means(mydata2, sub, act)
    subMeans <- rbind(subMeans, actMeans)
  }
  subMeans
  data <- cbind(c(sub, sub, sub, sub, sub, sub), actLabels, subMeans)
  finaldata <- rbind(finaldata, data)
}

names(finaldata) <- names(mydata2)
write.table(finaldata, file = "TidyDataFinal.txt")