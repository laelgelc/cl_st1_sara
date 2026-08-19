## Development Specification: `generate_llm_short_story.py`

### 1. Programme purpose

`generate_llm_short_story.py` creates an LLM-generated short-story subcorpus that mirrors the human-authored short-story subcorpus on a story-by-story basis.

The programme is part of Phase 2 of the project, whose aim is to compare variation of style between human-authored and LLM-generated fiction using **Traditional / Functional Multi-dimensional Analysis**, rather than Lexical Multi-dimensional Analysis. The generated subcorpus should therefore preserve the broad plot and stylistic profile of each corresponding human-authored text while ensuring that the story-generation LLM request is not directly exposed to the original human-authored short story.

The programme should implement a three-stage workflow for each human-authored short story:

1. **Plot extraction**
   - Submit the original human-authored short story to GPT using a plot-extraction prompt template.
   - Save the extracted plot as a `.txt` file.

2. **Style-profile extraction**
   - Submit the original human-authored short story to GPT using a style-profile extraction prompt template.
   - Save the extracted style profile as a `.txt` file.

3. **LLM short-story generation**
   - Retrieve the corresponding target `word_count` from the Phase 1 metadata file.
   - Submit only:
     - the extracted plot;
     - the extracted style profile;
     - the rendered generation prompt containing the target word count;
     - neutral metadata needed for traceability.
   - Do **not** submit the original human-authored story to the generation-stage request.
   - Save the generated LLM short story as a `.txt` file.

The programme should use GPT through the OpenAI API. The default model should be:

```plain text
gpt-5.6-sol
```


The same model should be used for all three stages through a single `--model` command-line argument.

---

### 2. Core methodological requirement: segregated LLM calls

The programme must treat the three stages as separate API interactions.

The plot-extraction and style-extraction stages may receive the original human-authored story because their purpose is to derive intermediate artefacts from that story.

The generation stage must be segregated from the original story. It must not receive:

- the original human-authored short story text;
- the original human-authored short story as an uploaded file;
- previous conversation messages containing the original story;
- a reused thread, assistant state, or conversation context containing the original story;
- file references from the extraction calls;
- any cached prompt context containing the original story.

The generation request must be constructed as a fresh, stateless API request using only:

- the rendered generation prompt;
- the extracted plot text;
- the extracted style-profile text;
- the target `word_count`;
- neutral metadata such as story filename, story ID, and output naming information.

The per-story metadata must explicitly record that the generation stage did not receive the original story.

Recommended metadata field:

```json
{
  "segregation": {
    "plot_extraction_received_original_story": true,
    "style_extraction_received_original_story": true,
    "generation_received_original_story": false,
    "generation_request_reused_extraction_context": false,
    "generation_request_reused_uploaded_original_file": false,
    "generation_input_source": "persisted_plot_style_outputs_and_metadata_word_count_only"
  }
}
```


---

### 3. Inputs

#### 3.1 Human-authored short-story directory

The programme should read human-authored short stories from:

```plain text
cl_st1_ph2_sara/corpus/01_human/
```


Default CLI argument:

```plain text
--human-dir corpus/01_human
```


The directory is expected to contain `.txt` files, one per human-authored short story.

Supported input extension for this version:

```plain text
.txt
```


The programme should fail early with a clear error if:

- the human-story directory does not exist;
- the human-story directory contains no `.txt` files;
- one or more `.txt` files cannot be read as text.

The programme should process files in natural filename order unless another ordering option is introduced later.

---

#### 3.2 Phase 1 short-story metadata

The programme should read Phase 1 short-story metadata from:

```plain text
cl_st1_ph1_sara/corpus/short_stories.ndjson
```


Default CLI argument:

```plain text
--metadata-ndjson ../cl_st1_ph1_sara/corpus/short_stories.ndjson
```


The metadata file is expected to contain one JSON object per line.

The programme must use this metadata to retrieve the corresponding `word_count` for each human-authored story.

The metadata should contain sufficient information to match each human-story `.txt` file to its metadata row. The implementation should support matching by the most reliable available filename/path field. Recommended matching strategy:

1. Prefer an exact match against a metadata field representing the selected human text filename, if present.
2. Otherwise, match against the basename of any metadata field containing a source or output text path.
3. If multiple rows match the same human-story filename, mark that story as failed.
4. If no row matches the human-story filename, mark that story as failed.

The per-story metadata output should record:

