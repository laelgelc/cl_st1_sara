# Development Specification: `examples_md.py`

## 1. Programme Purpose

`examples_md.py` generates readable Markdown (`.md`) example files for each Traditional Multi-Dimensional Analysis (TMDA) factor pole.

For each factor dimension, the programme selects texts with the most extreme factor scores, grouped and ranked by `prompt` condition (`human`, `llm`, `llm_free`). It writes nicely formatted Markdown files containing:

1. Text source metadata (Prompt, Filepath, Author, Title);
2. The factor-pole score;
3. The loading features associated with that factor pole;
4. The original full text.

The programme is intended to support the qualitative review and interpretation of factor examples without requiring complex tagging reconstruction or LaTeX compilation.

---

## 2. Project Context

The project analyses a short story corpus across three prompt conditions:
```text
human
llm
llm_free
```
The programme is expected to live in the project phase directory as:
```text
examples_md.py
```
By default, the project name is inferred from the current working directory.

Example:
```text
cl_st1_ph2_sara
```
---

## 3. Inputs

### 3.1 SAS Scores File

Default input path:
```text
sas/output_<project>/<project>_scores_only.csv
```
Example:
```text
sas/output_cl_st1_ph2_sara/cl_st1_ph2_sara_scores_only.csv
```
The file must be **comma-separated**.

Required columns:

| Column     | Description                                                  |
|------------|--------------------------------------------------------------|
| `prompt`   | The prompt condition (`human`, `llm`, or `llm_free`)         |
| `filename` | The specific filename (e.g., `4000_story_0004_llm_free.txt`) |
| `f<n>`     | Factor score for dimension `<n>`                             |

The programme detects available factor dimensions from columns matching:
```regex
f\d+
```
### 3.2 Human Metadata NDJSON

Default input path:
```text
../cl_st1_ph1_sara/corpus/short_stories.ndjson
```
This file contains the original story metadata. The programme extracts the `author` and `title` fields using the base `story_id` (e.g., `4000_story_0004`) as the key.

### 3.3 SAS Loadtable

Default input path:
```text
sas/output_<project>/loadtable.html
```
Example:
```text
sas/output_cl_st1_ph2_sara/loadtable.html
```
This file is parsed to extract the linguistic features associated with each factor pole (e.g., "Adverb (excluding other types)", "Emphatics"). The programme uses these features to populate the loading features metadata in the output header.

### 3.4 Full-Text Corpus Directories

Default corpus root:
```text
corpus/
```
The programme routes to specific subcorpora based on the `prompt` value:

- `human` -> `corpus/01_human/<filename>`
- `llm` -> `corpus/03_llm/<filename>`
- `llm_free` -> `corpus/04_llm_free/<filename>`

### 3.5 Command-Line Arguments

The programme must support:
```text
--project
```
Default: current working directory name.
```text
--sas-output-dir
```
Default: `sas/output_<project>`
```text
--corpus-dir
```
Default: `corpus`
```text
--metadata-file
```
Default: `../cl_st1_ph1_sara/corpus/short_stories.ndjson`
```text
--loadtable-file
```
Default: `sas/output_<project>/loadtable.html`
```text
--output-dir
```
Default: `examples_md`
```text
--top-prompt-examples
```
Default: `20` (Quota for the prompt group with the most extreme mean score).
```text
--other-prompt-examples
```
Default: `10` (Quota for the other prompt groups).

---

## 4. Outputs

### 4.1 Output Directory

Default:
```text
examples_md
```
The programme must create this directory if it does not exist.

### 4.2 Per-Factor Pole Directories

For each factor dimension and pole, the programme creates:
```text
examples_md/f<n>_pos/
examples_md/f<n>_neg/
```
Examples:
```text
examples_md/f1_pos/
examples_md/f1_neg/
```
### 4.3 Individual Markdown Example Files

For each selected example, the programme writes one `.md` file.

Filename format:
```text
examples_md/f<n>_<pole>/f<n>_<pole>_<id>.md
```
Example:
```text
examples_md/f1_pos/f1_pos_001.md
```
The example ID must be zero-padded to three digits.

### 4.4 Missing Files Report

If any selected full-text files cannot be located, the programme writes:
```text
missing_files.txt
```
### 4.5 Output Encoding

All generated files must be written using `UTF-8`.

---

## 5. Functional Requirements

### 5.1 Project Inference & Path Resolution

The programme must infer the project name from the current working directory and use it to resolve default paths for SAS outputs and the load table.

### 5.2 Parse Metadata

The programme must load `short_stories.ndjson` into a lookup dictionary.
1. Use `story_id` as the key.
2. For each record, extract `author` and `title`.

### 5.3 Parse SAS Loadtable

The programme must parse `loadtable.html`.
1. Detect factor pole headers (e.g., `Factor 1 pos`, `Factor 1 neg`).
2. Extract the corresponding feature names from the HTML tables (the `_NAME_` column).
3. Store them into a lookup structure, e.g.:
```python
loading_features = {
    "f1_pos": ["Adverb (excluding other types)", "Emphatics", ...],
    "f1_neg": ["Word length", "Passive postnominal modifier", ...]
}
```
### 5.4 Read Scores Data and Calculate Means

