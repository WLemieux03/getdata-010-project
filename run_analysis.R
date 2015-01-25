

##      The main function for the file. Executes all the other subfunctions. 
##
##      DS_path     the path to the root of the data set (i.e. location of the README.txt file).
##      ...         the arguments to restrain the variables (function select_variables). If 
##                  none is passed, a warning will be thrown and the whole data frame DF is 
##                  returned. "Labels" and "Subjects" are automatically added to this list.
##      whole_set   boolean value. TRUE if whole dataset is required. Results in a warning.
tidy_dataset <- function(DS_path, ..., whole_set=F){
    #   This loads the data from the files and assembles them together.
    data <- assemble(DS_path)
    
    #   This removes some variables (columns) from the data frame. 
    data <- select_variables(data, ..., whole_set=whole_set)
    
    #   This replaces the activity labels with actual names. 
    data <- set_act_names(data, DS_path)
    
    #   This renames the variables to human-readable values.
    data <- rename_var(data)
    
    #
    summary <- summarise(data)
    
    #   This creates the file containing the final dataset
    write.table(summary, file="tidy_data.txt", row.name=FALSE)
}

##      The function loads and merges all parts of the data set from three files: the main data 
##      (X_<...>), the label for the activity performed (y_<...>), and the subject numbers 
##      (subject_<...>). 
##
##      set         the variable is either the "test" or "train" set
##      DS_path     the path to the root of the data set (i.e. location of the README.txt file). 
load_set <- function(set, DS_path){
    
    #   The block computes the path to each file of the dataset (X_path, Y_path, S_path) and 
    #   stores them in a list, all_path. 
    X_path <- file.path(DS_path, set, paste("X_", set, ".txt", sep=""))
    Y_path <- file.path(DS_path, set, paste("y_", set, ".txt", sep=""))
    S_path <- file.path(DS_path, set, paste("subject_", set, ".txt", sep=""))
    all_path <- c(X_path, Y_path, S_path)
    
    #   The block loads all datasets in temporary variable .list. The three parts are then 
    #   merged column-wise. The resulting dataframe is returned. 
    .list <- lapply(all_path, read.table)
    all_data <- do.call(cbind, .list)
}


##      Loads the test and train subsets in memory from the file. Also loads the supplementary 
##      information from Y_<...>.txt and subject_<...>.txt for each subset. The function then 
##      merges all these data together in a single data frame. 
##
##      DS_path     the path to the root of the data set (i.e. location of the README.txt file).
assemble <- function(DS_path){
    
    var_names <- get_var_names(DS_path)
    test <- load_set("test", DS_path=DS_path)
    colnames(test) <- var_names
    train <- load_set("train", DS_path=DS_path)
    colnames(train) <- var_names
    
    all_subj <- rbind(test, train)
}


##      Gets the variable names from the features.txt file and appends "Labels" and "Subject" 
##      for the added activity labels and subject number, respectively. 
##
##      DS_path     the path to the root of the data set (i.e. location of the README.txt file).
get_var_names <- function(DS_path){
    #   loads in DF_names the reported names for the dataset variables.
    DF_names <- read.table(file.path(DS_path, "features.txt"))
    
    #   initiates an empty list to receive the names
    list_names <- numeric(dim(DF_names)[1])
    
    #   for each element of the second column of DF_names data frame, makes the element a 
    #   character and transfers it to the list (in corresponding position).
    for (i in seq(1,dim(DF_names)[1])){
        list_names[i] <- as.character(DF_names[i,2])
    }
    
    #   adds two names to the list for the complementary information loaded with the dataset.
    c(list_names, "Labels", "Subject")
}