- matched metadata row;
- matching field used;
- matched metadata value;
- target `word_count`.

The programme should fail early with a clear error if:

- the NDJSON metadata file does not exist;
- the NDJSON metadata file is empty;
- the NDJSON file contains invalid JSON lines;
- no usable `word_count` field is found in matched rows.

Per-story failure, not global failure, should occur if:

- a human-story file cannot be matched to a metadata row;
- more than one metadata row matches a human-story file;
- the matched metadata row has missing, empty, non-numeric, zero, or negative `word_count`.

---

#### 3.3 Prompt-template directory

The default prompt-template directory is:

```plain text
cl_st1_ph2_sara/generate_short_story_prompts/
```


The programme must not hardcode prompt contents. It must read prompt instructions from external Markdown prompt-template files.

Default prompt templates:

```plain text
generate_short_story_prompts/extract_plot_v1.md
generate_short_story_prompts/extract_style_v1.md
generate_short_story_prompts/generate_short_story_v1.md
```


Default CLI arguments:

```plain text
--plot-prompt-template generate_short_story_prompts/extract_plot_v1.md
--style-prompt-template generate_short_story_prompts/extract_style_v1.md
--generation-prompt-template generate_short_story_prompts/generate_short_story_v1.md
```


The prompt-template paths must be overridable so that newer versions can be used without modifying the programme.

Example:

```shell script
python generate_llm_short_story.py \
  --plot-prompt-template generate_short_story_prompts/extract_plot_v2.md \
  --style-prompt-template generate_short_story_prompts/extract_style_v2.md \
  --generation-prompt-template generate_short_story_prompts/generate_short_story_v2.md
```


The programme should fail early with a clear error if:

- any prompt-template file is missing;
- any prompt-template file is empty;
- the generation prompt template does not contain the placeholder:

```plain text
<word_count>
```


The programme should record SHA-256 hashes for all three prompt templates.

---

#### 3.4 Environment file

The programme should load environment variables from:

```plain text
cl_st1_ph2_sara/env/.env
```


Default CLI argument:

```plain text
--env-file env/.env
```


The environment file is expected to contain the OpenAI API key, typically:

```plain text
OPENAI_API_KEY=...
```


The programme should attempt to load the `.env` file before initialising the OpenAI client.

Recommended behaviour:

1. If `--env-file` exists, load environment variables from it.
2. After loading the `.env` file, check the process environment for `OPENAI_API_KEY`.
3. If `--env-file` does not exist, continue only if `OPENAI_API_KEY` is already available in the process environment.
4. If `OPENAI_API_KEY` is not available after these checks, fail before any API calls.
5. Never log, print, write, or expose the value of `OPENAI_API_KEY`.

The programme should not require the `.env` file to exist if the API key has already been exported in the shell or otherwise provided in the process environment.

The programme should record only safe environment-loading metadata, for example:

```json
{
  "environment": {
    "env_file": "env/.env",
    "env_file_found": true,
    "openai_api_key_available": true,
    "openai_api_key_source": "env_file_or_process_environment",
    "openai_api_key_logged": false
  }
}
```


The actual API key value must never be written to per-story JSON metadata, run manifests, logs, or error messages.

---

### 4. Prompt handling

#### 4.1 Plot-extraction prompt

The programme should load the plot-extraction prompt template from the path specified by:

```plain text
--plot-prompt-template
```


The plot-extraction request should include:

1. the plot-extraction prompt text;
2. the original human-authored short-story text;
3. neutral metadata identifying the story filename.

The output should be saved as:

```plain text
corpus/02_plot_style/<original_filename_without_txt>_plot.txt
```


Example:

```plain text
corpus/02_plot_style/Apollo - Chimamanda Ngozi Adichie_plot.txt
```


The `.txt` file should contain only the clean plot extraction returned by the model.

---

#### 4.2 Style-profile extraction prompt

The programme should load the style-profile extraction prompt template from the path specified by:

```plain text
--style-prompt-template
```


The style-profile extraction request should include:

1. the style-profile extraction prompt text;
2. the original human-authored short-story text;
3. neutral metadata identifying the story filename.

The output should be saved as:

```plain text
corpus/02_plot_style/<original_filename_without_txt>_style.txt
```


Example:

```plain text
corpus/02_plot_style/Apollo - Chimamanda Ngozi Adichie_style.txt
```


The `.txt` file should contain only the clean style-profile extraction returned by the model.

---

#### 4.3 Generation prompt