The programme must:
1. Read the scores file (`cl_st1_ph2_sara_scores_only.csv`) with pandas.
2. Detect factor score columns matching `f\d+`.
3. Group the data by `prompt` (`human`, `llm`, `llm_free`).
4. Calculate the mean score for each `f<n>` dimension per prompt.

### 5.5 Rank Prompts by Pole

For each factor dimension:
- Positive pole: Rank `prompt` groups by descending mean score.
- Negative pole: Rank `prompt` groups by ascending mean score.

The top-ranked prompt receives the `--top-prompt-examples` quota. The remaining prompts receive the `--other-prompt-examples` quota.

### 5.6 Sort Texts by Factor Score

Within each pole and prompt, texts must be sorted by their corresponding factor score:
- Positive pole: descending score.
- Negative pole: ascending score.

Texts with a factor score of exactly `0` must be skipped.

### 5.7 Locate Full Text and Extract Story ID

For each selected scores row:
1. Extract the base `story_id` from the `filename` by stripping `_llm_free.txt`, `_llm.txt`, or `.txt`. (e.g., `4000_story_0004`).
2. Construct the full-text path dynamically based on the `prompt`:
    - `human` -> `corpus/01_human/<filename>`
    - `llm` -> `corpus/03_llm/<filename>`
    - `llm_free` -> `corpus/04_llm_free/<filename>`

If the file cannot be located, record it in `missing_files.txt` and continue.

### 5.8 Author and Title Prefixing

Using the base `story_id` to retrieve the original `Author` and `Title` from the metadata lookup, apply the following formatting rules:

- If `prompt == human`: keep original author and title.
- If `prompt == llm`: prefix with `"LLM mirror of "`.
- If `prompt == llm_free`: prefix with `"LLM free mirror of "`.

### 5.9 Write Markdown Example

Each Markdown example must follow the exact layout:
```markdown
**Prompt:** <prompt>
**Filepath**: corpus/<prompt_folder>/<filename>
**Author**: <formatted_author>
**Title:** <formatted_title>
**Score (<label>):** <score_rounded_to_2_decimals>
**Loading features (<label>), N=<count>:** <comma_separated_features>

---

<raw_text_content>
```
---

## 6. Output Content Requirements

### 6.1 Example Environment

#### Case 1: `prompt` = `human`
```markdown
**Prompt:** human
**Filepath**: corpus/01_human/4000_story_0004.txt
**Author**: Achmed Abdullah
**Title:** An Indian Jataka
**Score (f1_pos):** 11.24
**Loading features (f1_pos), N=17:** Adverb (excluding other types), Emphatics, Modals of prediction or volition, ...

---

By the time Mara Venn reached Bellweather...
```
#### Case 2: `prompt` = `llm`
```markdown
**Prompt:** llm
**Filepath**: corpus/03_llm/4000_story_0004_llm.txt
**Author**: LLM mirror of Achmed Abdullah
**Title:** LLM mirror of An Indian Jataka
**Score (f1_pos):** 1.10
**Loading features (f1_pos), N=17:** Adverb (excluding other types), Emphatics, Modals of prediction or volition, ...

---

The clockmaker struck the bell...
```
#### Case 3: `prompt` = `llm_free`
```markdown
**Prompt:** llm_free
**Filepath**: corpus/04_llm_free/4000_story_0004_llm_free.txt
**Author**: LLM free mirror of Achmed Abdullah
**Title:** LLM free mirror of An Indian Jataka
**Score (f1_pos):** -5.36
**Loading features (f1_pos), N=17:** Adverb (excluding other types), Emphatics, Modals of prediction or volition, ...

---

Mara Vale first heard the rain...
```
---

## 7. Error Handling Requirements

- **Missing Scores File / Directories:** Raise `FileNotFoundError`.
- **Missing NDJSON Metadata:** Raise `FileNotFoundError`.
- **Missing Loadtable:** Warn and leave the loading features section empty if `loadtable.html` cannot be parsed, or raise `FileNotFoundError` if the file doesn't exist.
- **Missing Factor Columns:** Raise `RuntimeError` if no `f\d+` columns are found in the CSV.
- **Missing Text Files:** Do not crash; record the missing `filename` in `missing_files.txt` and move to the next text.

---

## 8. Non-Functional Requirements

- **Encoding:** Read and write all files using `UTF-8`.
- **Determinism:** Factor dimensions and selection logic must be deterministic.
- **Dependencies:** Uses `pandas` and standard library modules (`argparse`, `pathlib`, `json`, `re`, `html.parser` or `BeautifulSoup` for the load table). No external processes are required.

---

## 9. Downstream Usage

The generated Markdown files are intended for manual review in any standard text editor or Markdown viewer. They facilitate checking whether the full text supports the stylometric interpretation of the factor pole without requiring LaTeX tooling.

---

## 10. Summary

`examples_md.py` extracts readable Markdown examples for interpreting TMDA factor dimensions. 

It drops the complex intra-text tag highlighting, replacing it with a robust pipeline that directly calculates prompt-group means from the CSV, maps texts to their raw source folders based on the prompt condition, matches metadata from the original dataset, and extracts the primary linguistic features dynamically from the SAS HTML load table.
