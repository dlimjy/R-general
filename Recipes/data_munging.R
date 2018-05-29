##### Some recipes for data munging
# Using titanic dtaset as an example
setwd("C:\\Analytics\\Kaggle\\Titanic")
titan <- fread("titan.csv")


# Null treatment ----------------------------------------------------------

titan %>% select(Age) %>% is.na %>% table # Check distribution of nulls

# Imputing nulls, stratified
age_med_M <- (titan %>% filter(Sex == "male"))$Age %>% median(na.rm = TRUE) # filter first, select column with $, then apply a function
age_med_F <- (titan %>% filter(Sex == "female"))$Age %>% median(na.rm = TRUE)

titan$Age[is.na(titan$Age)] <- -100 # Set null to some arbitrary value
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "male", median_age_M, titan$Age), titan$Age) # Use that arbitrary value + straifying variable to replace
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "female", median_age_F, titan$Age), titan$Age)

# Replacing blank strings
titan$TextColumn <- ifelse(titan$TextColumn == "", "Replacement", titan$TextColumn)


# Binning -----------------------------------------------------------------
# Bin age as an example
titan$Age_bin <- ifelse(titan$Age < 15, "< 15"
                , ifelse(titan$Age < 20, "15 - 19"
                , ifelse(titan$Age < 25, "20 - 24"
                , ifelse(titan$Age < 30, "25 - 29"
                , ifelse(titan$Age < 35, "30 - 34"
                , ifelse(titan$Age < 40, "35 - 39"
                , ifelse(titan$Age < 45, "40 - 44"
                , ifelse(titan$Age < 50, "45 - 49"
                , ifelse(titan$Age < 55, "50 - 54"
                , ifelse(titan$Age < 60, "55 - 59"
                , ifelse(titan$Age < 65, "60 - 64", "65+")))))))))))

# # Train test split ------------------------------------------------------

split_ratio <- 0.8 # Specify split ratio
split_size <- floor(0.8 * nrow(titan)) # Floor of number of rows based on split ratio
split_ind <- base::sample(seq_len(nrow(titan)), size = split_size) # Generate index for splitting
trainset <- titan[split_ind,] 
testset <- titan[-split_ind,]
