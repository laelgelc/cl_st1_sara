# Corpus Linguistics - Study 1 - Sara  
# Phase 2 Manual Pipeline

This document records the manual commands used to run the Phase 2 short-story generation pipeline.

It is not intended to be executed as a shell script. Commands should be copied and pasted into the terminal one stage at a time.

## 1. Working directory

Run all commands from the Phase 2 project directory:

```shell script
cd ~/PycharmProjects/cl_st1_sara/cl_st1_ph2_sara
```


If running locally from a different clone location, enter the equivalent `cl_st1_ph2_sara` directory before running the commands.

## 2. Pipeline overview

The current Phase 2 workflow creates an LLM-generated short-story subcorpus that mirrors the human-authored subcorpus story by story.

| Stage | Purpose                                                                      | Programme                     | Main output directories                   |
|------:|------------------------------------------------------------------------------|-------------------------------|-------------------------------------------|
|     1 | Extract plot, extract style profile, and generate mirrored LLM short stories | `generate_llm_short_story.py` | `corpus/02_plot_style/`, `corpus/03_llm/` |

## 3. General notes

- The human-authored subcorpus is expected in:

```plain text
corpus/01_human/
```


- The programme reads Phase 1 metadata from:

```plain text
../cl_st1_ph1_sara/corpus/short_stories.ndjson
```


- Prompt templates are read from:

```plain text
generate_short_story_prompts/
```


- The OpenAI API key should be available through:

```plain text
env/.env
```


or through the process environment.

- Existing successful outputs are skipped by default unless `--reprocess` is used.
- Test mode is enabled by default.
- Use full mode only after confirming that test outputs are correct.
- Do not commit, print, or paste API keys into source files, logs, or pipeline documents.

## 4. Environment setup reminder

Activate the Phase 2 environment, if applicable:

```shell script
conda env create -f env/condaenv.yaml
conda activate cl_st1_ph2_sara
```


If the environment already exists:

```shell script
conda activate cl_st1_ph2_sara
```


Check that the `.env` file exists:

```shell script
ls env/.env
```


If needed, create it from the template and add the API key manually:

```shell script
cp env/.env_template env/.env
```


Do not print the API key to the terminal.

## 5. Stage 1 — Generate mirrored LLM short stories

### Purpose

For each human-authored short story, the programme:

1. extracts the plot;
2. extracts the style profile;
3. retrieves the corresponding `word_count`;
4. generates a mirrored LLM short story using only the extracted plot, extracted style profile, and target word count.

### Default test run

```shell script
python generate_llm_short_story.py
```


### Explicit one-story test run

```shell script
python generate_llm_short_story.py --test-limit 1
```


### Full run

```shell script
python generate_llm_short_story.py --no-test-mode
```


### Resume from a specific story

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --start-filename "Apollo - Chimamanda Ngozi Adichie.txt"
```


### Force reprocessing

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --reprocess
```


### Use a different GPT model

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --model gpt-5.6-terra
```


### Use newer prompt-template versions

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --plot-prompt-template generate_short_story_prompts/extract_plot_v2.md \
  --style-prompt-template generate_short_story_prompts/extract_style_v2.md \
  --generation-prompt-template generate_short_story_prompts/generate_short_story_v2.md
```


### Use a non-default environment file

```shell script
python generate_llm_short_story.py \
  --env-file env/.env_production
```


### Expected outputs

Plot and style-profile outputs:

```plain text
corpus/02_plot_style/<BASENAME>_plot.txt
corpus/02_plot_style/<BASENAME>_style.txt
```


Generated LLM short stories and metadata:

```plain text
corpus/03_llm/<BASENAME>_llm.txt
corpus/03_llm/<BASENAME>_llm.json
```


Run-level outputs:

```plain text
corpus/03_llm/generate_llm_short_story.log
corpus/03_llm/generate_llm_short_story_manifest.json
corpus/03_llm/generate_llm_short_story_manifest_<RUN_ID>.json
```


## 6. Smoke test sequence

Run this before the full corpus:

```shell script
conda activate cl_st1_ph2_sara
cd ~/PycharmProjects/cl_st1_sara/cl_st1_ph2_sara

python generate_llm_short_story.py --test-limit 1
```


After the smoke test, inspect:

```shell script
find corpus/02_plot_style corpus/03_llm -maxdepth 1 -type f | sort | head
```


A successful smoke test should produce:

- one `_plot.txt` file;
- one `_style.txt` file;
- one `_llm.txt` file;
- one `_llm.json` metadata file;
- a run log;
- a run manifest.

## 7. Full production run sequence

Run this only after the smoke test succeeds.

Use `tmux` for long runs:

```shell script
tmux new -s sara_phase2_generation
```


Inside the session:

```shell script
conda activate cl_st1_ph2_sara
cd ~/PycharmProjects/cl_st1_sara/cl_st1_ph2_sara

python generate_llm_short_story.py --no-test-mode
```


Detach from `tmux`:

```plain text
Ctrl+B
D
```


Reattach:

```shell script
tmux attach -t sara_phase2_generation
```


## 8. Resume and reprocess patterns

### Resume from a specific story

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --start-filename "Apollo - Chimamanda Ngozi Adichie.txt"
```


### Reprocess the full generation stage

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --reprocess
```


## 9. Basic output inspection

List generated plot/style files:

```shell script
find corpus/02_plot_style -maxdepth 1 -type f | sort | head
```


List generated LLM stories:

```shell script
find corpus/03_llm -maxdepth 1 -type f | sort | head
```


Inspect the run manifest:

```shell script
sed -n '1,220p' corpus/03_llm/generate_llm_short_story_manifest.json
```


Check output directory sizes:

```shell script
du -sh corpus/02_plot_style corpus/03_llm
```


## 10. Manual run log

| Date       | Stage      | Command                                                         | Notes                                       |
|------------|------------|-----------------------------------------------------------------|---------------------------------------------|
| YYYY-MM-DD | Smoke test | `python generate_llm_short_story.py --test-limit 1`             | Initial one-story test                      |
| YYYY-MM-DD | Full run   | `python generate_llm_short_story.py --no-test-mode`             | Full LLM short-story generation             |
| YYYY-MM-DD | Reprocess  | `python generate_llm_short_story.py --no-test-mode --reprocess` | Reprocess after prompt or programme changes |