#  USAGE:  source("./run_analysis.R")

library(dplyr) #nothing else is needed

#initialization of global variables.
dataInDir <- "./"
dataOutDir <- "./"
activityNamesFile <- "activity_labels.txt"
featureNamesFile <- "features.txt"
subjectFilePrefix <- "subject_"
activityFilePrefix <- "y_"
actualDataPrefix <- "X_"
MAXROWS <- -1  #this can be set to 100 to do quick experiments


#this function reads the two datasets (training and test) assuming that they have been downloaded, unzipped, and
#placed in the correct working directory. All other data description files must also be kept in
#the working diectory.
#RAW DATA IN THE INITIAL DATA SET IS CONSISTENTLY IGNORED.  WE JUST WORK WITH train AND test SETS.
ReadData <- function(dataInDir, dataset, activityNameFile, featureNameFile, 
         subjectFilePrefix, activityFilePrefix, actualDataPrefix,
	 maxrows = -1) {
	 File <- paste(c(dataInDir, actualDataPrefix, dataset, ".txt"), collapse="")
	 data <- read.table(File, nrows = maxrows, sep = "", header = F)#data
	 File <- paste(c(dataInDir, featureNamesFile), collapse="")
         features <- read.table(File, sep = "", header = F)#column names
	 File <- paste(c(dataInDir, activityNamesFile), collapse="")
         actnames <- read.table(File, sep = "", header = F)[2]#activities (character vectors)
	 File <- paste(c(dataInDir, activityFilePrefix, dataset, ".txt"), collapse="")         
         actcodes <- read.table(File, sep = "", header = F, nrows = maxrows)#activity codes (integers)
	 File <- paste(c(dataInDir, subjectFilePrefix, dataset, ".txt"), collapse="")         
         subjects <- read.table(File, sep = "", header = F, nrows = maxrows)#human subject ids (integers)
         rows <- dim(data)[1]
         cols <- dim(data)[2]
         actcodes <- lapply(actcodes, FUN = function(x) {actnames$V2[x]})
         if (
             (dim(features)[1] != cols) ||
             (length(subjects$V1) != rows) ||
             (length(actcodes$V1) != rows) ||
             (FALSE)
             ) {
	       #basic sanity check.  If we fail here, we will just not proceed.
               return(c(length(subjects$V1), rows, dim(features)[1], length(subjects$V1), cols, length(actcodes)))
         }
         data["activity"] = actcodes
         data["subject"] = subjects$V1
         data["dataset"] <- rep(dataset, dim(data)[1])
         names(data) <- c(t(features[2]), "activity", "subject", "dataset")
         data #now we have a data frame which has the original columns plus activities, subject and training/test annotation.
}



trn <- ReadData(dataInDir, "train", activityNamesFile, featureNamesFile, 
    	        subjectFilePrefix, activityFilePrefix, actualDataPrefix,
                MAXROWS); #read the training set

tst <- ReadData(dataInDir, "test", activityNamesFile, featureNamesFile, 
    	        subjectFilePrefix, activityFilePrefix, actualDataPrefix,
                MAXROWS); #read the test set.

combined <- rbind(trn, tst) #stack them one over other.
n = names(tst)

recols<-combined[unique(c("activity", "subject", 
                          c(grep("mean", n, value=TRUE), 
                            grep("Mean", n, value=TRUE), 
                            grep("std", n, value=TRUE))))] #get rid of columns that do not contain mean, and std. 

tabdf <- tbl_df(recols)#change to a form amenable for tidy processing.
savednames <- names(tabdf)#remember names.
num <- 3:length(savednames)
num <- sapply(num, FUN=function(x) {paste("V", x, sep="")})
num <- c(savednames[1:2], num)#We got rid of train/test marking as well.
newnames <- num #create names that are not messy. (we will get rid of these names later).
names(tabdf) <- newnames
grped <- group_by(tabdf, activity, subject)#our artificial names work better.

#we will programmatically created the command that does groupby and mean and execute it using R's eval command.
partcmd = paste(sapply(3:length(newnames), FUN=function(x) {paste(newnames[x], "=mean(", newnames[x], ")", sep="")}), sep="", collapse=",")
fullcmd<-paste("finaldata <- summarize(grped,", partcmd, ")", sep="")
eval(parse(text=fullcmd))

#Just so our column names are different from the original, we prepended AVG to all column names.
#BUT TO MAINTAIN CONSISTENCY WITH THE ORIGINAL NAMES, WE DID NOT **intentionally** ALTER ANYTHING ELSE.
q<-sapply(1:length(savednames), FUN=function(x) {if (x < 3) savednames[x] else paste("AVG", savednames[x], sep="")})
#now we set the name to their modified versions.
names(finaldata) <- q

OPFile <- paste(c(dataOutDir, "finaldata.txt"), collapse="")         
write.table(finaldata, file=OPFile, row.names=FALSE)
#final data is in CSV format and has a header row.
print(paste(c("All is well that ends well.  An object of size ",
		               paste(dim(finaldata), collapse="x"),
			       " written in ", 
			       OPFile, "."), collapse=""), quote=FALSE)