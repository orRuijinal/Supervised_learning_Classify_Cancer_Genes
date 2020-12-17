# Supervised_learning_Identify_Cancer_Genes
In this project, we will identify both TSGs and OGs. If we can have an accurate prediction of the class of genes, we can use this model to discover new TSGs and OGs, which will be very useful in cancer diagnosis.


This project focus on only using methods such as KNN, LDA, QDA, and Logistic Logression.  


## Introduction
  Majority of cancers are about gene mutations which are some permanent change in the DNA sequence. This is normally caused by lifestyle and environment and as the result of it, the cell will be out of control and keep invading other cells and spread out through people's bodies. Normally our gene will find the balance between growth and apoptosis of cells controlled by OG and TSG, but as key genetic alterations accumulate, the balance will be broken and cause cancer. In this study, our goal is to determine if the given gene is a neutral gene(NG), Oncogene(OG), or a tumor suppressor gene(TSG) based on the basic information of the genes.


## Feature Selection
  We first take a look at the correlation relationships between the class variables and all the others. It seems there’s no too obvious relationship between them. As a naive model, from the boxplot of “class” against other predictors, we have a bias decision that we want to take all the predictors’ absolute correlation with the class column that is greater than 0.28(This can capture most predictors that have relationship with “class”) into account. After filtering out predictors, we want to check if there’s invalid observations or outliers. But nothing seems too unreasonable since some predictors’ values have a large range in nature so we don’t want to break it.

  Since we want to predict a nominal variable(three classes) we conduct a full model of Multinomial Logistic Regression to see if there are significant predictors. Multinomial Logistic Regression can tell if there is a relationship between the independent and dependent variables. We calculated the z-score for each variable and we decided to pursue those variables that have a p-value smaller than 0.05. We ended up having 61 predictors including the "class" predictor.(The full list of predictors are in the appendix)
  
  
## Inbalanced Sample
    From the training data set we can see that it contains about 89\% of “NG” genes, 5.5\% of “OG” genes, and 5.5\% of “TSG” genes. The model that relies on this training data set might become skewed to minority classes. In this situation, we utilized upsampling techniques to mitigate the issues. We also took downsampling into account, but it did not perform well since the proportion of minority class is too small, which will lead to a problem that we will only have a small training data set. The motivation of Upsampling techniques is quite simple that we randomly draw samples from the minority class so that the minority class will end up having the same size as the majority class.
