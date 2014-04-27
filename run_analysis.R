# you must be sure to be in the directory where the project
# data exists; where the "UCI HAR Dataset" directory lives

# read in the data
test<-read.table("UCI HAR Dataset/test/x_test.txt")
train<-read.table("UCI HAR Dataset/train/x_train.txt")

#check if the col names are a match
intersect(names(test),names(train))
# I visually inspected that there were 561 variable names
# - ok, I really didn't get it at this point! so I read the manual
# and read the forums and figured it out.....

#merge the data - really we are concatenating it
allData<-rbind(test,train)

# read in the separate test subjects and test activities:

test_activity<-read.table("UCI HAR Dataset/test/y_test.txt")
train_activity<-read.table("UCI HAR Dataset/train/y_train.txt")
subject_test<-read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train<-read.table("UCI HAR Dataset/train/subject_train.txt")

# concatenate them

subjects<-rbind(subject_test,subject_train)
activities<-rbind(test_activity,train_activity)

# read in the activity labels and the features labels
labels<-read.table("UCI HAR Dataset/activity_labels.txt")
feature_labels<-read.table("UCI HAR Dataset/features.txt")

# Extract the mean and std columns
# I'm gonna take all text with the string mean or std and make
# it case insensitive by making all the strings lowercase

#grep string:
greptoMatch<-c("mean","std")

# get the indices of the variables I want
# the value=FALSE gives the indices, the paste() concatenates
# the "mean" and "std", and the tolower() causes all variable
# names to be in lower case
varIdx<-unique (grep(paste(greptoMatch,collapse="|"),
                     tolower(feature_labels$V2), value=FALSE))

# now take those indices and subset the data
tidyAllData<-allData[,varIdx]

# I'm also gonna need those col names so I'll use the indices
# to get them back without having the lower case conversion
vars<-feature_labels$V2[varIdx]

# now we need to get the activity names instead of the number
activities_pretty<-labels$V2[activities$V1]

# now bind the columns together
tidyData<-cbind(subjects,activities_pretty,tidyAllData)

# label the columns:
colnames(tidyData)<-c("Subject","Activity",as.character(vars))

# now split the data by subject:
spl_sub<-split(tidyData,tidyData$Subject)

# and use sapply to get the means for all variables
# grouped by subject
subject_means<-sapply(spl_sub,function(x) colMeans(x[,as.character(vars)]))

# Do the same but split the data on Actvity:
spl_act<-split(tidyData,tidyData$Activity)
activity_means<-sapply(spl_act,function(x) colMeans(x[,as.character(vars)]))

# concatenate:
tidyMeans<-cbind(activity_means,subject_means)

#write it out to disk
write.table(tidyData, file="./tidydata.txt", sep="\t")
write.table(tidyMeans, file="./tidymeans.txt", sep="\t")
