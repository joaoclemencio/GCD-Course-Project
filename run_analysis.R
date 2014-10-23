require(reshape2)

# If the source data is not present in the working directory, download and unzip the files, and remove the downloaded file
if(!(file.exists("UCI HAR Dataset"))){
    download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "dataset.zip")
    unzip("dataset.zip")
    file.remove("dataset.zip")
}

# Read the activity labels to later assign them to values in the tidy data set
activities <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# Read the features labels to later be used as column names for the table read
features <- read.table("UCI HAR Dataset/features.txt")[,2]
# Filter the features by mean and std only, as required; droplevels is used since selected.features is a factor
# selected.feature.indexes will be used as a column filter for the data tables (filter only means and stds)
selected.feature.indexes <- grep("mean\\(\\)|std\\(\\)", features)

# Could possibly be improved by filtering by columns on read, which is possible via data.table's fread
# colClasses assigned to numeric to improve performance; assumed from data description
test.data <- read.table("UCI HAR Dataset/test/X_test.txt", header = F, colClasses = "numeric", col.names = as.character(features))
test.data <- test.data[,selected.feature.indexes]
train.data <- read.table("UCI HAR Dataset/train/X_train.txt", header = F, colClasses = "numeric", col.names = as.character(features))
train.data <- train.data[,selected.feature.indexes]

# Read subject data directly into the two tables via the same method as before
# Note the $Subject at the end. If not applied, it will pass a dataframe to the dataframe, which will produce errors in rbind
test.data$Subject <- read.table("UCI HAR Dataset/test/subject_test.txt", header = F, colClasses = "numeric", col.names = "Subject")$Subject
train.data$Subject <- read.table("UCI HAR Dataset/train/subject_train.txt", header = F, colClasses = "numeric", col.names = "Subject")$Subject

# Activities read via the same method as before
test.activities <- read.table("UCI HAR Dataset/test/y_test.txt", header = F, colClasses = "numeric", col.names = "ActivityCode")
train.activities <- read.table("UCI HAR Dataset/train/y_train.txt", header = F, colClasses = "numeric", col.names = "ActivityCode")

# Translate activity codes to activity names in the main tables
# This could've been done in the previous line, but it's easier to read like this.
test.data$Activity <- activities[test.activities$ActivityCode]
train.data$Activity <- activities[train.activities$ActivityCode]

# Merge the two tables
all.data <- rbind(test.data, train.data)

# Clean up the data.frame names
names(all.data) <- c(as.character(features[selected.feature.indexes]), "Subject", "Activity")
names(all.data) <- gsub("BodyBody", "Body", names(all.data))
names(all.data) <- gsub("Mag-", "-Mag-", names(all.data))

### Quick 'break' to categorize the names in all.data ###

# For later categorization (better do it now before the melt, memory-wise)
vars <- as.character(names(all.data)[-grep("Subject|Activity", names(all.data))])

# Garbage collection
rm(list = setdiff(ls(), c("all.data", "vars")))

# Split the variables into 3 components: Measurement, Direction and Function
vars.list <- strsplit(vars, "-")
# Turn the list into a data.frame...
vars.list <- as.data.frame(vars.list)
# ... and transpose it to make it look nice
vars.list <- as.data.frame(t(vars.list), row.names = 1:length(vars))
# Now join this with the variable names, so later we can relate them with the main table (which we'll transpose later)
vars <- cbind(vars, vars.list)
# Garbage collection...
rm(vars.list)

# V1 actually has 2 values, Measure Type (frequency or time) and Measurement (BodyAcc, GravityAcc, etc)
# So we create two new columns distinguishing them and remove the original V1
vars$MeasureType <- substr(vars$V1, 1, 1)
vars$Measurement <- substr(vars$V1, 2, 20)
vars$V1 <- NULL

# There's an issue here because where Magnitude was measured the Function (mean or std) shows on V3, and in the rest it is on V2
# So we create each column with an ifelse check
vars$Direction <- ifelse(vars$V2=="Mag", as.character(vars$V2), as.character(vars$V3))
vars$Function <- ifelse(vars$V2=="Mag", as.character(vars$V3), as.character(vars$V2))
# And here we just clean up the function names
vars$Function <- gsub("\\(\\)", "", vars$Function)
# And garbage collect
vars$V2 <- NULL
vars$V3 <- NULL
vars$V4 <- NULL

# Since we've got so much repeated names now, they'll be easier to manipulate if factored
# So we turn all columns into factors
for(i in names(vars)){
    vars[[i]] <- as.factor(vars[[i]])
}

# Now it's easy to rename f and t to Frequency and Time
levels(vars$MeasureType) = c("Frequency", "Time")

### And back to the actual data ###

# Melt all data from wide to long form (aka pivot by Subject and Activity)
all.data <- melt(all.data, id.vars = c("Subject", "Activity"))

# And finally we create a final.data data.frame by merging the original data with our new classification
final.data <- merge.data.frame(x = all.data, y = vars, by.x = "variable", by.y = "vars", all.x = T)

# Garbage collection; remove all but the final list
rm(list = setdiff(ls(), "final.data"))

# We don't need the variable column anymore, everything is classified
final.data$variable <- NULL

# Reorder the columns to look a bit better
final.data <- final.data[,c(1:2, 4:7, 3)]

# Why not factorize Subject and Activity as well....
final.data$Subject <- as.factor(final.data$Subject)
final.data$Activity <- as.factor(final.data$Activity)

# Finally we calculate the means of all measurement configurations
final.data.means <- aggregate(value ~ Subject + Activity + MeasureType + Measurement, data = final.data, mean)
names(final.data.means) <- c(names(final.data.means)[1:4], "Mean")

# And export to tidy.dataset.txt
write.table(final.data.means, "tidy.dataset.txt", row.names = F)