The programme should load the generation prompt template from the path specified by:

```plain text
--generation-prompt-template
```


The generation prompt template must contain:

```plain text
<word_count>
```


For each story, the programme must replace `<word_count>` with the corresponding integer `word_count` retrieved from the metadata NDJSON file.

For example, if the matched metadata row has:

```plain text
word_count = 4850
```


then the rendered generation prompt should include:

```plain text
4850 words
```


The generation request must include:

1. the rendered generation prompt;
2. the extracted plot text from the `_plot.txt` file;
3. the extracted style-profile text from the `_style.txt` file;
4. neutral metadata identifying:
   - original story filename;
   - target word count;
   - plot file path;
   - style file path.

The generation request must **not** include the original human-authored story.

The LLM-generated short story should be saved as:

```plain text
corpus/03_llm/<original_filename_without_txt>_llm.txt
```


Example:

```plain text
corpus/03_llm/Apollo - Chimamanda Ngozi Adichie_llm.txt
```


The `.txt` file should contain only the clean generated short story.

---

### 5. Output directories

#### 5.1 Plot and style output directory

The programme should save extracted plot and style-profile files in:

```plain text
cl_st1_ph2_sara/corpus/02_plot_style/
```


Default CLI argument:

```plain text
--plot-style-dir corpus/02_plot_style
```


The programme should create this directory if it does not exist.

For each human story:

```plain text
<original_filename_without_txt>_plot.txt
<original_filename_without_txt>_style.txt
```


---

#### 5.2 LLM-generated short-story output directory

The programme should save generated LLM short stories in:

```plain text
cl_st1_ph2_sara/corpus/03_llm/
```


Default CLI argument:

```plain text
--llm-dir corpus/03_llm
```


The programme should create this directory if it does not exist.

For each human story:

```plain text
<original_filename_without_txt>_llm.txt
```


---

#### 5.3 Per-story metadata output

For each processed story, the programme should write a JSON metadata file.

Recommended directory:

```plain text
cl_st1_ph2_sara/corpus/03_llm/
```


Recommended filename pattern:

```plain text
<original_filename_without_txt>_llm.json
```


This JSON file should contain full reproducibility metadata for all three stages.

---

### 6. Per-story output naming

Given an input file:

```plain text
corpus/01_human/<BASENAME>.txt
```


The programme should write:

```plain text
corpus/02_plot_style/<BASENAME>_plot.txt
corpus/02_plot_style/<BASENAME>_style.txt
corpus/03_llm/<BASENAME>_llm.txt
corpus/03_llm/<BASENAME>_llm.json
```


The programme should preserve the original filename stem exactly, except for adding the suffixes.

If the input filename contains characters that are valid on the current filesystem, the programme should preserve them. It should not attempt to simplify, normalise, slugify, or rename files unless a future `--sanitize-filenames` option is introduced.

---

### 7. LLM submission strategy

For each story, the programme should perform up to three LLM calls:

1. plot extraction;
2. style extraction;
3. story generation.

The calls should be logically independent. The generation call should be constructed only after the plot and style outputs have been written or loaded from existing files.

Recommended request structure for plot extraction:

```plain text
[plot-extraction prompt text]

Story metadata:
Original filename: <filename>

Short story:
<original human-authored story text>
```


Recommended request structure for style extraction:

```plain text
[style-profile extraction prompt text]

Story metadata:
Original filename: <filename>

Short story:
<original human-authored story text>
```


Recommended request structure for generation:

```plain text
[generation prompt text with <word_count> replaced]

Story generation metadata:
Original filename: <filename>
Target word count: <word_count>
Plot source file: corpus/02_plot_style/<BASENAME>_plot.txt
Style source file: corpus/02_plot_style/<BASENAME>_style.txt

Important methodological constraint:
The original human-authored story is not included in this request. Use only the plot and style profile provided below.

Plot:
<extracted plot text>

Style profile:
<extracted style-profile text>
```


The neutral methodological note is allowed because it records the segregation requirement without giving the original story to the model.

---

### 8. Existing-output skipping and reprocessing

The programme should skip existing successful outputs unless `--reprocess` is provided.

A story may be skipped entirely if all of the following exist:

```plain text
corpus/02_plot_style/<BASENAME>_plot.txt
corpus/02_plot_style/<BASENAME>_style.txt
corpus/03_llm/<BASENAME>_llm.txt
corpus/03_llm/<BASENAME>_llm.json
```


