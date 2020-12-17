library(caret)
library(nnet)
library(ggcorrplot)
library(caret) 
library(MLeval)
library(glmnet)


# see <-read.csv("submission019.csv")
# table(see$class)   

# 1126  105  132 
#  1107 114 142 /score 0.8 set.seed(151515)
# 1117  116  130 / score 0.81  # best!
# 1113 115 135 / set.seed(51243)    
# 51244/ 0.7  1120 101 142
training <- read.csv("training.csv")
training <- training[, -1]
testing <- read.csv("test.csv")




dim(training)




#variables selecting--------

cor_var <- cor(training)
ml <- multinom(class ~. , data = training)
sum.ml <- summary(ml)

# now get the p values by first getting the t values
#which(pt(abs(sum.ml2$coefficients / sum.ml2$standard.errors), df = nrow(training)-97, lower=FALSE) > 0.05)
p <- (1- pnorm(abs(sum.ml$coefficients / sum.ml$standard.errors), 0 ,1)) * 2
#selected variables 
best.var <- as.numeric(which(p[1,] < 0.05 & p[2,] < 0.05)) - 1
best.var <- best.var[-1]
# best.var <- which(abs(cor_var[,98]) >= 0.3 )
names(best.var) <- NULL
cat(best.var, sep = ", ")


cor_var <- cor(training[c(2, 3, 7, 8, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                   24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
                   42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 58, 61, 62, 66,
                   69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 98)])





# change class name to character
training$class <- factor(unlist(lapply(training$class,
                                       function(x){ if (x == 1) {"OG"}else if(x == 2) {"TSG"} else {"NG"}})),
                         levels = c("NG", "OG", "TSG"))



# best_var02 <- which(abs(cor_var[,61]) >= 0.2)
# summary(abs(cor_var[,61]))
# indexs <- which(as.numeric(colnames(training) %in% names(best_var02)) == 1)
# cat(indexs, sep = ", ")
# 
# 


#2, 3, 7, 8, 17, 21, 22, 25, 28, 31, 36, 37, 38,41, 42, 43, 44, 45, 46, 52, 54, 62, 66, 69, 72, 75, 78, 87, 93, 96, 98

#------------------------------------------------------------------------------------------------------

# training_df <- training[c(2, 3, 7, 8,
#                           9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 31, 
#                           32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
#                           52, 53, 54, 55, 58, 61, 62, 66, 69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 98)]



# wo used upsample to eliminate the problem of inbalanced sample in our training set.
set.seed(51244)
balanced_train <- upSample(x = training[,-ncol(training)], y= training$class) # 8520 total observations now


 training_df <- balanced_train[c(2, 3, 7, 8, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                                 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
                                 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 58, 61, 62, 66,
                                 69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 98)]


View(data.frame("Predictors" = colnames(training_df)))

 # training_df <- balanced_train[c(2, 3, 7, 8, 17, 21, 22, 25, 28, 31, 36, 37, 
 #                                 38,41, 42, 43, 44, 45, 46, 52, 54, 
 #                                 62, 66, 69, 72, 75, 78, 87, 93, 96, 98)]
 # 
 # 
 # 
 
 dim(training_df)
 

# training$class <- factor(unlist(lapply(training$class,
#                                        function(x){ if (x == 1) {"OG"}else if(x == 2) {"TSG"} else {"NG"}})),
#                          levels = c("NG", "OG", "TSG"))
# 
# 


#---------------------------------------------CV-model fitting
 
 
trainIndex <- createDataPartition(training_df$Class, p = 0.7, 
                                  list = FALSE) 

cell_training <- training_df[trainIndex,]
cell_testing <- training_df[-trainIndex,]

train_control <- trainControl(method = "cv", number = 5,
                              classProbs = TRUE,
                              savePredictions = TRUE)

# KNNfit <- train(Class ~ ., 
#                 data = cell_training, method = 'knn',
#                 ## Center and scale the predictors for the training
#                 ## set and all future samples.
#                 preProc = c("center", "scale"),
#                 trControl = train_control,
#                 tuneGrid = expand.grid(k = seq(1, 50, by = 5)))
# ggplot(KNNfit) + theme_bw()

dim(cell_training)

LRfit <- train(Class ~ . , 
               data = cell_training, method = "multinom",
               preProc = c("center", "scale"),
               trControl = train_control)




# LDAfit <- train(Class ~ .,
#                 data = cell_training, method = "lda",
#                 preProc = c("center", "scale"),
#                 trControl = train_control)

# we abandone LDA due to some variables are collinear.


# QDAfit <- train(Class ~ . ,
#                 data = cell_training, method = "qda",
#                 preProc = c("center", "scale"),
#                 trControl = train_control)



res <- evalm(list(KNNfit,LRfit),gnames=c('KNN','MLR'))
res$roc

predLR <- predict(LRfit, newdata = cell_testing)
confusionMatrix(data = predLR, reference = cell_testing$Class)


#------------------------------------------------------------------------------------------------------------------
# output

sample02 <- read.csv("sample.csv")

submit003 <- testing[-1]
submit003 <- submit003[c(2, 3, 7, 8, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                         24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
                         42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 58, 61, 62, 66,
                         69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 98)]

dim(submit003)

submit003 <- predict(LRfit, newdata = submit003, "prob") # 1256 45 62


class003 <- unlist(lapply(submit003, function(x){if(x == "NG") {0} 
  else if (x == "OG") {1}
  else {2}}))

sample02$class <- class003

table(submit003)
table(sample02$class)
table(class003)


write.csv(sample02, row.names = FALSE, file = "submission023.csv")


# table(read.csv("submission003.csv")$class) best! 
# 1251 49 63  best! seed 1697, cv 0.7  
# 1081  130  152 best 0.738
# 1052  167  144   DOWN SAMPLE 
# 1078 133 152 set.seed 1697/ cv 0.8


