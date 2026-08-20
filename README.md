# Corpus Linguistics - Study 1 - Sara

## Phase 1 - Data Collection and Sampling

Phase 1 prepares the human-authored short story corpus for later comparison with AI-generated texts.

The initial source corpus is based on the [4000 stories with sentiment analysis dataset](https://brunel.figshare.com/articles/dataset/4000_stories_with_sentiment_analysis_dataset/7712540?file=14357549). The dataset was loaded, cleaned, and reduced to the metadata and text fields needed for the study: `url`, `title`, `author`, and `story`. Each story was assigned a unique `story_id` using the pattern `4000_story_0001`, `4000_story_0002`, etc.

Additional contemporary short stories by selected authors were also incorporated. Their metadata was parsed from filenames to identify `title`, `collection_title`, and `author`, and each text was assigned its own `story_id`.

All stories were exported as individual `.txt` files, then normalized by replacing curly quotation marks and apostrophes with straight equivalents. Word counts were calculated from the normalized files and added to the combined metadata table.

The two story sources were merged into a single `df_short_stories` metadata table. The resulting table includes story metadata, word counts, source file paths, and selection flags. To control for text length, the interquartile range (IQR) of `word_count` was calculated, and stories within the IQR were marked. A balanced sample was then selected by author: all authors with 13 or fewer IQR-filtered stories were fully retained, while authors with more than 13 eligible stories were randomly sampled down to 13 stories.

The final Phase 1 outputs include:

- `short_stories.ndjson`
- `short_stories.tsv`
- `short_stories.xlsx`
- normalised text files for the selected human-authored stories copied into `cl_st1_ph2_sara/corpus/01_human/`

## Phase 2 - Traditional Multi-dimensional Analysis of the human-authored and AI-generated subcorpora to identify variations of style

Phase 2 uses the selected human-authored short story corpus prepared in Phase 1 as the basis for constructing two aligned LLM-generated subcorpora. These generated subcorpora are designed to mirror the human-authored subcorpus on a story-by-story basis for later comparison using Traditional / Functional Multi-dimensional Analysis.

The LLM generation workflow is implemented by `generate_llm_short_story.py` and uses GPT through the OpenAI API. The chosen LLM model for the generation workflow was:
```plain text
gpt-5.6-sol
```
The same model is used across all stages of the workflow: plot extraction, style-profile extraction, plot/style-guided story generation, and free story generation.

For each human-authored short story in `cl_st1_ph2_sara/corpus/01_human/`, the programme creates two corresponding LLM-generated stories:

1. a plot/style-guided LLM story;
2. a free-generated LLM story.

The plot/style-guided LLM subcorpus is stored in:
```plain text
cl_st1_ph2_sara/corpus/03_llm/
```
The free-generation LLM subcorpus is stored in:
```plain text
cl_st1_ph2_sara/corpus/04_llm_free/
```
Intermediate plot and style-profile files are stored in:
```plain text
cl_st1_ph2_sara/corpus/02_plot_style/
```
The programme follows a four-stage workflow for each human-authored short story:

1. **Plot extraction**  
   The original human-authored story is submitted to GPT using an external plot-extraction prompt template. The extracted plot is saved as a `.txt` file in `corpus/02_plot_style/`.

2. **Style-profile extraction**  
   The original human-authored story is submitted to GPT using an external style-profile extraction prompt template. The extracted style profile is saved as a `.txt` file in `corpus/02_plot_style/`.

3. **Plot/style-guided LLM short-story generation**  
   The programme retrieves the target `word_count` for the corresponding human-authored story from the Phase 1 metadata file, `cl_st1_ph1_sara/corpus/short_stories.ndjson`. The generation request is then constructed from the extracted plot, the extracted style profile, the rendered generation prompt containing the target word count, and neutral traceability metadata. The original human-authored story is not submitted to the generation-stage request. The generated story is saved in `corpus/03_llm/`.

4. **Free LLM short-story generation**  
   The free-generation story is produced from a self-contained free-generation prompt only. This request does not include the original human-authored story, the extracted plot, the extracted style profile, or the metadata-derived word count. The generated story is saved in `corpus/04_llm_free/`.

This workflow enforces segregation between extraction and generation stages. The plot/style-guided generation request is a fresh, stateless request that does not reuse the original story or the extraction-stage context. The free-generation request is also fresh and stateless, and is based only on the free-generation prompt template.

For each input file:
```plain text
corpus/01_human/<BASENAME>.txt
```
the programme writes the following outputs:
```plain text
corpus/02_plot_style/<BASENAME>_plot.txt
corpus/02_plot_style/<BASENAME>_style.txt
corpus/03_llm/<BASENAME>_llm.txt
corpus/03_llm/<BASENAME>_llm.json
corpus/04_llm_free/<BASENAME>_llm_free.txt
corpus/04_llm_free/<BASENAME>_llm_free.json
```
Per-story JSON metadata records the model used, prompt-template paths and hashes, metadata matching information, target word count for the plot/style-guided pathway, output paths and hashes, stage statuses, and the segregation status of the LLM calls.

Run-level logs and manifests are written to:
```plain text
cl_st1_ph2_sara/corpus/03_llm/
```
including:
```plain text
generate_llm_short_story.log
generate_llm_short_story_manifest.json
generate_llm_short_story_manifest_<RUN_ID>.json
```
The resulting Phase 2 corpus structure therefore contains three aligned subcorpora:

- the human-authored subcorpus in `corpus/01_human/`;
- the plot/style-guided LLM subcorpus in `corpus/03_llm/`;
- the free-generation LLM subcorpus in `corpus/04_llm_free/`.