and the JSON metadata records:

```json
"status": "success"
```


If only intermediate files exist, the programme may reuse them unless `--reprocess` is provided.

Recommended behaviour:

| Existing artefacts | `--reprocess` absent | `--reprocess` present |
|---|---|---|
| Existing successful full output | Skip story | Re-run all stages |
| Existing plot only | Reuse plot, run style and generation | Re-run all stages |
| Existing style only | Reuse style, run plot and generation | Re-run all stages |
| Existing plot and style, no generated story | Reuse plot/style, run generation | Re-run all stages |
| Existing failed JSON | Retry story | Re-run all stages |

The per-run manifest should record whether each stage was:

- submitted to the LLM;
- skipped because an existing successful output was found;
- reused from an existing intermediate file;
- failed.

---

### 9. Model configuration

The programme should use one model setting for all stages.

Default:

```plain text
gpt-5.6-sol
```


CLI argument:

```plain text
--model MODEL
```


The same configured model should be used for:

- plot extraction;
- style-profile extraction;
- story generation.

The per-story JSON should record:

```json
{
  "model": {
    "configured_model": "gpt-5.6-sol",
    "plot_extraction_model": "gpt-5.6-sol",
    "style_extraction_model": "gpt-5.6-sol",
    "generation_model": "gpt-5.6-sol"
  }
}
```


The programme should also support:

```plain text
gpt-5.6-terra
gpt-5.6-luna
```


or any other model string accepted by the OpenAI API, provided via `--model`.

Recommended methodological default:

```plain text
gpt-5.6-sol
```


because it is the highest-capability GPT-5.6 tier and is preferable for final literary generation quality.

---

### 10. Temperature and generation parameters

Recommended default:

```plain text
--temperature 0
```


A low or zero temperature helps make the workflow more reproducible. However, because the generation task is creative, the specification may allow the researcher to set a higher temperature if desired.

The programme should record:

- configured temperature;
- whether temperature was sent to the API;
- any other model parameters sent to the API;
- API response metadata where available.

If the selected model or API endpoint does not support temperature, the programme should omit it and record:

```json
"temperature_sent_to_api": false
```


If temperature is supported and sent:

```json
"temperature_sent_to_api": true
```


---

### 11. Per-story JSON metadata

For each story, the programme should write a JSON file:

```plain text
corpus/03_llm/<BASENAME>_llm.json
```


#### 11.1 Recommended success structure

```json
{
  "story_filename": "Apollo - Chimamanda Ngozi Adichie.txt",
  "story_basename": "Apollo - Chimamanda Ngozi Adichie",
  "status": "success",
  "input": {
    "human_story_file": "corpus/01_human/Apollo - Chimamanda Ngozi Adichie.txt",
    "metadata_ndjson": "../cl_st1_ph1_sara/corpus/short_stories.ndjson",
    "plot_prompt_template": "generate_short_story_prompts/extract_plot_v1.md",
    "style_prompt_template": "generate_short_story_prompts/extract_style_v1.md",
    "generation_prompt_template": "generate_short_story_prompts/generate_short_story_v1.md",
    "env_file": "env/.env"
  },
  "output": {
    "plot_file": "corpus/02_plot_style/Apollo - Chimamanda Ngozi Adichie_plot.txt",
    "style_file": "corpus/02_plot_style/Apollo - Chimamanda Ngozi Adichie_style.txt",
    "llm_story_file": "corpus/03_llm/Apollo - Chimamanda Ngozi Adichie_llm.txt",
    "metadata_file": "corpus/03_llm/Apollo - Chimamanda Ngozi Adichie_llm.json"
  },
  "environment": {
    "env_file": "env/.env",
    "env_file_found": true,
    "openai_api_key_available": true,
    "openai_api_key_source": "env_file_or_process_environment",
    "openai_api_key_logged": false
  },
  "metadata_match": {
    "status": "matched",
    "matching_field": "source_filename",
    "matching_value": "Apollo - Chimamanda Ngozi Adichie.txt",
    "word_count": 4850,
    "row": {}
  },
  "hashes": {
    "human_story_sha256": "...",
    "metadata_ndjson_sha256": "...",
    "plot_prompt_template_sha256": "...",
    "style_prompt_template_sha256": "...",
    "generation_prompt_template_sha256": "...",
    "rendered_generation_prompt_sha256": "...",
    "plot_output_sha256": "...",
    "style_output_sha256": "...",
    "llm_story_output_sha256": "..."
  },
  "prompt_placeholders": {
    "generation_word_count_placeholder_found": true,
    "generation_word_count_placeholder_replaced": true,
    "word_count_replacement_value": 4850
  },
  "model": {
    "configured_model": "gpt-5.6-sol",
    "plot_extraction_model": "gpt-5.6-sol",
    "style_extraction_model": "gpt-5.6-sol",
    "generation_model": "gpt-5.6-sol"
  },
  "segregation": {
    "plot_extraction_received_original_story": true,
    "style_extraction_received_original_story": true,
    "generation_received_original_story": false,
    "generation_request_reused_extraction_context": false,
    "generation_request_reused_uploaded_original_file": false,
    "generation_input_source": "persisted_plot_style_outputs_and_metadata_word_count_only"
  },
  "stages": {
    "plot_extraction": {
      "status": "success",
      "submitted_to_llm": true,
      "reused_existing_output": false,
      "response_text": "...",
      "api_metadata": {},
      "duration_seconds": 10.1,
      "error": null
    },
    "style_extraction": {
      "status": "success",
      "submitted_to_llm": true,
      "reused_existing_output": false,
      "response_text": "...",
      "api_metadata": {},
      "duration_seconds": 11.2,
      "error": null
    },
    "generation": {
      "status": "success",
      "submitted_to_llm": true,
      "reused_existing_output": false,
      "target_word_count": 4850,
      "response_text": "...",
      "api_metadata": {},
      "duration_seconds": 35.7,
      "error": null
    }
  },
  "temperature": 0,
  "temperature_sent_to_api": false,
  "created_at": "2026-08-19T00:00:00Z",
  "duration_seconds": 57.0,
  "error": null
}
```


