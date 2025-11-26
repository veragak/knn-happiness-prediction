
#load libraries
library(tidyverse)
library(fastDummies)
library(FNN)
library(ggplot2)
library(knitr)
library(kableExtra)

#research question
# Can we predict a person's happiness level based on persons with similar lifestyle?

#import data set
df <- read.csv("Mental_Health_and_Social_Media_Balance_Dataset.csv")

# Clean column names
names(df) <- make.names(names(df))

#make all data numeric (required for KNN)
## KNN predicts outcomes by comparing observations based on Euclidean distance between their feature values.
# This means all input variables must correctly reflect similarity.
# We use dummy variables for Gender & Social media because the categories have no natural numeric order, 
# and KNN relies on distance, so encoding Gender as 1,2,3 would incorrectly imply relationships that do not exist.

#the first dummy is the reference dummy (female & Facebook)
df <- fastDummies::dummy_cols(df,
                              select_columns = c("Gender", "Social_Media_Platform"),
                              remove_first_dummy = TRUE, #female baseline, and facebook too
                              remove_selected_columns = TRUE) #drop original colums
# remove ID only
df <- subset(df, select = -User_ID)
stopifnot(all(colSums(is.na(df)) == 0))  # will error if any NA

##visual check for outliers


df %>%
  pivot_longer(cols = -Happiness_Index.1.10., names_to = "Variable", values_to = "Value") %>%
  ggplot(aes(x = Variable, y = Value)) +
  geom_boxplot() +
  coord_flip() +
  theme_bw()


#There are no outliers that should be removed.
# We evaluated potential outliers using boxplots and determined that the observed extreme values 
# represent realistic behavioral variation (e.g., high screen time or high exercise frequency) rather 
# than data-entry errors. Since KNN is sensitive to scale, we standardized all predictor variables 
# instead of removing observations, ensuring that natural variation is retained while preventing 
# extreme values from disproportionately influencing distance calculations.

# train test split
set.seed(123) # make the random split reproducible
n <- nrow(df) # number of rows (people)
idx_train <- sample(seq_len(n), size = floor(0.7*n)) # pick 70% indices at random

train <- df[idx_train, ]  # training data (what the model "sees")
test  <- df[-idx_train, ] # test data (held-out, for honest evaluation)

#defining predictor x and target y
y_train <- train$Happiness_Index.1.10.  
y_test  <- test$Happiness_Index.1.10.

#KNN needs predictors (features) to compute distances; 
#the target is what we’re trying to predict and must be excluded from the distance calculation.
X_train <- subset(train, select = -Happiness_Index.1.10.) # all columns except target
X_test  <- subset(test,  select = -Happiness_Index.1.10.) # same for test

#if variables are on different scales, distance becomes unfair.
#scale(standardize)  all predictors variables
X_train_sc <- scale(X_train)
X_test_sc <- scale(
  X_test,
  center = attr(X_train_sc, "scaled:center"),
  scale = attr(X_train_sc, "scaled:scale")
)


#Tune K (find the best number of neighbors)
##FNN function uses euclidian distance by default
k_values <- 1:30
rmse_values <- sapply(k_values, function(k){
  pred_k <- knn.reg(train = X_train_sc, test = X_test_sc, y = y_train, k = k)$pred
  sqrt(mean((pred_k - y_test)^2))
})

best_k <- k_values[which.min(rmse_values)]
best_k

#Plot RMSE vs K
plot(k_values, rmse_values, type = "b",
     xlab = "K (neighbors)", ylab = "RMSE",
     main = "K Selection Curve")
abline(v = best_k, col = "red", lty = 2)

#Fit Final KNN Model Using Best K
final_pred <- knn.reg(train = X_train_sc, test = X_test_sc,
                      y = y_train, k = best_k)$pred

#Evaluate Model Performance
RMSE <- sqrt(mean((final_pred - y_test)^2)) # typical error size
MAE  <- mean(abs(final_pred - y_test))  # average absolute error
R2   <- 1 - sum((final_pred - y_test)^2) / sum((y_test - mean(y_test))^2) # variance explained

