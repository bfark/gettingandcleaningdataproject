How it works
=============================

To run the run_analysis.R script, you must set your R environment
to be in the directory where you unzipped the project data. In other
words, you must have the directory "UCI HAR Dataset" in your current
working directory.

By running the script, the test and training sets will be merged and 
the columns for Subject and Activity will be prepended. Only the variables
with any kind of mean or std in them will be in the data. The entire data
set will be written back to your working directory with the name tidydata.txt
and the means of all the variables grouped by Subject as well as by
activity will be written to your working directory with the name tidymeans.txt