#### 11.2 Recommended failure structure

```json
{
  "story_filename": "Apollo - Chimamanda Ngozi Adichie.txt",
  "story_basename": "Apollo - Chimamanda Ngozi Adichie",
  "status": "failed",
  "input": {
    "human_story_file": "corpus/01_human/Apollo - Chimamanda Ngozi Adichie.txt",
    "metadata_ndjson": "../cl_st1_ph1_sara/corpus/short_stories.ndjson",
    "plot_prompt_template": "generate_short_story_prompts/extract_plot_v1.md",
    "style_prompt_template": "generate_short_story_prompts/extract_style_v1.md",
    "generation_prompt_template": "generate_short_story_prompts/generate_short_story_v1.md",
    "env_file": "env/.env"
  },
  "output": {
    "plot_file": "corpus/02_plot_style/Apollo - Chimamanda Ngozi Adichie_plot.txt",
    "style_file": "corpus/02_plot_style/Apollo - Chimamanda Ngozi Adichie_style.txt",
    "llm_story_file": "corpus/03_llm/Apollo - Chimamanda Ngozi Adichie_llm.txt",
    "metadata_file": "corpus/03_llm/Apollo - Chimamanda Ngozi Adichie_llm.json"
  },
  "environment": {
    "env_file": "env/.env",
    "env_file_found": false,
    "openai_api_key_available": false,
    "openai_api_key_source": null,
    "openai_api_key_logged": false
  },
  "metadata_match": {
    "status": "failed",
    "matching_field": null,
    "matching_value": null,
    "word_count": null,
    "row": null
  },
  "segregation": {
    "plot_extraction_received_original_story": null,
    "style_extraction_received_original_story": null,
    "generation_received_original_story": false,
    "generation_request_reused_extraction_context": false,
    "generation_request_reused_uploaded_original_file": false
  },
  "stages": {
    "plot_extraction": {
      "status": "not_started",
      "submitted_to_llm": false,
      "error": null
    },
    "style_extraction": {
      "status": "not_started",
      "submitted_to_llm": false,
      "error": null
    },
    "generation": {
      "status": "not_started",
      "submitted_to_llm": false,
      "error": null
    }
  },
  "created_at": "2026-08-19T00:00:00Z",
  "duration_seconds": 0.5,
  "error": "OPENAI_API_KEY is not available after checking env/.env and the process environment"
}
```


---

### 12. Run-level outputs

The programme should write run-level logs and manifests.

Recommended output location:

```plain text
corpus/03_llm/
```


Recommended files:

```plain text
corpus/03_llm/generate_llm_short_story.log
corpus/03_llm/generate_llm_short_story_manifest.json
corpus/03_llm/generate_llm_short_story_manifest_<RUN_ID>.json
```


