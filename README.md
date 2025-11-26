# Happiness Prediction Using KNN (k-Nearest Neighbors)

This project predicts a person's **happiness level (1–10)** based on their
lifestyle habits and social media usage patterns.  
The goal is to explore whether similar people (in terms of behavior, habits,
stress, sleep, and screen time) tend to have similar happiness levels.

The analysis uses **KNN regression**, which predicts the target value based
on the average happiness of the *k* most similar individuals.

---

## Repository Structure

- `R-Code/`
  - `knn_happiness.R` — main analysis script (cleaning → encoding → scaling → K tuning → evaluation → visualization)

- `data/`
  - `Mental_Health_and_Social_Media_Balance_Dataset.csv` — raw dataset

- `figures/`
  - `01_variables.png` — boxplots of predictors
  - `02_k_selection.png` — RMSE vs K for tuning
  - `03_actual_vs_predicted.png` — model performance
  - `04_knn_visualisation.png` — KNN neighbor visualization (PCA)

- `README.md`

---

## Project Overview

The goal is to answer the question:

> **Can we predict a person's happiness level based on people with a similar lifestyle?**

Steps performed:

### **1. Data Cleaning**
- Column names standardized  
- Unnecessary ID column removed  
- Missing values checked  
- Categorical variables dummy-encoded  
  - Gender  
  - Social media platform  
- Dataset made fully numeric (required for Euclidean distance)

### **2. Scaling (Standardization)**
KNN is distance-based → variables must be comparable.  
All predictors were standardized using **training-set centering and scaling**.

### **3. Train–Test Split**
- 70% training  
- 30% testing  
- Ensures honest model evaluation

### **4. Tuning K**
Tested `k = 1` to `30` and computed RMSE for each.  
The value of **k** with the lowest RMSE is selected.

Visualization: `figures/02_k_selection.png`

[View K Selection Plot](figures/02_k_selection.png)



### **5. Final Model**
Using the optimal **k**, predictions were generated for the test set.

Evaluation metrics included:
- **RMSE**
- **MAE**
- **R²**

Visualization: `figures/03_actual_vs_predicted.png`

[View Actual vs Predicted Plot](figures/03_actual_vs_predicted.png)



### **6. KNN Visualization (Neighbors Plot)**
A PCA-based 2D plot shows:
- the selected test person (blue star)  
- their *k* nearest neighbors (red dots)

Visualization: `figures/04_knn_visualisation.png`

[View KNN Visualisation](figures/04_knn_visualisation.png)


---

## How to Run the Analysis

- **Open the main script:**
  - `R-Code/knn_happiness.R`

- **Make sure the dataset is in the correct folder:**
  - `data/Mental_Health_and_Social_Media_Balance_Dataset.csv`

- **Run the script sequentially to perform:**
  - data cleaning  
  - dummy encoding  
  - standardization (scaling)  
  - train–test split  
  - tuning of K (1–30)  
  - KNN model training  
  - model performance evaluation (RMSE, MAE, R²)  
  - visualization of results  
  - neighbor interpretation via PCA

- **All generated figures will automatically appear in:**
  - `figures/`
    - `01_variables.png`
    - `02_k_selection.png`
    - `03_actual_vs_predicted.png`
    - `04_knn_visualisation.png`

- **No additional configuration required**  
  Simply run the script in R or RStudio after installing the required packages.

  ## Required Packages

Install the required packages with:

```r
install.packages(c(
  "tidyverse",
  "fastDummies",
  "FNN",
  "ggplot2",
  "kableExtra"
))

