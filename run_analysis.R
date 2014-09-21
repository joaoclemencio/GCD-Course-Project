#require(data.table)
require(reshape2)

if(!(file.exists("UCI HAR Dataset"))){
    download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "dataset.zip")
    unzip("dataset.zip")
    file.remove("dataset.zip")
}

activities <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

features <- read.table("UCI HAR Dataset/features.txt")[,2]
selected.features <- features[grep("mean\\(\\)|std\\(\\)", features)]
selected.features <- droplevels(selected.features)

test.data <- read.table("UCI HAR Dataset/test/X_test.txt", header = F, colClasses = "numeric", col.names = as.character(features))
test.data <- test.data[,selected.features]
train.data <- read.table("UCI HAR Dataset/train/X_train.txt", header = F, colClasses = "numeric", col.names = as.character(features))
train.data <- train.data[,selected.features]

test.subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", header = F, colClasses = "numeric", col.names = "Subject")
train.subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", header = F, colClasses = "numeric", col.names = "Subject")
test.data$Subject <- test.subjects$Subject
train.data$Subject <- train.subjects$Subject

test.activities <- read.table("UCI HAR Dataset/test/y_test.txt", header = F, colClasses = "numeric", col.names = "ActivityCode")
train.activities <- read.table("UCI HAR Dataset/train/y_train.txt", header = F, colClasses = "numeric", col.names = "ActivityCode")
test.data$Activity <- activities[test.activities$ActivityCode]
train.data$Activity <- activities[train.activities$ActivityCode]

all.data <- rbind(test.data, train.data)
names(all.data) <- c(as.character(selected.features), "Subject", "Activity")

rm(list = setdiff(ls(), "all.data"))

all.data <- melt(all.data, id.vars = c("Subject", "Activity"))

#Variable categorization
all.data$variable <- gsub("BodyBody", "Body", all.data$variable)
all.data$variable <- gsub("Mag-", "-Mag-", all.data$variable)

vars <- unique(all.data$variable)

vars.list <- strsplit(vars, "-")

vars.list.df <- as.data.frame(matrix(unlist(vars.list), nrow = length(vars), byrow = T))

vars <- cbind(vars, vars.list.df)

rm(vars.list, vars.list.df)

vars$MeasureType <- substr(vars$V1, 1, 1)
vars$Measurement <- substr(vars$V1, 2, 20)
vars$V1 <- NULL

vars$Direction <- ifelse(vars$V2=="Mag", as.character(vars$V2), as.character(vars$V3))
vars$Function <- ifelse(vars$V2=="Mag", as.character(vars$V3), as.character(vars$V2))

vars$Function <- gsub("\\(\\)", "", vars$Function)

vars$V2 <- NULL
vars$V3 <- NULL
vars$V4 <- NULL

for(i in names(vars)){
    vars[[i]] <- as.factor(vars[[i]])
}

levels(vars$MeasureType) = c("Frequency", "Time")

final.data <- merge.data.frame(x = all.data, y = vars, by.x = "variable", by.y = "vars", all.x = T)
rm(list = setdiff(ls(), "final.data"))

final.data$variable <- NULL

final.data <- final.data[,c(1:2, 4:7, 3)]

final.data$Subject <- as.factor(final.data$Subject)

final.data2 <- aggregate(value ~ Subject + Activity + MeasureType + Measurement, data = final.data, mean)

