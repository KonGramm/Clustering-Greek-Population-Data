# Clustering the Age Composition of Greek Municipalities

MSc coursework project — **Statistical Machine Learning**, MSc in Statistics, Athens
University of Economics and Business (AUEB) — Prof. D. Karlis.

## Overview

This project explores the **age composition of Greece's population**, based on the
**2001 national census**, to identify groups of municipalities with similar demographic
(age) profiles. For each municipal district, the data records the number of people in
each of 7 age groups (0–14, 15–24, 25–39, 40–54, 55–64, 65–79, 80+), split by gender.

The goals of the analysis are to:

1. Determine the **optimal number of clusters** of municipalities based on age structure.
2. **Characterize** each cluster in terms of its typical age distribution.
3. Compare clustering approaches (hierarchical vs. model-based) and validate results
   using multiple evaluation techniques.

## Methods

### Data preparation
- Raw census data (Greek-language column headers) is cleaned and renamed into readable
  English column names.
- Only municipality-level rows (`ΔΗΜΟΣ`) are retained.
- Age-group counts are converted to **relative frequencies** (proportion of each
  municipality's population in each age band), so that municipalities of different
  sizes are directly comparable.

### Hierarchical Clustering
- Distance metrics: **Mahalanobis**, Euclidean, Manhattan, and Gower.
- Linkage methods: **Ward**, Complete, Single, and Average.
- Cluster validity assessed via:
  - **Silhouette analysis** (average silhouette width across k = 2–15 clusters)
  - **Wilks' Lambda** (MANOVA-based separation test across cluster solutions)

### Model-Based Clustering
- **Gaussian Mixture Models** fitted via `mclust`, testing multiple covariance
  structures (`EII`, `VII`, `EEI`, `EVI`, `VEI`, `VVI`) and 2–20 components.
- Optimal number of components selected via **BIC**.

### Comparison & Visualization
- **Principal Component Analysis (PCA)** used to visualize cluster separation in 2D.
- Per-cluster age-distribution bar charts to interpret and characterize each cluster.
- **Adjusted Rand Index (ARI)** used to compare agreement between the hierarchical
  and model-based cluster assignments.

## Key findings

- Ward's method (with Mahalanobis distance) combined with silhouette analysis suggests
  **4 clusters** of municipalities as a well-separated, interpretable solution.
- Each of the 4 hierarchical clusters shows a visibly distinct age profile (e.g. clusters
  skewed toward younger vs. older populations).
- The Gaussian Mixture Model favors a much larger number of components (18, by BIC),
  reflecting a more granular decomposition than the hierarchical solution.
- Agreement between the hierarchical (k=4) and model-based clustering, measured via
  Adjusted Rand Index, is reported in the script/report as a way of cross-validating the
  two approaches.

## Files

| File | Description |
|---|---|
| `greek_data.xls` | Raw 2001 census data: population counts by age group, gender, and municipality |
| `Clustering_Project_Code.R` | Main R script: data cleaning, hierarchical clustering, model-based clustering, evaluation, and visualization |
| *(report file — add here once uploaded)* | Full project write-up |

> **Note:** `Clustering_Code.txt` was an earlier draft of the same script and can be
> removed to avoid duplication — `Clustering_Project_Code.R` is the file to run.

## Requirements

```r
install.packages(c(
  "readxl", "corrgram", "HDclassif", "cluster", "mclust",
  "nnet", "class", "tree", "dplyr", "readr", "ggplot2",
  "purrr", "reshape2", "factoextra", "corrplot", "gridExtra"
))
```

## Usage

1. Place `greek_data.xls` in the same folder as the script (or update the `path`
   variable near the top of `Clustering_Project_Code.R` to point to your local copy).
2. Run the script:

   ```r
   source("Clustering_Project_Code.R")
   ```

3. The script will:
   - Load and clean the census data (renaming columns, filtering to municipality-level
     rows, converting counts to frequencies)
   - Compute Mahalanobis, Euclidean, Manhattan, and Gower distance matrices
   - Fit hierarchical clustering models (Ward, Complete, Single, Average linkage) and
     plot dendrograms
   - Evaluate solutions via silhouette width and Wilks' Lambda across k = 2–15 clusters
   - Visualize per-cluster age distributions and PCA projections
   - Fit a Gaussian Mixture Model and compare it to the hierarchical solution via ARI

> **Note:** the script reads data from a hardcoded local path
> (`C://Users//kosti//OneDrive//...`) — update this to a relative path before running
> on another machine.

## Author

Konstantinos Grammenos · MSc in Statistics, AUEB
