# Corpus Linguistics - Study 1 - Sara

## Phase 1 - Data Collection

Extract a sample of 1000 texts from the [4000 stories with sentiment analysis dataset](https://brunel.figshare.com/articles/dataset/4000_stories_with_sentiment_analysis_dataset/7712540?file=14357549) balanced across `author`.

## Phase 2 - LLM Prompt Engineering

The following prompts have been successfully tested with GPT:

1. Plot extraction prompt

`The attached file is a short story. Extract its plot. Do not include the title in your answer. Also, do not acknowledge this prompt, just provide the answer straightaway.`

2. Style profile extraction prompt

`The attached file is a short story. Extract its style profile. Organise your answer using running text. Also, do not acknowledge this prompt, just provide the answer straightaway.`

3. Story writing prompt

`Use the attached plot and style information to write a short story considering a length closer to *** words, just provide the answer straightaway.`
