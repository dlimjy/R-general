##### Recipe for using XGBoost, binary classification
# Read in data
setwd("Z:\\Kaggle\\Titanic")
titan <- fread("train.csv")


# Data munging ------------------------------------------------------------
# Missing ages, impute with median age by gender and pclass
median_age_M_1 <- (titan %>% filter(Sex == "male" & Pclass == 1))$Age %>% median(na.rm = TRUE)
median_age_M_2 <- (titan %>% filter(Sex == "male" & Pclass == 2))$Age %>% median(na.rm = TRUE)
median_age_M_3 <- (titan %>% filter(Sex == "male" & Pclass == 3))$Age %>% median(na.rm = TRUE)
median_age_F_1 <- (titan %>% filter(Sex == "female" & Pclass == 1))$Age %>% median(na.rm = TRUE)
median_age_F_2 <- (titan %>% filter(Sex == "female" & Pclass == 2))$Age %>% median(na.rm = TRUE)
median_age_F_3 <- (titan %>% filter(Sex == "female" & Pclass == 3))$Age %>% median(na.rm = TRUE)

titan$Age[is.na(titan$Age)] <- -100
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "male" & titan$Pclass == 1, median_age_M_1, titan$Age), titan$Age)
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "male" & titan$Pclass == 2, median_age_M_2, titan$Age), titan$Age)
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "male" & titan$Pclass == 3, median_age_M_3, titan$Age), titan$Age)
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "female" & titan$Pclass == 1, median_age_F_1, titan$Age), titan$Age)
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "female" & titan$Pclass == 2, median_age_F_2, titan$Age), titan$Age)
titan$Age <- ifelse(titan$Age == -100, ifelse(titan$Sex == "female" & titan$Pclass == 3, median_age_F_3, titan$Age), titan$Age)
titan$Age %>% summary

# Select columns we want
modelset <- titan %>% select(Survived, Pclass, Sex, Age_bin, SibSp, Parch, Fare, Embarked)


# Train test split --------------------------------------------------------
split_size <- floor(0.8 * nrow(modelset))
split_ind <- base::sample(seq_len(nrow(modelset)), size = split_size)
trainset <- modelset[split_ind,]
testset <- modelset[-split_ind,]

trainset %>% nrow
testset %>% nrow()



# Xgboosting --------------------------------------------------------------
# Convert dataframe to matrix
trainset_M <- Matrix::sparse.model.matrix(Survived ~.-1, trainset) # -1 removes the first col that is generated (basically an index)
testset_M <- Matrix::sparse.model.matrix(Survived~.-1, testset)

labelz = as.numeric(trainset$Survived)
param <- list(objective   = "binary:logistic", # logistic outputs probabilities
              eval_metric = "logloss", # AUC also an option, default for binary:logit is 
              max_depth   = 5,
              eta         = 0.1, # step size in h2o
              gammma      = 0,
              colsample_bytree = 0.5, #col sample rate in h2o
              min_child_weight = 1)

xgb <- xgboost(params  = param,
               data    = trainset_M,
               label = labelz,
               nrounds = 500,
               print_every_n = 10,
               verbose = 1)

# Prediction  -------------------------------------------------------------
trainpred <-predict(xgb, trainset_M) %>% as.data.frame
testpred <- predict(xgb, testset_M) %>% as.data.frame


# Prep for ROCR -----------------------------------------------------------
names(trainpred) <- "p1"
names(testpred) <- "p1"

trainpred$label <- trainset$Survived
testpred$label <- testset$Survived

# Model metrics -----------------------------------------------------------
## Var importance
importance_matrix <- xgb.importance(model = xgb)
print(importance_matrix)
xgb.plot.importance(importance_matrix = importance_matrix)

## ROCR
# Create prediction object
train_predobj <- prediction(trainpred$p1, trainpred$label)
test_predobj <- prediction(testpred$p1, testpred$label)

# ROC
train_roc <- performance(train_predobj, measure = "tpr", x.measure = "fpr")
test_roc <- performance(test_predobj, measure = "tpr", x.measure = "fpr")

par(mfrow = c(1, 2))
plot(train_roc, main = paste0("Train ROC - AUC = ", performance(train_predobj, measure = "auc")@y.values))
abline(a = 0, b = 1)
plot(test_roc, main = paste0("Test ROC - AUC = ", performance(test_predobj, measure = "auc")@y.values))
abline(a = 0, b = 1)

