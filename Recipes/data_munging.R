##### Some recipes for data munging
# Using titanic dtaset as an example
setwd("C:\\Analytics\\Kaggle\\Titanic")
train <- fread("train.csv")


# Null treatment ----------------------------------------------------------

train %>% select(Age) %>% is.na %>% table # Check distribution of nulls

# Imputing nulls, stratified
age_med_M <- (train %>% filter(Sex == "male"))$Age %>% median(na.rm = TRUE) # filter first, select column with $, then apply a function
age_med_F <- (train %>% filter(Sex == "female"))$Age %>% median(na.rm = TRUE)

train$Age[is.na(train$Age)] <- -100 # Set null to some arbitrary value
train$Age <- ifelse(train$Age == -100, ifelse(train$Sex == "male", median_age_M, train$Age), train$Age) # Use that arbitrary value + straifying variable to replace
train$Age <- ifelse(train$Age == -100, ifelse(train$Sex == "female", median_age_F, train$Age), train$Age)

# Replacing blank strings
train$TextColumn <- ifelse(train$TextColumn == "", "Replacement", train$TextColumn)


# # Train test split ------------------------------------------------------

split_ratio <- 0.8 # Specify split ratio
split_size <- floor(0.8 * nrow(train)) # Floor of number of rows based on split ratio
split_ind <- base::sample(seq_len(nrow(train)), size = split_size) # Generate index for splitting
trainset <- train[split_ind,] 
testset <- train[-split_ind,]
