# TidyData
Tidy Data Project for Coursera
Repository created on 3/12/15
Add more material to this file offline.

#Program Information

##USAGE
source("./run_analysis.R")
**After you setwd to the directory that contains the above file**.


##MORE DESCRIPTION
This program produces the Tidy Data Set for the Coursera/JH Getting and Cleaning Data course project.

As long as your R installation is current around March 2015,  you can run this R code and produce the tidy dataset.  Here are the steps:

0.  If you do not have the dplyr library, from R do install.packages("dplyr")

1.  Unzip tidyproject.zip in the directory of your choice and traverse
to the directory X where you see the file run_analysis.R.

2.  In R and change your setwd(X), where X comes from the previous step.

3.  All files needed by the R script are also in the directory X.

4.  source("./run_analysis.R")

5.  After about 1 minute of waiting, you will see a recently created file called finaldata.txt in X.  This is the tidy file that you need.

6.  A true copy of it is stored in finaldata.txt.TRUECOPY (to avoid erasing of the original file.).

7.  The codebook describes the content of finaldata.txt.

8.  The raw samsung data was ignored and only the intermediate data described was used.

