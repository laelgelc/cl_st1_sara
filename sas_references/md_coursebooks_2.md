# Development Specification: `md_coursebooks.sas`

## 1. Overview
The `md_coursebooks.sas` script is a comprehensive SAS program designed to perform a Multi-Dimensional (MD) analysis on a linguistic corpus. Drawing upon Biber's framework of linguistic features, the script processes feature frequency counts, conducts exploratory and rotated factor analyses, calculates factor scores, and executes a suite of subsequent statistical procedures including ANOVAs, clustering, and Discriminant Function Analysis (DFA).

## 2. Configuration Parameters
The script relies on several global macro variables to configure the analysis:
*   **`project`**: Set to `group1`, functioning as the base name for primary datasets and file exports.
*   **`extractfactors`**: The number of factors to extract during the final rotation (set to `9`).
*   **`minloading`**: The minimum loading threshold (set to `0.3`) for a variable to be considered "loaded" onto a factor.
*   **`communalcutoff`**: The minimum communality threshold (set to `0.15`). Variables with communalities below this are dropped.

## 3. Workflow Specification

### 3.1. Data Ingestion and Preprocessing
*   Reads the primary frequency counts from a text file (`group1_counts.txt`).
*   The data structure includes file metadata (e.g., filename), general metrics (TTR, word length, word count), and detailed normalized counts for dozens of linguistic features (e.g., private verbs, amplifiers, nominalizations).
*   Corrects specific filename anomalies (e.g., specific `chicagopd` episodes).
*   Drops predetermined overarching dimension variables and base summary variables before factoring.

### 3.2. Initial Factor Analysis & Communality Trimming
*   Runs an initial unrotated principal factor analysis calculating up to 100 factors to estimate prior communalities (SMC) and eigenvalues.
*   Transposes the communality outputs and drops any linguistic variable failing to meet the `&communalcutoff` threshold (0.15).
*   Generates a Scree Plot to visually assist in confirming the number of viable factors.

### 3.3. Promax Rotation & Sum Variable Check
*   Conducts a preliminary Promax-rotated factor analysis (using `&extractfactors`).
*   Evaluates the loading strength and polarity of each variable across the extracted factors based on the `&minloading` cutoff.
*   Reconstructs summary variables (e.g., `allmodal`, `allpasv`, `allwh`) from the remaining variables. If a category no longer has enough constituent variables meeting the minimum criteria, the summary variable is zeroed out to prevent redundancy.
*   Drops un-loaded variables and redundant sum components prior to the final analysis.

### 3.4. Final Factor Analysis and Interpretation
*   Executes the final Promax rotation on the cleaned dataset.
*   Maps variables to specific linguistic labels using a predefined `PROC FORMAT` dictionary.
*   Produces sorted loading tables for positive and negative poles of each factor to aid qualitative interpretation.

### 3.5. Factor Scoring and Outlier Removal
*   Standardizes the raw counts (Mean=0, STD=1).
*   Applies the derived scoring coefficients to the standardized data to generate factor scores (`f1` to `f9`) for each text.
*   Calculates the Interquartile Range (IQR) for each factor.
*   Removes text outliers that fall beyond `1.5 * IQR` (configured using multiplier `1`) to prepare a refined dataset for group comparisons.

### 3.6. Statistical Comparisons and Group Analysis
*   **ANOVA & Duncan's MRT**: Analyzes variance across metadata categories (e.g., `countrycode`, `locale`, `native`). Uses Waller-Duncan multiple range tests to group significance across L1 backgrounds.
*   **Correlations**: Integrates output from TAALED (e.g., lexical diversity metrics) and correlates them with the factor scores using Pearson correlation. Additional correlations are run against demographic metadata (e.g., age, years studying English).
*   **Clustering**: 
    *   *K-Means (`FASTCLUS`)*: Computes cluster assignments for the texts based on factors 1 and 2.
    *   *Hierarchical (`CLUSTER` method=ward)*: Groups texts using Ward's minimum-variance method, generating dendrograms, CCC (Cubic Clustering Criterion), and Pseudo-F statistics to evaluate cluster quality. Canonical discriminant analysis charts the clusters.
*   **Discriminant Function Analysis (DFA)**: 
    *   Performs stepwise discriminant analysis to identify which specific linguistic features best predict the target class (e.g., `countrycode`).
    *   Cross-validates the classification to generate confusion matrices.

### 3.7. Additive / Comparison Analysis
*   Merges the primary corpus data with a secondary comparison corpus (`group1_comparison_counts.txt`).
*   Runs size/descriptive statistics and an overarching Discriminant Function Analysis over existing `dim1-dim5` variables between different registers (`fic`, `spo`, `ess`) to evaluate corpus alignment and classification overlaps.
*   Concludes with a Mixed Model analysis testing fixed effects while accounting for random effects (e.g., `locale`, `native`, `gender`).

## 4. Output Artifacts
The script automatically exports extensive artifacts to the designated project folder:
*   `.csv` extracts: dropped communalities, raw factor scores, outlier lists, TAALED merges, loading tables, and cluster solutions.
*   `.html` files: SAS ODS results including DFA summaries, ANOVA results, TAALED correlations.
*   `.png` graphical plots: Scree plots, boxplots, Waller-Duncan bar charts, hierarchical dendrograms, and clustering scatter plots.