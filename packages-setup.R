# Setup workspace
pkgs <- c("tidyverse", "h2o", "gbm", "rpart", "data.table", "ROCR", "lubridate")
# install.packages(pkgs)

lapply(pkgs, require, character.only = TRUE)