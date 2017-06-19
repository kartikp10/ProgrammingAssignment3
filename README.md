## ProgrammingAssignment3
## This file explains how the script run_analysis.R works 
Course project for "Getting and Cleaning Data"
==================================================================
Information About the data set
==================================================================
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:
======================================

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

=========================================
Explanation for how the script works
=========================================
- Merge the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement.
These 2 steps were done together. First we import 2 libraries we will be using in the script: data.table & reshape2
Load activity labels and features into R using fread function from data.table. This file has activity names and numbers associated with each activity.
Rename it's columns as classLabels and activityName.
Similarly, read the features file into R which contains feature names and numbers associated with each feature.
Rename it'scolumns to featureNum and featureNames.
Subset feature names to select only mean and standard deviation values by using regular expression "(mean|std)\\(\\)"
Remove parentheses so that column names don't look like functions.

Now load Test X and Train X data sets which have values measured from activities.
Subset them with requiredCols so that only mean and std deviation columns are remaining.
Now, assign the names of the required features to these datasets.
Assigning requiredFeatures as column names to trainData 
>names(trainData) <- requiredFeatures
Now create 2 new vectors for each of the datasets, train and test, called t---Labels and t---Subjects
>trainLabels <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("trainLabel"))
>trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
Now bind these 2 new columns 
>trainData <- cbind(trainSubjects, trainLabels, trainData)

For rbind to work testLabel and trainLabel will need to have the same column name therefore, change column names to actionLabel
data.table::setnames(trainData, old = "trainLabel", new = "actionLabel")
data.table::setnames(testData, old = "testLabel", new = "actionLabel")

Merge using rbind
merged <- rbind(trainData, testData)

-Uses descriptive activity names to name the activities in the data set
-Appropriately labels the data set with descriptive variable names.

Convert classlabels to activity names in activity label 
>merged[["actionLabel"]] <- factor(x = merged[,actionLabel], levels = activityLabels$classLabels
                                  , labels = activityLabels$activityName)

- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Finally creating an independent dataset with the average of each variable for each activity and each subject.

Hence converting the 30 subjects to factors
Melt the table to display each subjectNum and each actionLabel with all readings as variables
Now averaging the values for all readings of each action per subject 
newdata <- reshape2::dcast(data = newdata, formula = SubjectNum + actionLabel ~variable, fun.aggregate = mean)
Hence we can see the resulting change using the dim() function:
> dim(merged)
[1] 10299    68
> dim(newdata)
[1] 180  68

Save to a new file
write.table(x = newdata ,file = "tidy data.txt", row.names = F)
-To read in this new file please use:
new_file <- read.table(file = "tidy data.txt", header =  T)

