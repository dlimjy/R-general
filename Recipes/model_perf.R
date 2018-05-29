#### Model performance
# Take in a file with labels + predicted probabilities
# Uses ROCR

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