results_table <- data.frame(
  Metric = c("Best K", "RMSE", "MAE", "R²"),
  Value  = c(best_k, round(RMSE, 3), round(MAE, 3), round(R2, 3))
)


results_table |>
  kable(caption = "KNN Model Performance Metrics") |>
  kable_styling(full_width = FALSE, bootstrap_options = c("striped","hover"))





#Actual vs Predicted plot
ggplot(data.frame(Actual = y_test, Predicted = final_pred),
       aes(Actual, Predicted)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, linetype = 2) +
  labs(title = "KNN: Actual vs Predicted Happiness",
       x = "Actual (test set)", y = "Predicted") +
  theme_minimal()


## prediction example 

new_person <- data.frame(
  Age = 40, 
  Daily_Screen_Time.hrs. = 5,
  Sleep_Quality.1.10. = 6,
  Stress_Level.1.10. = 7,
  Days_Without_Social_Media = 0,
  Exercise_Frequency.week. = 5,
  Gender_Male = 0,
  Gender_Other = 0,
  Social_Media_Platform_TikTok = 1,
  Social_Media_Platform_YouTube = 0,
  Social_Media_Platform_LinkedIn = 0,
  Social_Media_Platform_Instagram = 0,
  Social_Media_Platform_X..Twitter.=0

)

# align columns with the training matrix (names & order)
missing <- setdiff(names(X_train), names(new_person))
if (length(missing)) new_person[missing] <- 0
new_person <- new_person[, names(X_train), drop = FALSE]


# Scale it using training scaling:
new_person_sc <- scale(new_person,
                       center = attr(X_train_sc, "scaled:center"),
                       scale  = attr(X_train_sc, "scaled:scale"))

# Predict:
predicted_happiness <- knn.reg(train = X_train_sc, test = new_person_sc, 
                               y = y_train, k = best_k)$pred
predicted_happiness





library(FNN)
library(ggplot2)
library(dplyr)

#picks one test person (test_row <- 5),
#finds their K (= best_k) nearest neighbors in the scaled space,
#uses PCA to get 2D coordinates just for plotting,
#marks neighbors in red and the test person as a blue star,
#plots them.
# explains how KNN actually works

# Pick a test person to visualize 
test_row <- 10

# Get the 18 nearest neighbors (using the scaled training matrix)
kn <- get.knnx(X_train_sc, X_test_sc[test_row, , drop = FALSE], k = best_k)
nbr_idx <- as.vector(kn$nn.index)   # indices of closest training rows

# PCA to get 2D coordinates for plotting
pca <- prcomp(X_train_sc, center = FALSE, scale. = FALSE)
scores_train <- as.data.frame(predict(pca, X_train_sc))
scores_test  <- as.data.frame(predict(pca, X_test_sc[test_row, , drop = FALSE]))

# Keep only first two components; if PC2 doesn't exist, create it
if(ncol(scores_train) < 2) {
  scores_train$PC2 <- 0
  scores_test$PC2 <- 0
}
scores_train <- scores_train[,1:2]
scores_test  <- scores_test[,1:2]
colnames(scores_train) <- c("PC1","PC2")
colnames(scores_test)  <- c("PC1","PC2")

# Mark which points are neighbors
scores_train$Type <- "Other Person"
scores_train$Type[nbr_idx] <- "Neighbor"

# Plot
ggplot() +
  geom_point(data = scores_train, aes(PC1, PC2, color = Type), alpha = 0.7, size = 3) +
  geom_point(data = scores_test, aes(PC1, PC2), shape = 8, size = 5, color = "blue") +  # star = test person
  scale_color_manual(values = c("Neighbor" = "red", "Other Person" = "grey")) +
  labs(title = paste("The", best_k, "Closest Neighbors to the Test Person"),
       subtitle = "Blue star = test person   •   Red points = nearest neighbors",
       x = "PC1 (visualization)", y = "PC2 (visualization)") +
  theme_minimal()


