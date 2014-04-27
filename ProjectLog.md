# This is a Markdown file that I used to log the steps of my work

First step was to get the data. I might have cheated here, but I simply
clicked on the given link to the zip file and saved it to my project directory
and then extracted the files.
The data extracted cleanly into a "test" and a "train" directory. Part of the
assignment is to merge the data from these two directories.

I saw that all of the data were in .txt files so I decided to load one to see 
what would happen:
setwd("UCI HAR Dataset/test")
dir()
this showed me the data in the test directory
test<-read.table("y_test.txt")
head(test)
showed me one column of data labeled "V1". This was not interesting, so I read 
the manual! Actually, I read the document at the link provided.

It became clear that I needed to load the train/X_train.txt file and the 
test/X_test.txt file and merge the two.

Go back to the main directory:
setwd("..")
get the test file:
test<-read.table("UCI HAR Dataset/test/x_test.txt")
train<-read.table("UCI HAR Dataset/train/x_train.txt")

looking into my Environment I see there is a lot of data:
test - 2947 obs. of 561 variables
train - 7352 obs of 561 variables

I wanted to see if the variable names match so I ran the intersect command.
The command came back with 561 variable names; they match.
I tried a merge with the merge command, but it came back with 0 rows!!
I realized a merge will merge rows in one data set with rows in another.
I really just want to concatenate the data sets. I want to use rbind.

allData<-rbind(test,train)

Ok, I managed to concatenate, but now I'm starting to suspect I don't have 
variable names and that is why my labels seemed to match up! Also, I'm 
starting to believe that I need to cbind with the y-values which contains
the activities. Also, there is the Test Subject file and Train subject file
that I'm gonna need to cbind as well

I read in the separate test subjects and test activities as such:

test_activity<-read.table("UCI HAR Dataset/test/y_test.txt")
train_activity<-read.table("UCI HAR Dataset/train/y_train.txt")
subject_test<-read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train<-read.table("UCI HAR Dataset/train/subject_train.txt")

I also read in the activity labels and the features labels
labels<-read.table("UCI HAR Dataset/activity_labels.txt")
feature_labels<-read.table("UCI HAR Dataset/features.txt")

Before cbinding the subjects and the activities, I need to concatenate them
subjects<-rbind(subject_test,subject_train)
activities<-rbind(test_activity,train_activity)

now I need to extract the mean and std columns from the main dataset.
According to the forums, toMatch <- c("mean()[-]", "std()[-]") is a good start
After some playing with grep I decided to search for all text with 'mean'
or 'std' and to change the variable names to lower case with the tolower()
funciton, and take the indices of those var names:
varIdx<-unique (grep(paste(greptoMatch,collapse="|"),
                tolower(feature_labels$V2), value=FALSE))
This gives me 86 total variables.
Now I tidy up the main data:
tidyAllData<-<-allData[,varIdx]

I'm also gonna need those col names so I'll use the indices to get them back
without having the lower case conversion
vars<-feature_labels$V2[varIdx]

Now I need to convert the activity to a real name of an activity! My activities
are in the 'activities' variable and I want the label of the index into
the labels variable I created.
activities_pretty<-labels$V2[activities$V1]

Now I need to bind the columns for the subject and activity to the data:
tidyData<-cbind(subjects,activities_pretty,tidyAllData)

Now I just need the column names:
colnames(tidyData)<-c("Subject","Activity",as.character(vars))

Done! -- nope - now I need a second tidy data set with the average
of each variable for each activity and each subject. Holy cow. seems like
split and lappy or sapply will come in handy here

I played with split to split the dataset according to factors and it worked
great.
I split on each subject with:
spl_sub<-split(tidyData,tidyData$Subject)
I used sapply to get the means for the variables as follows:
subject_means<-sapply(spl_sub,function(x) colMeans(x[,as.character(vars)]))

Now I need to do the same but split the data on Actvity:
spl_act<-split(tidyData,tidyData$Activity)
activity_means<-sapply(spl_act,function(x) colMeans(x[,as.character(vars)]))

Finally, concatenate these two, but just append the new cols
tidyMeans<-cbind(activity_means,subject_means)

This gives me a matrix, not sure that is what I want, but it seems ok
got to get this into a txt file now...


#write it out to disk
write.table(tidyData, file="./tidydata.txt", sep="\t")
write.table(tidyMeans, file="./tidymeans.txt", sep="\t")
