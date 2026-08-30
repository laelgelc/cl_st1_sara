# Methodological Framework: Traditional and Additive Multi-Dimensional Analysis

## 1. Overview
The study employs a Multi-Dimensional Analysis (MDA) framework to identify and compare dimensions of linguistic variation across human-authored and LLM-generated short stories. The analytical pipeline consists of two primary phases: a Traditional MDA to establish the dimensional space based on a base corpus, followed by an Additive MDA to map a new, guided LLM-generated register onto this established multi-dimensional space. 

## 2. Data Ingestion and Preparation
The dataset comprises linguistic feature counts for three distinct subcorpora:
*   **Human-Authored Subcorpus** (`source: human`, `prompt: human`)
*   **LLM-Free Subcorpus** (`source: ai`, `prompt: llm_free`)
*   **LLM-Guided Subcorpus** (`source: ai`, `prompt: llm`)

To establish the foundational multi-dimensional space, the Human and LLM-Free subcorpora are combined to form the **Base Corpus**. The LLM-Guided subcorpus is held out as an **Additive Corpus**. Legacy variables (such as pre-calculated 1988 Biber dimensions and redundant summary variables) are excluded from the dataset prior to statistical processing to prevent collinearity and distortion.

## 3. Factor Extraction (Traditional MDA)
Factor analysis is conducted exclusively on the Base Corpus to define the underlying dimensions of variation. 

**3.1. Unrotated Factor Analysis and Communality Cutoff**
An initial, unrotated principal component analysis is performed to evaluate the variance captured by the linguistic features. Variables demonstrating low shared variance—specifically those with communality estimates below **0.15**—are excluded from the final model to ensure robustness. A scree plot of eigenvalues is also generated to visually assess the optimal number of factors.

**3.2. Rotated Factor Analysis**
A final factor analysis is performed on the remaining variables using Principal Component extraction and a **Promax (oblique)** rotation. Based on the study's parameters, exactly **9 factors** are extracted. 

Features are assigned to a specific factor based on their highest absolute loading, with a minimum inclusion threshold of **0.30**. Variables that load on multiple factors are strictly assigned to the factor where their loading is mathematically highest, maintaining orthogonal clarity in the final scoring. Both positive and negative poles are identified for each factor.

## 4. Additive Multi-Dimensional Analysis and Scoring
To directly compare the LLM-Guided subcorpus with the established base dimensions, an Additive MDA approach is utilized. 

**4.1. Standardization**
The raw linguistic counts of the Base Corpus are standardized to z-scores (mean = 0, standard deviation = 1). Crucially, to ensure a valid comparison, the features of the Additive Corpus (LLM-Guided) are standardized *using the exact mean and standard deviation parameters derived from the Base Corpus*.

**4.2. Dimension Scoring**
Following Biber’s (1988) methodology, dimension scores for each text across all subcorpora are calculated based on the standardized z-scores. For any given text on a given factor, the dimension score is computed by summing the z-scores of the features that loaded on the positive pole, and subsequently subtracting the summation of the z-scores of the features that loaded on the negative pole. 

## 5. Outlier Treatment
The methodology includes a robust framework for identifying and handling outliers across the calculated dimension scores. Outliers are defined quantitatively using the Interquartile Range (IQR) method (specifically, outside the Q1 - 1*IQR to Q3 + 1*IQR boundaries). 

*Note on Bypass:* Depending on the analytical goal—particularly when evaluating AI-generated texts where extreme stylometric deviations may be linguistically significant rather than mere statistical noise—the pipeline includes an explicit bypass to retain outliers in the final dataset for statistical testing.

## 6. Statistical Analysis and Visualization
To determine whether significant differences in linguistic variation exist between the different subcorpora, the combined dimension scores (spanning both the Base and Additive corpora) are analyzed using General Linear Models (GLMs).

*   **ANOVAs** are executed to test the main effects of the independent variables (`prompt` and `source`) and their interaction (`prompt*source`) on each of the 9 extracted dimensions. 
*   **Boxplots** are dynamically generated for each dimension to visually evaluate the distribution, median, and variance of the dimension scores across the different prompt conditions.