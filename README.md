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