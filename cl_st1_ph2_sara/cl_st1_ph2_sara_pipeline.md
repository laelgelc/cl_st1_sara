# Corpus Linguistics - Study 1 - Sara  
# Phase 2 Pipeline

This document records the main commands for running the Phase 2 short-story generation pipeline.

The pipeline creates two LLM-generated subcorpora aligned with the human-authored subcorpus:

| Output | Purpose | Directory |
|---|---|---|
| Plot/style-guided LLM stories | Generated from extracted plot, extracted style profile, and target word count | `corpus/03_llm/` |
| Free-generated LLM stories | Generated from a self-contained free-generation prompt only | `corpus/04_llm_free/` |

Intermediate plot and style-profile files are written to:

```plain text
corpus/02_plot_style/
```


## 1. Working directory

Run commands from the Phase 2 project directory:

```shell script
cd ~/PycharmProjects/cl_st1_sara/cl_st1_ph2_sara
```


If using another clone location, enter the equivalent `cl_st1_ph2_sara` directory.

## 2. Environment

Activate the environment:

```shell script
conda activate cl_st1_ph2_sara
```


If the environment has not been created yet:

```shell script
conda env create -f env/condaenv.yaml
conda activate cl_st1_ph2_sara
```


Ensure the OpenAI API key is available through:

```plain text
env/.env
```


or through the process environment. Do not print or commit the API key.

## 3. Input and output summary

Main inputs:

```plain text
corpus/01_human/
../cl_st1_ph1_sara/corpus/short_stories.ndjson
generate_short_story_prompts/extract_plot_v1.md
generate_short_story_prompts/extract_style_v1.md
generate_short_story_prompts/generate_short_story_v1.md
generate_short_story_prompts/generate_free_short_story_v1.md
```


Main outputs:

```plain text
corpus/02_plot_style/
corpus/03_llm/
corpus/04_llm_free/
```


Existing successful outputs are skipped by default unless `--reprocess` is used.

## 4. Smoke tests

### One-story smoke test

Use this before any larger run:

```shell script
python generate_llm_short_story.py --test-limit 1
```


Expected outputs include:

```plain text
corpus/02_plot_style/<BASENAME>_plot.txt
corpus/02_plot_style/<BASENAME>_style.txt
corpus/03_llm/<BASENAME>_llm.txt
corpus/03_llm/<BASENAME>_llm.json
corpus/04_llm_free/<BASENAME>_llm_free.txt
corpus/04_llm_free/<BASENAME>_llm_free.json
```


### Three-story test

Run this after the one-story smoke test succeeds:

```shell script
python generate_llm_short_story.py --test-limit 3
```


### Force a fresh test run

Use this after code or prompt changes:

```shell script
python generate_llm_short_story.py \
  --test-limit 3 \
  --reprocess
```


## 5. Inspect test outputs

List generated files:

```shell script
find corpus/02_plot_style corpus/03_llm corpus/04_llm_free -maxdepth 1 -type f | sort | head -40
```


Inspect the run manifest:

```shell script
sed -n '1,220p' corpus/03_llm/generate_llm_short_story_manifest.json
```


Check output directory sizes:

```shell script
du -sh corpus/02_plot_style corpus/03_llm corpus/04_llm_free
```


## 6. Production run

Run the full corpus only after the smoke tests are satisfactory.

```shell script
python generate_llm_short_story.py --no-test-mode
```


For long runs, use `tmux`:

```shell script
tmux new -s sara_phase2_generation
```


Inside the session:

```shell script
conda activate cl_st1_ph2_sara
cd ~/PycharmProjects/cl_st1_sara/cl_st1_ph2_sara

python generate_llm_short_story.py --no-test-mode
```


Detach:

```plain text
Ctrl+B
D
```


Reattach:

```shell script
tmux attach -t sara_phase2_generation
```


## 7. Resume or reprocess

Resume from a specific story filename:

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --start-filename "Apollo - Chimamanda Ngozi Adichie.txt"
```


Reprocess the full corpus:

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --reprocess
```


## 8. Optional variants

Use a different GPT model:

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --model gpt-5.6-terra
```


Use newer prompt-template versions:

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --plot-prompt-template generate_short_story_prompts/extract_plot_v2.md \
  --style-prompt-template generate_short_story_prompts/extract_style_v2.md \
  --generation-prompt-template generate_short_story_prompts/generate_short_story_v2.md \
  --free-generation-prompt-template generate_short_story_prompts/generate_free_short_story_v2.md
```


Use a non-default environment file:

```shell script
python generate_llm_short_story.py \
  --env-file env/.env_production
```


Use a non-default free-output directory:

```shell script
python generate_llm_short_story.py \
  --llm-free-dir corpus/04_llm_free_alt
```


## 9. Run-level outputs

Run-level logs and manifests are written to:

```plain text
corpus/03_llm/generate_llm_short_story.log
corpus/03_llm/generate_llm_short_story_manifest.json
corpus/03_llm/generate_llm_short_story_manifest_<RUN_ID>.json
```
