# ============================================================
# Project pipeline for CL-ST1 Phase 2
#
# Run this script from the project phase directory, e.g.:
#
#   cl_st1_ph2_sara/
#
# The pipeline prepares the corpus, selects keywords, builds the
# SAS input files, generates post-SAS factor outputs, creates
# visualisations and examples, and finally prepares/interprets
# factor-pole prompts.
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
# Run SAS
# ------------------------------------------------------------


# ------------------------------------------------------------
# 8. Build factor loading lists
#
# Reads SAS factor outputs and produces readable positive/negative
# loading lists for each factor.
# ------------------------------------------------------------

python factor_lists.py
# Output: factors/


# ------------------------------------------------------------
# 9. Calculate corpus size summaries
#
# Produces corpus-size metadata for reporting and checking balance
# across decades.
# ------------------------------------------------------------

python corpus_size.py
# Output: corpus_size/corpus_size.tsv


# ------------------------------------------------------------
# 10. Generate LaTeX/TikZ boxplots
#
# Creates one boxplot per factor dimension and a combined mosaic
# for use in slides or reports.
# ------------------------------------------------------------

cd latex_boxplots

python latex_boxplots.py
# Output: latex_boxplots/slides/

cd ..


# ------------------------------------------------------------
# 11. Generate LaTeX ANOVA table
#
# Summarises decade effects for each factor using F, p, R², and
# percent R².
# ------------------------------------------------------------

python latex_anova_table.py
# Output: latex_tables/anova_decade.tex


# ------------------------------------------------------------
# 12. Generate LaTeX example extracts
#
# Selects representative high-scoring texts by factor pole and
# decade, then writes LaTeX examples with factor-loading lemmas
# highlighted.
# ------------------------------------------------------------

python examples.py
# Output: examples/


# ------------------------------------------------------------
# 13. Generate score-details report
#
# Sanity-check report showing, for each text and factor, which
# positive- and negative-pole loading words are present.
# ------------------------------------------------------------

python score_details.py
# Output: examples/score_details.txt


# ------------------------------------------------------------
# 14. Generate plaintext example extracts
#
# Produces plain `.txt` versions of the selected examples, including
# score metadata and loading words. These are useful for manual review
# and for building interpretation prompts.
# ------------------------------------------------------------

python examples_txt.py
# Output: examples_txt/


# ------------------------------------------------------------
# 15. Build interpretation prompts
#
# Combines factor loadings, mean decade scores, plaintext examples,
# and score-details information into one prompt per factor pole.
# ------------------------------------------------------------

python interpretation_prompts.py
# Output: interpretation/input/


# ------------------------------------------------------------
# 16. Submit interpretation prompts to GPT
#
# Sends each prompt file to the configured GPT model and writes one
# response file per factor pole. Requires OPENAI_API_KEY in the
# environment or in env/.env.
# ------------------------------------------------------------

python generate_interpretation_gpt.py \
    --input interpretation/input \
    --output interpretation/output \
    --model gpt-5.5 \
    --workers 4
# Output: interpretation/output/