The run manifest should include:

- run ID;
- start time;
- end time;
- project phase;
- methodological description;
- human-story input directory;
- metadata NDJSON path;
- plot/style output directory;
- LLM story output directory;
- environment file path;
- environment file found status;
- safe API-key availability status;
- prompt-template paths;
- prompt-template hashes;
- model configuration;
- temperature configuration;
- test-mode configuration;
- processing order;
- number of human stories discovered;
- number of stories planned;
- number skipped;
- number submitted for plot extraction;
- number submitted for style extraction;
- number submitted for generation;
- number succeeded;
- number failed;
- number failed due to metadata matching;
- number failed due to missing word count;
- number failed due to prompt-template problems;
- number failed due to missing API key;
- number failed due to API errors;
- number failed due to empty LLM responses;
- per-story status list.

Recommended strategy block:

```json
{
  "strategy": {
    "study_method": "Traditional / Functional Multi-dimensional Analysis",
    "corpus_design": "human_authored_subcorpus_mirrored_by_llm_generated_subcorpus_story_by_story",
    "llm_family": "GPT",
    "model_used_for_all_stages": "gpt-5.6-sol",
    "stage_1": "plot_extraction_from_original_human_story",
    "stage_2": "style_profile_extraction_from_original_human_story",
    "stage_3": "short_story_generation_from_extracted_plot_style_and_target_word_count_only",
    "generation_context_segregation": "fresh_stateless_generation_request_without_original_story"
  }
}
```


Recommended environment block:

```json
{
  "environment": {
    "env_file": "env/.env",
    "env_file_found": true,
    "openai_api_key_available": true,
    "openai_api_key_source": "env_file_or_process_environment",
    "openai_api_key_logged": false
  }
}
```


---

### 13. Processing order

Default processing order:

1. Parse command-line arguments.
2. Validate global input paths and options.
3. Load environment variables from `--env-file`, if the file exists.
4. Check whether `OPENAI_API_KEY` is available in the process environment.
5. Fail before API calls if `OPENAI_API_KEY` is unavailable.
6. Initialise the OpenAI client without logging the API key.
7. Load and validate prompt templates.
8. Confirm that the generation template contains `<word_count>`.
9. Load and validate the metadata NDJSON file.
10. Discover `.txt` files in the human-story directory.
11. Apply `--start-filename`, if provided.
12. Apply test-mode limit, if enabled.
13. For each selected human-story file:
    - derive basename;
    - locate or compute output paths;
    - skip existing successful output unless `--reprocess`;
    - read human-story text;
    - match the story to a metadata row;
    - retrieve `word_count`;
    - render generation prompt by replacing `<word_count>`;
    - perform or reuse plot extraction;
    - perform or reuse style-profile extraction;
    - perform generation using a fresh request containing only plot/style/word count;
    - write generated short story;
    - write per-story JSON metadata.
14. Write run-level manifest and log.

Processing should continue after per-story failures.

---

### 14. Command-line interface

Recommended CLI arguments:

| Argument | Default | Purpose |
|---|---:|---|
| `--human-dir PATH` | `corpus/01_human` | Human-authored short-story input directory |
| `--metadata-ndjson PATH` | `../cl_st1_ph1_sara/corpus/short_stories.ndjson` | Phase 1 metadata containing `word_count` |
| `--plot-prompt-template PATH` | `generate_short_story_prompts/extract_plot_v1.md` | Plot-extraction prompt template |
| `--style-prompt-template PATH` | `generate_short_story_prompts/extract_style_v1.md` | Style-profile extraction prompt template |
| `--generation-prompt-template PATH` | `generate_short_story_prompts/generate_short_story_v1.md` | Story-generation prompt template |
| `--env-file PATH` | `env/.env` | Optional `.env` file from which to load `OPENAI_API_KEY` and related settings |
| `--plot-style-dir PATH` | `corpus/02_plot_style` | Output directory for extracted plot/style files |
| `--llm-dir PATH` | `corpus/03_llm` | Output directory for generated LLM short stories and metadata |
| `--model MODEL` | `gpt-5.6-sol` | GPT model used for all three stages |
| `--temperature FLOAT` | `0` | Generation temperature, omitted if unsupported |
| `--test-mode` | enabled | Process limited number of stories |
| `--no-test-mode` | disabled | Process all stories |
| `--test-limit N` | `5` | Number of stories to attempt in test mode |
| `--start-filename FILENAME` | `None` | Resume processing from a given human-story filename |
| `--reprocess` | `False` | Regenerate existing outputs |
| `--workers N` | `1` | Number of concurrent workers |
| `--max-retries N` | `2` | API retry attempts per LLM call |
| `--retry-backoff-seconds FLOAT` | `5.0` | Initial retry backoff |
| `--log-file PATH` | `<llm-dir>/generate_llm_short_story.log` | Optional explicit log file path |
| `--manifest-file PATH` | `<llm-dir>/generate_llm_short_story_manifest.json` | Optional explicit run manifest path |

