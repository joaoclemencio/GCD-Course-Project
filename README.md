GCD-Course-Project
==================

This is a submission for the Course Project of the Getting and Cleaning Data course of the John Hopkins University 'Data Science Specialization' in Coursera.

The following is the project description and objectives:

> The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

> One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

> http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

> Here are the data for the project: 

> https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

> You should create one R script called run_analysis.R that does the following. 
> 1. Merges the training and the test sets to create one data set.
> 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
> 3. Uses descriptive activity names to name the activities in the data set
> 4. Appropriately labels the data set with descriptive variable names. 
> 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

> Good luck!

Resulting Dataset
---

The resulting dataset has the following configuration:

* 1620 observations
* 5 Variables:
    * __Subject__: Factor w/ 30 levels (1-30)
    * __Activity__: Factor w/ 6 levels (Laying, Sitting, etc.)
    * __MeasureType__: Factor w/ 2 levels (Frequency; Time)
    * __Measurement__: Factor w/ 5 levels (BodyAcc, BodyAccJerk, etc.)
    * __Mean__: Numeric

Method
---

The run_analysis.R file has almost all lines commented to maximize code understanding. Here is a summarized description of the process:

1. The working directory should have the "UCI HAR Dataset" folder. If this is not the case, the script will download the zipped file, extract the directory and delete the zipped file
2. Read "activity_labels.txt"
3. Read "features.txt"
4. Filter *features* by mean and std
5. Read *test* and *train* data
6. Filter both by the columns corresponding to means and standard deviations
7. Read and append Subject and Activity information to both *train* and *test*
8. Merge tables and clean up column names
9. Before the table is melted, we split the measurements by 4 categorizations: Measurement Type, measurement, Direction and Function
10. Melt the table and append the categorizations
11. Clean up the final table with all the values
12. Aggregate and export the final dataset (final table with non-aggregated values is also kept in memory for further processing)
