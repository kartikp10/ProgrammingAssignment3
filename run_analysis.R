# Load Packages and get the Data

packages <- c("data.table", "reshape2")
sapply(packages, library, character.only=TRUE)

path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "data.zip"))
unzip(zipfile = "data.zip")

# Load activity labels and features

# Renaming columns
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))

# Renaming columns
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("featureNum", "featureNames"))

# Subsetting feature names to select only mean and standard deviation values
# by using regular expression
requiredCols <- grepl("(mean|std)\\(\\)", features$featureName)
requiredFeatures<- features$featureName[requiredCols]


# Removing parenthesis so that column names don't look like functions
requiredFeatures <- gsub('[()]', '', requiredFeatures)

# Loading Train datasets

trainData <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))
# Subsetting train data with requiredcols to select mean and std measurements
trainData <- trainData[,requiredCols, with = FALSE]

# Assigning requiredFeatures as column names to trainData 
names(trainData) <- requiredFeatures

trainLabels <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("trainLabel"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
# adding subject label and train label columns to trainData 
trainData <- cbind(trainSubjects, trainLabels, trainData)

# repeating exact same process for Test datasets
testData <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))
testData <- testData[,requiredCols, with = FALSE]
names(testData) <- requiredFeatures
testLabels <- fread(file.path(path, "UCI HAR Dataset/test/y_test.txt")
                     , col.names = c("testLabel"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                       , col.names = c("SubjectNum"))
testData <- cbind(testSubjects, testLabels, testData)

# for rbind to work testLabel and trainLabel will need to have the same column name
# therefore, changing column names to actionLabel
data.table::setnames(trainData, old = "trainLabel", new = "actionLabel")
data.table::setnames(testData, old = "testLabel", new = "actionLabel")

# Combining using rbind
merged <- rbind(trainData, testData)

# Converting classlabels to activity names in activity label 
merged[["actionLabel"]] <- factor(x = merged[,actionLabel], levels = activityLabels$classLabels
                                  , labels = activityLabels$activityName)

# Finally creating an independent dataset with
# the average of each variable for each activity and each subject.

# hence converting the 30 subjects to factors
merged$SubjectNum <- as.factor(merged$SubjectNum)
# melting the table to display each subjectNum and each actionLabel with all readings as variables
newdata <- reshape2::melt(data = merged, id = c("SubjectNum", "actionLabel"))
# Now averaging the values for all readings of each action per subject 
newdata <- reshape2::dcast(data = newdata, formula = SubjectNum + actionLabel ~variable, fun.aggregate = mean)
# Hence we can see the resulting change using the dim() function:
# > dim(merged)
# [1] 10299    68
# > dim(newdata)
# [1] 180  68

# Saving to a new file
write.table(x = newdata ,file = "tidy data.txt", row.names = F)
# To read in this new file please use:
# new_file <- read.table(file = "tidy data.txt", header =  T)