Optional future arguments:

| Argument | Purpose |
|---|---|
| `--plot-model MODEL` | Use a separate model for plot extraction |
| `--style-model MODEL` | Use a separate model for style extraction |
| `--generation-model MODEL` | Use a separate model for story generation |
| `--allow-missing-word-count` | Continue with a fallback word count if metadata lacks `word_count`; not recommended |
| `--word-count-tolerance FLOAT` | Record target tolerance for generated story length |
| `--sanitize-filenames` | Write outputs using filesystem-normalised filenames |
| `--metadata-match-field FIELD` | Force metadata matching through a specific field |
| `--dry-run` | Validate inputs and planned outputs without API calls |

For the current version, only one `--model` should be implemented.

---

### 15. Example commands

#### 15.1 Default test run

```shell script
python generate_llm_short_story.py
```


This should:

- load environment variables from `env/.env`, if present;
- confirm that `OPENAI_API_KEY` is available;
- read human-authored stories from `corpus/01_human/`;
- read metadata from `../cl_st1_ph1_sara/corpus/short_stories.ndjson`;
- use the default v1 prompt templates;
- use `gpt-5.6-sol`;
- process up to 5 stories;
- save plot/style outputs in `corpus/02_plot_style/`;
- save LLM-generated stories in `corpus/03_llm/`.

---

#### 15.2 Full run

```shell script
python generate_llm_short_story.py --no-test-mode
```


---

#### 15.3 Reprocess all stories

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --reprocess
```


---

#### 15.4 Resume from a specific filename

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --start-filename "Apollo - Chimamanda Ngozi Adichie.txt"
```


---

#### 15.5 Use a different GPT-5.6 tier

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --model gpt-5.6-terra
```


---

#### 15.6 Use newer prompt-template versions

```shell script
python generate_llm_short_story.py \
  --no-test-mode \
  --plot-prompt-template generate_short_story_prompts/extract_plot_v2.md \
  --style-prompt-template generate_short_story_prompts/extract_style_v2.md \
  --generation-prompt-template generate_short_story_prompts/generate_short_story_v2.md
```


---

#### 15.7 Use a non-default environment file

```shell script
python generate_llm_short_story.py \
  --env-file env/.env_production
