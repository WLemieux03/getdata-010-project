# Code Book

## Loading the data
The clean version from the original dataset. It can be loaded into a data frame with:
```
DF <- read.table("tidy_data.txt", header=TRUE)
```

## Labels
### Activities
The names used are from the **activity_labels.txt** of the dataset:
- `WALKING`: walking on a level surface
- `WALKING_UPSTAIRS`: walking a flight of stairs upwards
- `WALKING_DOWNSTAIRS`: walking a flight of stairs downwards
- `SITTING`: sitting on a chair
- `STANDING`: standing up
- `LAYING`: laying on a flat surface

### Variables 
The tidy dataset **tidy_data.txt** was created by **run_analysis.R** and includes only the mean and standard deviation variables for all the measures for simplicity's sake. Some were obtained through a Fast Fourier Transform (FFT) and are noted as Frequency-Domain. These FFT measurements have an additionnal set of variables: the mean frequency. 

**These are given for each of the X, Y, and Z axis**

1. `Time.domain.body.acceleration`: Is the calculated acceleration of the user
2. `Time.domain.gravity.acceleration`: Is the gravity acceleration
3. `Time.domain.body.acceleration.jerking`: Is the jerking in the calculated acceleration of the user
4. `Time.domain.body.gyration`: Is the calculated rotation of the user
5. `Time.domain.body.gyration.jerking`: Is the jerking in the rotation of the user
6. `Frequency.domain.body.acceleration`: Is the FFT of the calculated acceleration of the user
7. `Frequency.domain.body.acceleration.jerking`: Is the jerking of the FFT of the calculated acceleration of the user
8. `Frequency.domain.body.gyration`: Is the  FFT of the calculated rotation of the user

Additionnal measurements: magnitude (each encompassing all three axis)

- `Time.domain.body.acceleration.magnitude`
- `Time.domain.gravity.acceleration.magnitude`
- `Time.domain.body.acceleration.jerking.magnitude`
- `Time.domain.body.gyration.magnitude`
- `Time.domain.body.gyration.jerking.magnitude`
- `Frequency.domain.body.acceleration.magnitude`
- `Frequency.domain.body.acceleration.jerking.magnitude`
- `Frequency.domain.body.gyration.magnitude`

**Identity variables:** these are the two last columns 

- `Activity.performed`: is one of the six activities performed during the test
- `Test.subject.number`: is the number attributed to the test subject (ranges from 1-30)

## Cleaning the data
The organizing function `tidy_dataset()` is called on sourcing the script. It calls all the slave functions in order to load and clean-up the dataset. 

The original data set is scattered over several files and folders. `assemble()` is the first function called, and it joins together the *train* and *test* sets loaded in memory by `load_set()`. The variable names are temporarily given by the `get_var_names()` function in order to allow merging the sets seamlessly. The names are taken from the **features.txt** file loaded with the dataset. 

`load_set()` loads all sensor readings (561 variables) from **X_test.txt** or **X_train.txt** and appends the activities (**Y_test.txt** or **Y_train.txt**) and subject numbers (**subject_test.txt** or **subject_train.txt**). 

The `select_variables()` function is then called to remove any unwanted variables. If none are provided, it removes all but the mean and standard deviation for each measurement. To select the whole data frame, the whole_set can be set to `TRUE`. Arguments are checked using regular expressions, retaining variables matching keywords given. 

The data frame then goes through `set_act_names()`. This function replaces the numbers representing the activities performed by the names of these activities. The names are retrieved from the **activity_labels.txt** file from the dataset by `get_act_names()`.

The variable names are then modified in the dataset by `rename_var()` to make the names human-readable. Actually, `rename_var()` is a handling function for `name_as_human()`. This function uses a series of regular expression matching to produce a name from the original column names. 

The last correction applied is done by `summarise()`. As each subject has data for the six activities several times (rows), these are averaged by subject and activity. The function makes use of a handler for the `mean()` fucntion in order to allow the contraction of the text labels of the activities. This handler is the `mean_w_char()` function. If the char elements are not all identical, `NA` is returned instead. 

## Functions
###tidy_dataset(DS_path, ..., whole_set=F)
The main function for the file. Executes all the other subfunctions. 

`DS_path`     the path to the root of the data set (i.e. location of the README.txt file).
`...`         the arguments to restrain the variables (function select_variables). If none is passed, a warning will be thrown and the whole data frame DF is returned. "Labels" and "Subjects" are automatically added to this list.
`whole_set`   boolean value. TRUE if whole dataset is required; Results in a warning.

###load_set(set, DS_path)

###assemble(DS_path)

###get_var_names(DS_path)

###select_variables(DF, ..., whole_set)

###get_act_names(DS_path)

###set_act_names(DF, DS_path)

###rename_var(DF)

###name_as_human(name)

###summarise(DF)

###mean_w_char(x, ...)