##      select_variables subsets a data frame based on the variable names. It can take any 
##      number of arguments. The data frame must be specified to DF. 
##
##      DF          the data frame to be subsetted.
##      ...         the arguments to be matched. If none is passed, "mean" and "std" will be 
##                  used. "Labels" and "Subjects" are automatically added to this list.
##      whole_set   boolean value. TRUE if whole dataset is required. Results in a warning.
select_variables <- function(DF, ..., whole_set){
    #   Stores the ... arguments as a list.
    input <- list(...)
    
    #   if no arguments were passed, sets the default values "mean" and "std" instead
    if (!length(input)>0){
       input <-  c("mean", "std")
    }
    
    #   Checks if arguments were passed to the function (other than DF).
    if (whole_set){
        #   If whole_set is TRUE, throws a warning and returns the original dataframe.
        warning("No data frame restriction will occur!")
        return (DF)
    } else {
        #   If some arguments were passed, adds "Labels" and "Subject",
        toMatch <- c(input, "Labels", "Subject")
        #   Creates a T/F mask by regular expression mapping,
        select_mask <- grepl(paste(toMatch,collapse="|"),colnames(DF))
        #   And uses this mask to store a subset of the dataframe in a new data frame.
        DF_less <- DF[select_mask]
    }
    
}


##      Parses the activity labels from activity_labels.txt in the root folder of the dataset.
##
##      DS_path     the path to the root folder of the dataset (where README.txt is).
get_act_names <- function(DS_path){
    #   Reads the content of the file.
    act_names <- read.table(file.path(DS_path, "activity_labels.txt"))
    
    #   Initiates a list to get the activity labels.
    list_names <- numeric(dim(act_names)[1])
    
    #   Changes the levels stored in act_names to characters and stores them in the pre-
    #   initiated list.
    for (i in seq(1,dim(act_names)[1])){
        list_names[i] <- as.character(act_names[i,2])
    }
    list_names
}


##      Changes the numerical activity labels to human interpretable labels. The conversion 
##      is stored in activity_labels.txt (cf. get_act_names()). 
##
##      DF          the data frame with the row Labels to be modified.
##      DS_path     the path to the root folder of the dataset (where README.txt is).
set_act_names <- function(DF, DS_path){
    activity <- get_act_names(DS_path)
    DF$Labels <- sapply(DF$Labels, function(f) activity[f])
    DF
}


##      Renames the column names (variable names) based on the renaming function 
##      name_as_human. 
##
##      DF          the data frame to be renamed
rename_var <- function(DF){
    #   gets the names of the data frame in a list.
    names <- names(DF)
    
    #   cycles through the elements of the list, passing them to the renaming function. 
    for (i in seq(1:length(names))){
        names[i] <- name_as_human(names[i])
    }
    
    #   renames the columns with the translated names list. 
    colnames(DF) <- names
    DF
}