```


---

### 16. Validation rules

The programme should fail before API calls if:

- the human-story directory does not exist;
- the human-story directory contains no `.txt` files;
- the metadata NDJSON file does not exist;
- the metadata NDJSON file is empty;
- the metadata NDJSON file contains invalid JSON;
- the plot prompt template does not exist;
- the style prompt template does not exist;
- the generation prompt template does not exist;
- any prompt template is empty;
- the generation prompt template does not contain `<word_count>`;
- the plot/style output directory cannot be created;
- the LLM output directory cannot be created;
- `OPENAI_API_KEY` is unavailable after checking `--env-file` and the process environment;
- the OpenAI Python SDK is unavailable;
- `--test-limit <= 0`;
- `--workers <= 0`;
- `--temperature < 0`;
- `--max-retries < 0`;
- `--retry-backoff-seconds < 0`.

The programme should **not** fail solely because the `--env-file` path does not exist, provided `OPENAI_API_KEY` is already available in the process environment.

Per-story failures should not stop the full run.

---

### 17. Per-story failure handling

A story should be marked as failed, but the run should continue, if:

- the human-story file cannot be read;
- the human-story file is empty;
- the story cannot be matched to a metadata row;
- the story matches more than one metadata row;
- the matched metadata row lacks `word_count`;
- the matched `word_count` is non-numeric, zero, or negative;
- the rendered generation prompt cannot be created;
- the plot-extraction API request fails after retries;
- the style-extraction API request fails after retries;
- the generation API request fails after retries;
- the plot-extraction response contains no usable text;
- the style-extraction response contains no usable text;
- the generation response contains no usable text;
- any required output file cannot be written;
- segregation rules cannot be satisfied.

Each failure should be written to:

- the run log;
- the run manifest;
- the per-story JSON metadata file where possible.

A failed `.txt` LLM story output is not required. A failed `.json` metadata file should still be written where possible.

---

### 18. Logging requirements

The programme should log:

- run ID;
- start and end times;
- selected model;
- selected prompt-template paths;
- prompt-template hashes;
- input and output directories;
- environment file path;
- environment file found status;
- safe API-key availability status;
- number of discovered human stories;
- test-mode status;
- per-story start and end;
- per-stage status;
- skipped outputs;
- reused intermediate outputs;
- failures and error messages;
- retry attempts;
- final counts.

The programme must not log:

- the value of `OPENAI_API_KEY`;
- full raw API authentication headers;
- unnecessary full request payloads containing complete copyrighted story text.

The programme may log hashes, paths, and boolean availability status for reproducibility.

---

### 19. Reproducibility requirements

The programme should record enough information to reproduce a run:

- source human-story path;
- source human-story SHA-256 hash;
- metadata NDJSON path;
- metadata NDJSON SHA-256 hash, if feasible;
- matched metadata row;
- target `word_count`;
- prompt-template paths;
- prompt-template hashes;
- rendered generation prompt hash;
- environment file path;
- environment file found status;
- safe API-key availability status, without the key value;
- model name;
- temperature;
- whether temperature was sent to the API;
- API response metadata;
- output paths;
- output hashes;
- stage durations;
- segregation status.

The run manifest and per-story JSON files should be sufficient to determine:

1. which human story was processed;
2. which metadata row supplied the target word count;
3. which prompt versions were used;
4. which GPT model was used;
5. whether the environment file was used or whether the key came from the process environment;
6. whether outputs were newly generated or reused;
7. whether the generation request was segregated from the original story.

---

### 20. Acceptance criteria

The programme is acceptable when:

1. It is named `generate_llm_short_story.py`.
2. It reads human-authored `.txt` stories from `corpus/01_human/`.
3. It reads `word_count` metadata from `../cl_st1_ph1_sara/corpus/short_stories.ndjson`.
4. It reads prompt templates from external Markdown files.
5. Prompt text is not hardcoded into the programme.
6. The plot prompt path is configurable with `--plot-prompt-template`.
7. The style prompt path is configurable with `--style-prompt-template`.
8. The generation prompt path is configurable with `--generation-prompt-template`.
9. The generation prompt template must contain `<word_count>`.
10. The programme replaces `<word_count>` with the matched metadata value for each story.
11. The programme supports `--env-file`, defaulting to `env/.env`.
12. The programme loads environment variables from `env/.env` when present.
13. The programme can also use `OPENAI_API_KEY` from the process environment if the `.env` file is absent.
14. The programme fails before API calls if `OPENAI_API_KEY` is unavailable.
15. The programme never logs, prints, or writes the API key value.
16. The programme uses one `--model` argument for all three stages.
17. The default model is `gpt-5.6-sol`.
18. For each human story, the programme creates a plot extraction.
19. Plot outputs are saved in `corpus/02_plot_style/` with the `_plot.txt` suffix.
20. For each human story, the programme creates a style-profile extraction.
21. Style outputs are saved in `corpus/02_plot_style/` with the `_style.txt` suffix.
22. For each human story, the programme generates an LLM short story from plot, style profile, and target word count.
23. LLM-generated stories are saved in `corpus/03_llm/` with the `_llm.txt` suffix.
24. The generation request does not include the original human-authored story.
25. The generation request does not reuse extraction-stage context containing the original story.
26. Per-story JSON metadata records the segregation status.
27. Existing successful outputs are skipped unless `--reprocess` is used.
28. Intermediate plot/style files may be reused unless `--reprocess` is used.
29. Per-story failures are logged and do not stop the full run.
30. The programme writes a run-level manifest.
31. The programme writes a run-level log.
32. The programme supports test mode and full-run mode.
33. The programme supports resuming from a specified filename.
34. Prompt hashes, output hashes, model configuration, target word count, environment metadata, and metadata matching information are recorded.
35. The resulting generated subcorpus mirrors the human-authored subcorpus story by story.
36. The workflow is appropriate for subsequent Traditional / Functional Multi-dimensional Analysis of stylistic variation.