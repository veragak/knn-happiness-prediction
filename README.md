# Happiness Prediction Using KNN (k-Nearest Neighbors)

This project predicts a person's **happiness level (1–10)** based on their
lifestyle habits and social media usage patterns.  
The goal is to explore whether similar people (in terms of behavior, habits,
stress, sleep, and screen time) tend to have similar happiness levels.

The analysis uses **KNN regression**, which predicts the target value based on
the average happiness of the *k* most similar individuals.

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

### **Research Question**
**Can we predict a person's happiness level based on people with a similar lifestyle?**

---

### **1. Data Cleaning**
- Column names standardized  
- Unnecessary ID column removed  
- Missing values checked  
- Categorical variables dummy-encoded:
  - Gender  
  - Social media platform  
- Dataset converted to fully numeric (required for Euclidean distance)

---

### **2. Scaling (Standardization)**
KNN uses Euclidean distance → variables must be comparable.  
All predictors were standardized using **training-set mean and SD**.

---

### **3. Train–Test Split**
- 70% training  
- 30% testing  
- Ensures honest model evaluation  

---

### **4. Tuning K**
- Tested **k = 1 to 30**  
- Computed RMSE for each  
- Selected the k with the **lowest RMSE**

**Visualization:**  
[View K Selection Plot](figures/02_k_selection.png)

---

### **5. Final Model**
Using the optimal **k**, predictions were generated for the held-out test set.

Evaluation metrics:
- **RMSE**  
- **MAE**  
- **R²**

**Performance plot:**  
[Actual vs Predicted](figures/03_actual_vs_predicted.png)

---

### **6. KNN Visualization (Neighbors Plot)**

A PCA-based 2D plot shows:
- the selected test person (**blue star**)  
- their *k* nearest neighbors (**red points**)  
- all others in grey  

**Visualization:**  
[KNN Visualisation](figures/04_knn_visualisation.png)

---

## How to Run the Analysis

- Open the main script:  
  - `R-Code/knn_happiness.R`

- Ensure the dataset is located at:  
  - `data/Mental_Health_and_Social_Media_Balance_Dataset.csv`

- Run the script in order to perform:
  - data cleaning  
  - dummy encoding  
  - standardization  
  - train–test split  
  - tuning of k  
  - KNN regression  
  - performance evaluation  
  - visualizations (saved to `figures/`)

- Figures automatically saved to:
  - `figures/01_variables.png`  
  - `figures/02_k_selection.png`  
  - `figures/03_actual_vs_predicted.png`  
  - `figures/04_knn_visualisation.png`

No additional configuration required — just install packages and run.

---

## Required Packages

Install all required packages with:

```r
install.packages(c(
  "tidyverse",
  "fastDummies",
  "FNN",
  "ggplot2",
  "kableExtra"
))