##      This function is the computer-human translator for the variable names. 
##          NOTE : for some column names (EG angle) the translator is not yet implemented.
##
##      name        the computer name to be translated in a single character element. Lists 
##                  will result in a warning and only the first element will be translated.
name_as_human <- function(name){
    #   sets the very first element of the name. Cannot be NULL!
    prefix <- if (grepl("^t", name)){
        "Time-domain"
    } else if (grepl("^f", name)){
        "Frequency-domain"
    } else if (grepl("^angle", name)){
        "Angle of"
    } else if (grepl("^Labels", name)){
        "Activity performed"
    } else if (grepl("^Subject", name)){
        "Test subject number"
    } else {
        NULL
    }
    
    #   sets whether the data is estimated for the body, or for the gravity. 
    first <- if (grepl("^[ft]Body", name)){
        " body"
    } else if (grepl("^[ft]Gravity", name)){
        " gravity"
    } else {
        NULL
    }
    
    #   sets whether the measurement was performed by the accelerometer or the gyroscope.
    second <- if (grepl("^[A-z]+Acc", name)){
        " acceleration"
    } else if (grepl("^[A-z]+Gyro", name)){
        " gyration"
    } else {
        NULL
    }
    
    #   sets whether the the data is a measure of discontinuous movement.
    jerk <- if (grepl("^[A-z]+Jerk", name)){
        " jerking"
    } else {
        NULL
    }
    
    #   sets whether the measurement is a magnitude. 
    mag <- if (grepl("^[A-z]+Mag", name)){
        " magnitude"
    } else {
        NULL
    }
    
    #   sets what type of value the data represents. 
    measure <- if (grepl("mean()", name, fixed=T)){
        " mean"
    } else if (grepl("std()", name, fixed=T)){
        " standard deviation"
    } else if (grepl("mad()", name, fixed=T)){
        " median absolute deviation"
    } else if (grepl("max()", name, fixed=T)){
        " maximum"
    } else if (grepl("min()", name, fixed=T)){
        " minimum"
    } else if (grepl("sma()", name, fixed=T)){
        " signal magnitude area"
    } else if (grepl("energy()", name, fixed=T)){
        " energy"
    } else if (grepl("iqr()", name, fixed=T)){
        " interquartile range"
    } else if (grepl("entropy()", name, fixed=T)){
        " signal entropy"
    } else if (grepl("arCoeff()", name, fixed=T)){
        " autoregression coefficient"
    } else if (grepl("correlation()", name, fixed=T)){
        " correlation coefficient"
    } else if (grepl("maxInds()", name, fixed=T)){
        " highest component index"
    } else if (grepl("meanFreq()", name, fixed=T)){
        " mean frequency"
    } else if (grepl("skewness()", name, fixed=T)){
        " skewness"
    } else if (grepl("kurtosis()", name, fixed=T)){
        " kurtosis"
    } else if (grepl("bandsEnergy()", name, fixed=T)){
        " energy of bin "
    } else {
        NULL
    }
    
    #   sets on which axis the measurement was performed.
    axis <- if (grepl("-X", name, fixed=T)){
        " on X axis"
    } else if (grepl("-Y", name, fixed=T)){
        " on Y axis"
    } else if (grepl("-Z", name, fixed=T)){
        " on Z axis"
    } else {
        NULL
    }
    
    #   for bandsEnergy() measurements, sets the bin # of the measurement.
    bin <- NULL
    if (grepl("\\d{1-2},\\d{1-2}$", name)){
        temp <- strsplit(as.character(name), split="-")
        bin <- temp[[1]][length(temp[[1]])]
    }
    
    #   puts together all the parts of the name of the variable.
    paste(prefix, first, second, jerk, mag, measure, axis, bin, sep="")
}


##      Makes a summary of the data for each subject performing each activity. Activity 
##      labels must be in the before last column, and subject numbers in the last. 
##
##      DF          the data frame that will be summarized
summarise <- function(DF){
    #   gets the names for each column and the number of columns.
    c_name <- colnames(DF)
    c_name_length <- length(c_name)
     
    #   calculates a factor list based on the last and before last columns. These should 
    #   contain the subject numbers and activity labels respectively.
    act_levels <- factor(DF[[c_name_length-1]], ordered=T)
    subj_levels <- factor(DF[[c_name_length]], ordered=T)
    levels <- interaction(subj_levels, act_levels, drop=TRUE)
    
    #   initiates a new data frame to fit the summary in. 
    summarised = data.frame(matrix(vector(), nlevels(levels), c_name_length))
    colnames(summarised) <- c_name
    
    #   for each column, takes the mean for each level (combination of subject and activity).
    for (name in c_name){
        summarised[[name]] <- tapply(DF[[name]], levels, mean_w_char)
    }
    
    summarised
}


##      Handler for the mean function. If a non-numeric list is passed, the function returns 
##      the first element if all are identical, else it returns NA. 
##
##      x           the list of data to be treated (mean).
##      ...         supplementary arguments to be passed to the mean function.
mean_w_char <- function(x, ...){
    #   if x is a numeric list, returns the mean of this list.
    if (is.numeric(x)){
        return(mean(x, ...))
    } else {
        #   checks if all elements of the list are identical.
        answer <- T
        for (i in seq(2:length(x))){
            answer <- identical(x[1], x[i]) && answer
        }
        
        #   if the elements are indded identical, it returns the first element.
        if (answer){
            return(x[1])
        } else {
            #   if one or more elements are dissimilar, it gives a warning and returns NA
            warning("Error in the contraction of charaters: dissimilar elements found!")
            return(NA)
        }
        
    }
}


tidy_dataset("UCI_HAR")