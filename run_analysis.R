#############################################
############################################




###########function unzip file if exist 
##if dont exist downlod file 
extractFile <- function(nameFile = "dataset.zip"){
    print("check if file exist")
    if (!file.exists(nameFile)) {
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        tmp_file <- nameFile
        download.file(url,tmp_file, method="curl")
    }
    print(paste("unzip file ",nameFile,"   ...."))
    unzip(nameFile)
}

# Run the analysis -> creates -> "tiny.txt"

# Reads the base sets (files with begining by X) in an optimal way
#
#
#
readBaseSet <- function(filePath, filteredFeatures, features) {
    print("Read base set file")
    cols_widths <- rep(-16, length(features))
    cols_widths[filteredFeatures] <- 16
    rawSet <- read.fwf(
        file=filePath,
        widths=cols_widths,
        col.names=features[filteredFeatures])
}

# Reads an additional file (other than the base sets). Used for subjects and labels.
# * dataDirectoryNme: directory of data
# * filePath: relative path of the file. For instance if its value is "subject" it
#   will read "UCI HAR Dataset/test/subject_test.txt" and
# "UCI HAR Dataset/train/subject_train.txt", and merge them
readAdditionalFile <- function(dataDirectoryNme, filePath) {
    print("Read addictional files")
    filePathTest <- paste(dataDirectoryNme, "/test/", filePath, "_test.txt", sep="")
    filePathTrain <- paste(dataDirectoryNme, "/train/", filePath, "_train.txt", sep="")
    data <- c(read.table(filePathTest)[,"V1"], read.table(filePathTrain)[,"V1"])
    data
}

# Correct a feature name - makes it nicer for dataframe columns (removes parentheses)
# because otherwise they are transformed to dots.
# * featureName: name of the feature
getFeatureName <- function(featureName) {
    print("get features")
    featureName <- gsub("\\(", "", featureName)
    featureName <- gsub("\\)", "", featureName)
    featureName
}

##return dataset fatures
# Adding main data files (X_train and X_test)
readDataSetFatures <-function(dataDirectoryNme){
    print("Read data set ")
    featuresFilePath <- paste(dataDirectoryNme, "/features.txt", sep="")
    features <- read.table(featuresFilePath)[,"V2"]
    filteredFeatures <- sort(union(grep("mean\\(\\)", features), grep("std\\(\\)", features)))
    features <- getFeatureName(features)
    dataSet <- readBaseSet(paste(dataDirectoryNme, "/test/X_test.txt", sep=""), filteredFeatures, features)
    dataSet <- rbind(dataSet, readBaseSet(paste(dataDirectoryNme, "/train/X_train.txt", sep=""), filteredFeatures, features))
    ##return dataset
     dataSet
}


# Read sets and returns a complete sets
# * dataDirectoryNme: directory of data
returnDataSet <- function(dataDirectoryNme) {
   
    dataSet <- readDataSetFatures(dataDirectoryNme)
    # Adding subjects
    dataSet$subject <- readAdditionalFile("UCI HAR Dataset", "subject")
    
    # Adding activities
    activitiesFilePath <- paste(dataDirectoryNme, "/activity_labels.txt", sep="")
    activities <- read.table(activitiesFilePath)[,"V2"]
    dataSet$activity <- activities[readAdditionalFile("UCI HAR Dataset", "y")]
    print("Return data set ")
    dataSet
}

# From sets, creates the tidy dataset  summary
#  -execute returnDataSet @seer returnDataSet
#  -genetete set x
# * dataDirectoryNme: directory of data
createDataSunary <- function(dataDirectoryNme) {
    print("Create data sunary ")
    dataSets <- returnDataSet(dataDirectoryNme)
    ##genetete set x
    sets_x <- dataSets[,seq(1, length(names(dataSets)) - 2)]
    ##Split by Factors
    summary_by <- by(sets_x,paste(dataSets$subject, dataSets$activity, sep="_"), FUN=colMeans)
    ##Makes one data.table from a list of many
    summary <- do.call(rbind, summary_by)
    ##return sunary 
    summary
}

##extract or download file 
#getwd()
#list.files()

#getwd()
#setwd("/path/to/Getting-and-Cleaning-Data-ActivityRecognition")
#list.files()
atualDir <- getwd()
list.files()


##requeri path 
packages <- c("dplyr", "plyr","data.table")
sapply(packages, require, character.only = TRUE, quietly = TRUE)


##extract file 
extractFile()
directoryName <- "UCI HAR Dataset"

summary <- createDataSunary(directoryName)
View(summary)
write.table(summary, "tidy.txt")
    
