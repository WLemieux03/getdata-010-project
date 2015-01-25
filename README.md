# getdata-010-project
Course project for the Getting and Cleaning Data Coursera class

## Summary
The **run_analysis.R** file is a program designed to clean the [Human Activity Recognition dataset of the UC Irvine Machine Learning Repository] (https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). The complete dataset is included in the **UCI_HAR** directory. The file produced by the cleaning process is the **tidy_data.txt** file. Last, the **CodeBook.md** explains the various operations performed on the original data to yield a single data frame, **tidy_data.txt**.

## run-analysis.R
The organizing function `tidy_dataset()` is called on sourcing the script. It calls all the slave functions in order to load and clean-up the dataset. 

The original data set is scattered over several files and folders. `assemble()` is the first function called, and it joins together the *train* and *test* sets loaded in memory by `load_set()`. The variable names are temporarily given by the `get_var_names()` function in order to allow merging the sets seamlessly. The names are taken from the **features.txt** file loaded with the dataset. 

`load_set()` loads all sensor readings (561 variables) from **X_test.txt** or **X_train.txt** and appends the activities (**Y_test.txt** or **Y_train.txt**) and subject numbers (**subject_test.txt** or **subject_train.txt**). 

The `select_variables()` function is then called to remove any unwanted variables. If none are provided, it removes all but the mean and standard deviation for each measurement. To select the whole data frame, the whole_set can be set to `TRUE`. Arguments are checked using regular expressions, retaining variables matching keywords given. 

The data frame then goes through `set_act_names()`. This function replaces the numbers representing the activities performed by the names of these activities. The names are retrieved from the **activity_labels.txt** file from the dataset by `get_act_names()`.

The variable names are then modified in the dataset by `rename_var()` to make the names human-readable. Actually, `rename_var()` is a handling function for `name_as_human()`. This function uses a series of regular expression matching to produce a name from the original column names. 

The last correction applied is done by `summarise()`. As each subject has data for the six activities several times (rows), these are averaged by subject and activity. The function makes use of a handler for the `mean()` fucntion in order to allow the contraction of the text labels of the activities. This handler is the `mean_w_char()` function. If the char elements are not all identical, `NA` is returned instead. 
## CodeBook.md
This file contains several additionnal and more detailed instructions about **run_analysis.R**. It also explains the variables contained in **tidy_data.txt**. 
## tidy_data.txt
The clean version from the original dataset. It can be loaded into a data frame with:
```
DF <- read.table("tidy_data.txt", header=TRUE)
```
