# ============================================================
# Project pipeline for cl_st1_ph2_sara
#
# Run this script from the project phase directory, e.g.:
#
#   cl_st1_ph2_sara/
#
# ============================================================

# ------------------------------------------------------------
# 1. Generate the LLM short stories
#
# ------------------------------------------------------------

## One-story smoke test

python generate_llm_short_story.py \
    --test-limit 1
# Outputs:
# corpus/02_plot_style/<BASENAME>_plot.txt
# corpus/02_plot_style/<BASENAME>_style.txt
# corpus/03_llm/<BASENAME>_llm.txt
# corpus/03_llm/<BASENAME>_llm.json
# corpus/04_llm_free/<BASENAME>_llm_free.txt
# corpus/04_llm_free/<BASENAME>_llm_free.json

## Production run

python generate_llm_short_story.py \
    --no-test-mode

### Force a fresh run
python generate_llm_short_story.py \
    --no-test-mode \
    --reprocess


# ------------------------------------------------------------
# 2. Prepare the corpus for tagging with Biber Tagger
#
# ------------------------------------------------------------

python prepare_for_biber_tagger.py \
    --input-dir corpus/01_human \
    --output-dir corpus/05_tagged/01_human_prep

python prepare_for_biber_tagger.py \
    --input-dir corpus/03_llm \
    --output-dir corpus/05_tagged/03_llm_prep

python prepare_for_biber_tagger.py \
    --input-dir corpus/04_llm_free \
    --output-dir corpus/05_tagged/04_llm_free_prep


# ------------------------------------------------------------
# 3. Run SAS
# ------------------------------------------------------------


# ------------------------------------------------------------
# 4. Generate Markdown example extracts
#
# ------------------------------------------------------------

python examples_md.py
# Output: examples_md/


# ------------------------------------------------------------
# 5. Generate Markdown ANOVA table
#
# ------------------------------------------------------------

python anova_table_md.py
# Output: anova_table_md/
