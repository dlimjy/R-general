##### Some recipes for data munging
# Using titanic dtaset as an example
setwd("C:\\Analytics\\Kaggle\\Titanic")
train <- fread("train.csv")


# Null treatment ----------------------------------------------------------

train %>% select(Age) %>% is.na %>% table # Check distribution of nulls

# Suppose we want to impute missing ages using the median, stratifying by gender
age_med_M <- (train %>% filter(Sex == "male"))$Age %>% median(na.rm = TRUE) # filter first, select column with $, then apply a function
age_med_F <- (train %>% filter(Sex == "female"))$Age %>% median(na.rm = TRUE)

train$Age[is.na(train$Age)] <- -100
train$Age[train$Sex == "male" & train$Age == -100] <- age_med_M
train$Age[train$Sex == "female" & train$Age == -100] <- age_med_F


