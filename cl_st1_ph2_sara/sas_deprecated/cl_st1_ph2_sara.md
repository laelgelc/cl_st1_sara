# Development Specification: `cl_st1_ph2_sara.sas`

## 1. Overview and Objectives
The `cl_st1_ph2_sara.sas` script executes a hybrid statistical pipeline combining Traditional Multi-Dimensional Analysis (MDA) and Additive Multi-Dimensional Analysis. The objective is to identify and compare dimensions of linguistic variation between human-authored short stories and two AI-generated subcorpora (LLM-Free and LLM-Guided). 

The pipeline ingests raw linguistic feature counts (Biber Tagger outputs), extracts underlying stylistic factors from a foundational "Base Corpus", and maps the LLM-Guided texts onto this dimensional space using an additive scoring methodology. It concludes with statistical evaluation (ANOVA) and automated output packaging.

## 2. Environment and Parameters
*   **Target Environment:** SAS Studio (Online).
*   **Working Directory:** Configured via macro variables (`&whereisit/&myfolder`).
*   **Libraries:** Uses the default `WORK` library for temporary table manipulation and `gelc` for persistent references.
*   **Key Analytical Parameters:**
    *   `extractfactors`: 4 (Number of dimensions to extract).
    *   `minloading`: 0.3 (Minimum factor loading threshold for feature inclusion).
    *   `communalcutoff`: 0.15 (Minimum shared variance/communality threshold).

## 3. Data Ingestion (Section 2)
The script ingests three fixed-width text files containing normalized frequency counts of linguistic features:
1.  **Human-Authored Subcorpus** (`01_human_counts.txt`): Assigned `prompt = 'human'`, `source = 'human'`.
2.  **LLM-Free Subcorpus** (`04_llm_free_counts.txt`): Assigned `prompt = 'llm_free'`, `source = 'ai'`.
3.  **LLM-Guided Subcorpus** (`03_llm_counts.txt`): Assigned `prompt = 'llm'`, `source = 'ai'`.

*Note: Character variables `prompt` and `source` are explicitly initialized with `length $10` to prevent truncation during concatenation.*

## 4. Processing Pipeline

### 4.1. Base Corpus Preparation (Section 3)
*   **Base Corpus Formulation:** The Human and LLM-Free subcorpora are combined via `SET` to form the `base_corpus`. This establishes the baseline stylistic dimensional space.
*   **Additive Corpus:** The LLM-Guided texts form the `add_corpus`.
*   **Variable Filtering:** Pre-existing 1988 Biber dimensions (`dim1-dim5`) and certain variables (`pub_vb`, `prv_vb`, and specific summary aggregations) are dropped before factor extraction. Initial dataset snapshots are exported to CSV.

### 4.2. Unrotated Factor Analysis & Communalities (Section 4)
*   **Procedure:** `PROC FACTOR` (Principal Components, `mineigen=0`, `priors=smc`).
*   **Communality Cutoff:** Identifies variables with communality scores below `0.15`. These low-variance variables are dropped from the active dataset.
*   **Output:** Generates a Scree plot (`scree.png`) and an export of dropped variables (`communalities_dropped.csv`).

### 4.3. Initial Rotated Factor Analysis & Selection (Section 5)
*   **Procedure:** `PROC FACTOR` with Promax (oblique) rotation.
*   **Feature Assignment Rule:** A feature is assigned to a factor (1 through 4) based on its maximum absolute loading, provided it meets the `0.30` threshold.
*   **Summary Variable Check:** Evaluates aggregated variables (e.g., `allmodal`, `allpasv`). If individual constituent features load heavily, the summary variable is retained or dropped dynamically using a programmatic check (`loaded = 0` vs `loaded = 1`). 

### 4.4. Final Rotated Model & Loadings Table (Section 6)
*   **Final Extraction:** Re-runs the Promax rotation on the strictly filtered variable list.
*   **Formatting:** Applies a custom format (`PROC FORMAT $featurelabels`) to translate short variable names (e.g., `abstrcn`) into human-readable descriptions (e.g., "Abstract nouns").
*   **Loadings Output:** Generates structured HTML and CSV loading tables (`loadtable_for_interpretation.csv`), separating primary and secondary loadings on both positive and negative poles for all 4 extracted factors. 

### 4.5. Additive Scoring (Section 7)
*   **Base Corpus Standardization:** Uses `PROC STDIZE` to calculate z-scores for the Base Corpus, saving the statistical profiles (means/std devs) to `meta_stats`.
*   **Additive Corpus Standardization:** Applies the exact `meta_stats` from the Base Corpus to standardize the Additive Corpus, ensuring both reside on identical axes.
*   **Scoring:** `PROC SCORE` multiplies the standardized counts by the rotated factor pattern to produce dimension scores (`f1-f4`).
*   **Score Aggregation:** Generates base-only, additive-only, and combined CSV exports for the calculated scores.

### 4.6. Outlier Identification (Section 8)
*   **Method:** Interquartile Range (IQR) fence method (Multiplier: 1.0).
*   **Identification:** Flags texts lying outside the upper/lower bounds for any of the 4 factors and outputs the lists to CSV.
*   **Bypass:** The script implements a deliberate bypass (`data &project._no_outliers; set scores_combined; run;`) that explicitly retains outliers for the final statistical analysis, given the analytical significance of AI-generated extremes.

## 5. Statistical Analysis & Visualization (Section 9)
*   **General Linear Models (ANOVA):** Runs `PROC GLM` on the combined scores dataset.
    *   *Model:* `f&i = prompt source prompt*source`
    *   Extracts Fit Statistics, Overall ANOVA tables, and Means to HTML (`glm_meta.html`).
*   **Boxplots:** Generates `PROC SGPLOT` (via GLM graphics) boxplots for each factor by `prompt`, outputting as `.png` files.

## 6. Output Packaging and Cleanup
*   **ZIP Archive:** A custom `DATA _NULL_` routine recursively iterates through the working directory and compresses all relevant outputs into a single ZIP file (`output_cl_st1_ph2_sara.zip`).
*   **Garbage Collection:** Post-compression, an automated cleanup routine reads the directory and issues `FDELETE` commands to wipe the raw `.png`, `.html`, `.tsv`, and `.csv` files, leaving the environment clean with only the bundled `.zip` and base SAS scripts remaining.