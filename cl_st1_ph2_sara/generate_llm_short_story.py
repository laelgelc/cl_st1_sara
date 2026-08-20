#!/usr/bin/env python3
"""
generate_llm_short_story.py

Create LLM-generated short-story subcorpora that mirror the human-authored
short-story subcorpus story by story.

Workflow per human-authored story:
1. Extract plot from original human story.
2. Extract style profile from original human story.
3. Generate a new plot/style-guided LLM short story from extracted plot,
   extracted style profile, and the target word_count only.
4. Generate a second free LLM short story from a self-contained free-generation
   prompt only.

The plot/style-guided generation request is deliberately segregated from the
original human story. The free-generation request is also segregated and does
not receive the original story, plot, style profile, or word_count.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import logging
import os
import re
import sys
import threading
import time
import traceback
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


PROGRAMME_NAME = "generate_llm_short_story.py"
WORD_COUNT_PLACEHOLDER = "<word_count>"
SUPPORTED_TEXT_SUFFIXES = {".txt"}
TEMPERATURE_UNSUPPORTED_MODELS: set[str] = set()
TEMPERATURE_SUPPORT_LOCK = threading.Lock()


# ---------------------------------------------------------------------------
# Generic utilities
# ---------------------------------------------------------------------------


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def natural_sort_key(value: str) -> List[Any]:
    return [int(part) if part.isdigit() else part.lower() for part in re.split(r"(\d+)", value)]


def resolve_path(path_value: str | Path, base_dir: Path) -> Path:
    path = Path(path_value).expanduser()
    if path.is_absolute():
        return path
    return (base_dir / path).resolve()


def relpath(path: Path, base_dir: Path) -> str:
    try:
        return str(path.resolve().relative_to(base_dir.resolve()))
    except ValueError:
        return str(path.resolve())


def read_text_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text_file(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def write_json_file(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_int(value: Any) -> Optional[int]:
    if value is None:
        return None
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        if value.is_integer():
            return int(value)
        return None
    if isinstance(value, str):
        value = value.strip()
        if not value:
            return None
        if re.fullmatch(r"\d+", value):
            return int(value)
    return None


def load_dotenv_file(path: Path) -> bool:
    """
    Minimal .env loader.

    Supports simple KEY=VALUE lines. Existing environment variables are not
    overwritten.
    """
    if not path.exists():
        return False

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[len("export ") :].strip()
        if "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()

        if not key:
            continue

        if (
            (value.startswith('"') and value.endswith('"'))
            or (value.startswith("'") and value.endswith("'"))
        ):
            value = value[1:-1]

        os.environ.setdefault(key, value)

    return True


def extract_response_text(response: Any) -> str:
    """
    Extract text from OpenAI Responses API result robustly.
    """
    output_text = getattr(response, "output_text", None)
    if isinstance(output_text, str) and output_text.strip():
        return output_text.strip()

    output = getattr(response, "output", None)
    parts: List[str] = []
    if output:
        for item in output:
            content = getattr(item, "content", None)
            if not content:
                continue
            for content_item in content:
                text = getattr(content_item, "text", None)
                if text:
                    parts.append(str(text))

    return "\n".join(parts).strip()


def api_metadata_from_response(response: Any) -> Dict[str, Any]:
    metadata: Dict[str, Any] = {}

    for attr in ("id", "model", "created_at", "status"):
        value = getattr(response, attr, None)
        if value is not None:
            metadata[attr] = value

    usage = getattr(response, "usage", None)
    if usage is not None:
        try:
            if hasattr(usage, "model_dump"):
                metadata["usage"] = usage.model_dump()
            elif hasattr(usage, "dict"):
                metadata["usage"] = usage.dict()
            else:
                metadata["usage"] = str(usage)
        except Exception:
            metadata["usage"] = str(usage)

    return metadata


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate LLM short stories mirroring a human-authored short-story corpus."
    )

    parser.add_argument("--human-dir", default="corpus/01_human")
    parser.add_argument("--metadata-ndjson", default="../cl_st1_ph1_sara/corpus/short_stories.ndjson")
    parser.add_argument("--plot-prompt-template", default="generate_short_story_prompts/extract_plot_v1.md")
    parser.add_argument("--style-prompt-template", default="generate_short_story_prompts/extract_style_v1.md")
    parser.add_argument("--generation-prompt-template", default="generate_short_story_prompts/generate_short_story_v1.md")
    parser.add_argument("--free-generation-prompt-template", default="generate_short_story_prompts/generate_free_short_story_v1.md")
    parser.add_argument("--env-file", default="env/.env")

    parser.add_argument("--plot-style-dir", default="corpus/02_plot_style")
    parser.add_argument("--llm-dir", default="corpus/03_llm")
    parser.add_argument("--llm-free-dir", default="corpus/04_llm_free")

    parser.add_argument("--model", default="gpt-5.6-sol")
    parser.add_argument("--temperature", type=float, default=0.0)

    test_mode = parser.add_mutually_exclusive_group()
    test_mode.add_argument("--test-mode", action="store_true", default=True)
    test_mode.add_argument("--no-test-mode", action="store_false", dest="test_mode")

    parser.add_argument("--test-limit", type=int, default=5)
    parser.add_argument("--start-filename", default=None)
    parser.add_argument("--reprocess", action="store_true")
    parser.add_argument("--workers", type=int, default=1)
    parser.add_argument("--max-retries", type=int, default=2)
    parser.add_argument("--retry-backoff-seconds", type=float, default=5.0)

    parser.add_argument("--log-file", default=None)
    parser.add_argument("--manifest-file", default=None)

    return parser


@dataclass
class Config:
    script_dir: Path
    run_id: str

    human_dir: Path
    metadata_ndjson: Path
    plot_prompt_template: Path
    style_prompt_template: Path
    generation_prompt_template: Path
    free_generation_prompt_template: Path
    env_file: Path

    plot_style_dir: Path
    llm_dir: Path
    llm_free_dir: Path

    model: str
    temperature: float
    test_mode: bool
    test_limit: int
    start_filename: Optional[str]
    reprocess: bool
    workers: int
    max_retries: int
    retry_backoff_seconds: float

    log_file: Path
    manifest_file: Path
    timestamped_manifest_file: Path


def make_config(args: argparse.Namespace) -> Config:
    script_dir = Path(__file__).resolve().parent
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "_" + uuid.uuid4().hex[:8]

    llm_dir = resolve_path(args.llm_dir, script_dir)
    log_file = resolve_path(args.log_file, script_dir) if args.log_file else llm_dir / "generate_llm_short_story.log"
    manifest_file = (
        resolve_path(args.manifest_file, script_dir)
        if args.manifest_file
        else llm_dir / "generate_llm_short_story_manifest.json"
    )
    timestamped_manifest_file = llm_dir / f"generate_llm_short_story_manifest_{run_id}.json"

    return Config(
        script_dir=script_dir,
        run_id=run_id,
        human_dir=resolve_path(args.human_dir, script_dir),
        metadata_ndjson=resolve_path(args.metadata_ndjson, script_dir),
        plot_prompt_template=resolve_path(args.plot_prompt_template, script_dir),
        style_prompt_template=resolve_path(args.style_prompt_template, script_dir),
        generation_prompt_template=resolve_path(args.generation_prompt_template, script_dir),
        free_generation_prompt_template=resolve_path(args.free_generation_prompt_template, script_dir),
        env_file=resolve_path(args.env_file, script_dir),
        plot_style_dir=resolve_path(args.plot_style_dir, script_dir),
        llm_dir=llm_dir,
        llm_free_dir=resolve_path(args.llm_free_dir, script_dir),
        model=args.model,
        temperature=args.temperature,
        test_mode=args.test_mode,
        test_limit=args.test_limit,
        start_filename=args.start_filename,
        reprocess=args.reprocess,
        workers=args.workers,
        max_retries=args.max_retries,
        retry_backoff_seconds=args.retry_backoff_seconds,
        log_file=log_file,
        manifest_file=manifest_file,
        timestamped_manifest_file=timestamped_manifest_file,
    )


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------


def setup_logging(config: Config) -> None:
    config.log_file.parent.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(config.log_file, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )


# ---------------------------------------------------------------------------
# Validation and loading
# ---------------------------------------------------------------------------


def validate_basic_options(config: Config) -> None:
    if config.test_limit <= 0:
        raise ValueError("--test-limit must be greater than 0")
    if config.workers <= 0:
        raise ValueError("--workers must be greater than 0")
    if config.temperature < 0:
        raise ValueError("--temperature must be greater than or equal to 0")
    if config.max_retries < 0:
        raise ValueError("--max-retries must be greater than or equal to 0")
    if config.retry_backoff_seconds < 0:
        raise ValueError("--retry-backoff-seconds must be greater than or equal to 0")


def validate_directories(config: Config) -> None:
    if not config.human_dir.exists() or not config.human_dir.is_dir():
        raise FileNotFoundError(f"Human-story directory not found: {relpath(config.human_dir, config.script_dir)}")

    config.plot_style_dir.mkdir(parents=True, exist_ok=True)
    config.llm_dir.mkdir(parents=True, exist_ok=True)
    config.llm_free_dir.mkdir(parents=True, exist_ok=True)


def load_prompt(path: Path, label: str) -> str:
    if not path.exists():
        raise FileNotFoundError(f"{label} prompt template not found: {path}")
    text = read_text_file(path)
    if not text.strip():
        raise ValueError(f"{label} prompt template is empty: {path}")
    return text.strip()


def discover_human_story_files(config: Config) -> List[Path]:
    files = [
        path
        for path in config.human_dir.iterdir()
        if path.is_file() and path.suffix.lower() in SUPPORTED_TEXT_SUFFIXES
    ]
    files.sort(key=lambda p: natural_sort_key(p.name))

    if not files:
        raise FileNotFoundError(f"No .txt files found in human-story directory: {relpath(config.human_dir, config.script_dir)}")

    if config.start_filename:
        filenames = [path.name for path in files]
        if config.start_filename not in filenames:
            raise ValueError(f"--start-filename not found in human-story directory: {config.start_filename}")
        start_index = filenames.index(config.start_filename)
        files = files[start_index:]

    if config.test_mode:
        files = files[: config.test_limit]

    return files


def load_metadata_rows(config: Config) -> Tuple[List[Dict[str, Any]], str]:
    if not config.metadata_ndjson.exists():
        raise FileNotFoundError(f"Metadata NDJSON not found: {relpath(config.metadata_ndjson, config.script_dir)}")

    rows: List[Dict[str, Any]] = []
    with config.metadata_ndjson.open("r", encoding="utf-8") as handle:
        for line_number, raw_line in enumerate(handle, start=1):
            line = raw_line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"Invalid JSON in metadata NDJSON at line {line_number}: {exc}") from exc
            if not isinstance(item, dict):
                raise ValueError(f"Metadata NDJSON line {line_number} is not a JSON object")
            rows.append(item)

    if not rows:
        raise ValueError(f"Metadata NDJSON is empty: {relpath(config.metadata_ndjson, config.script_dir)}")

    has_word_count = any("word_count" in row for row in rows)
    if not has_word_count:
        raise ValueError("No usable word_count field found in metadata NDJSON")

    return rows, sha256_file(config.metadata_ndjson)


# ---------------------------------------------------------------------------
# Metadata matching
# ---------------------------------------------------------------------------


FILENAME_FIELD_HINTS = (
    "filename",
    "file_name",
    "source_filename",
    "selected_filename",
    "human_filename",
    "txt_filename",
    "output_filename",
)

PATH_FIELD_HINTS = (
    "path",
    "file",
    "filepath",
    "file_path",
    "source_path",
    "output_path",
    "txt_path",
    "human_path",
)


def flatten_metadata_values(row: Dict[str, Any], prefix: str = "") -> Iterable[Tuple[str, Any]]:
    for key, value in row.items():
        full_key = f"{prefix}.{key}" if prefix else str(key)
        if isinstance(value, dict):
            yield from flatten_metadata_values(value, full_key)
        else:
            yield full_key, value


def candidate_basename(value: Any) -> Optional[str]:
    if not isinstance(value, str):
        return None
    value = value.strip()
    if not value:
        return None

    basename = Path(value).name
    if basename:
        return basename
    return value


def match_metadata_row(story_file: Path, rows: List[Dict[str, Any]]) -> Tuple[Dict[str, Any], str, str]:
    story_filename = story_file.name
    story_stem = story_file.stem

    exact_candidates: List[Tuple[Dict[str, Any], str, str]] = []
    basename_candidates: List[Tuple[Dict[str, Any], str, str]] = []
    stem_candidates: List[Tuple[Dict[str, Any], str, str]] = []

    for row in rows:
        for field, value in flatten_metadata_values(row):
            field_lower = field.lower()
            if not isinstance(value, str):
                continue

            value_stripped = value.strip()
            value_basename = candidate_basename(value)

            if any(hint in field_lower for hint in FILENAME_FIELD_HINTS):
                if value_stripped == story_filename:
                    exact_candidates.append((row, field, value_stripped))
                elif value_basename == story_filename:
                    basename_candidates.append((row, field, value_stripped))
                elif Path(value_basename or "").stem == story_stem:
                    stem_candidates.append((row, field, value_stripped))

            elif any(hint in field_lower for hint in PATH_FIELD_HINTS):
                if value_basename == story_filename:
                    basename_candidates.append((row, field, value_stripped))
                elif Path(value_basename or "").stem == story_stem:
                    stem_candidates.append((row, field, value_stripped))

    for candidates in (exact_candidates, basename_candidates, stem_candidates):
        unique_rows = []
        seen_ids = set()
        for row, field, value in candidates:
            row_id = id(row)
            if row_id not in seen_ids:
                seen_ids.add(row_id)
                unique_rows.append((row, field, value))

        if len(unique_rows) == 1:
            return unique_rows[0]
        if len(unique_rows) > 1:
            raise ValueError(f"Multiple metadata rows match human story file: {story_filename}")

    raise ValueError(f"Could not match human story file to a unique metadata row: {story_filename}")


# ---------------------------------------------------------------------------
# OpenAI calls
# ---------------------------------------------------------------------------


def import_openai_client_class() -> Any:
    try:
        from openai import OpenAI
    except ImportError as exc:
        raise ImportError("The OpenAI Python SDK is unavailable. Install it with: pip install openai") from exc
    return OpenAI


def make_openai_client() -> Any:
    OpenAI = import_openai_client_class()
    return OpenAI()


def call_openai_with_retries(
    client: Any,
    *,
    model: str,
    prompt: str,
    temperature: float,
    max_retries: int,
    retry_backoff_seconds: float,
) -> Tuple[str, Dict[str, Any], bool]:
    last_error: Optional[BaseException] = None

    for attempt in range(max_retries + 1):
        try:
            kwargs: Dict[str, Any] = {
                "model": model,
                "input": prompt,
            }

            temperature_sent = False
            with TEMPERATURE_SUPPORT_LOCK:
                model_supports_temperature = model not in TEMPERATURE_UNSUPPORTED_MODELS

            if temperature is not None and model_supports_temperature:
                kwargs["temperature"] = temperature
                temperature_sent = True

            try:
                response = client.responses.create(**kwargs)
            except TypeError:
                kwargs.pop("temperature", None)
                temperature_sent = False
                with TEMPERATURE_SUPPORT_LOCK:
                    TEMPERATURE_UNSUPPORTED_MODELS.add(model)
                response = client.responses.create(**kwargs)
            except Exception as exc:
                error_text = str(exc)
                if (
                    "Unsupported parameter" in error_text
                    and "temperature" in error_text
                    and "temperature" in kwargs
                ):
                    logging.warning(
                        "Model %s does not support temperature; omitting temperature for subsequent requests.",
                        model,
                    )
                    kwargs.pop("temperature", None)
                    temperature_sent = False
                    with TEMPERATURE_SUPPORT_LOCK:
                        TEMPERATURE_UNSUPPORTED_MODELS.add(model)
                    response = client.responses.create(**kwargs)
                else:
                    raise

            text = extract_response_text(response)
            metadata = api_metadata_from_response(response)

            if not text.strip():
                raise ValueError("LLM response contains no usable text")

            return text.strip(), metadata, temperature_sent

        except Exception as exc:
            last_error = exc
            if attempt >= max_retries:
                break
            sleep_for = retry_backoff_seconds * (2 ** attempt)
            logging.warning("API call failed on attempt %s/%s: %s", attempt + 1, max_retries + 1, exc)
            if sleep_for > 0:
                time.sleep(sleep_for)

    raise RuntimeError(f"LLM request failed after {max_retries + 1} attempt(s): {last_error}") from last_error


# ---------------------------------------------------------------------------
# Request construction
# ---------------------------------------------------------------------------


def build_plot_request(plot_prompt: str, story_filename: str, story_text: str) -> str:
    return (
        f"{plot_prompt}\n\n"
        f"Story metadata:\n"
        f"Original filename: {story_filename}\n\n"
        f"Short story:\n"
        f"{story_text}"
    )


def build_style_request(style_prompt: str, story_filename: str, story_text: str) -> str:
    return (
        f"{style_prompt}\n\n"
        f"Story metadata:\n"
        f"Original filename: {story_filename}\n\n"
        f"Short story:\n"
        f"{story_text}"
    )


def build_generation_request(
    generation_prompt: str,
    *,
    story_filename: str,
    word_count: int,
    plot_file: str,
    style_file: str,
    plot_text: str,
    style_text: str,
) -> str:
    return (
        f"{generation_prompt}\n\n"
        f"Story generation metadata:\n"
        f"Original filename: {story_filename}\n"
        f"Target word count: {word_count}\n"
        f"Plot source file: {plot_file}\n"
        f"Style source file: {style_file}\n\n"
        f"Important methodological constraint:\n"
        f"The original human-authored story is not included in this request. "
        f"Use only the plot and style profile provided below.\n\n"
        f"Plot:\n"
        f"{plot_text}\n\n"
        f"Style profile:\n"
        f"{style_text}"
    )


def build_free_generation_request(free_generation_prompt: str) -> str:
    return free_generation_prompt


# ---------------------------------------------------------------------------
# Per-story processing
# ---------------------------------------------------------------------------


def stage_not_started() -> Dict[str, Any]:
    return {
        "status": "not_started",
        "submitted_to_llm": False,
        "reused_existing_output": False,
        "response_text": None,
        "api_metadata": {},
        "duration_seconds": 0,
        "error": None,
    }


def build_base_story_metadata(
    config: Config,
    story_file: Path,
    output_paths: Dict[str, Path],
    environment_metadata: Dict[str, Any],
) -> Dict[str, Any]:
    return {
        "story_filename": story_file.name,
        "story_basename": story_file.stem,
        "status": "started",
        "input": {
            "human_story_file": relpath(story_file, config.script_dir),
            "metadata_ndjson": relpath(config.metadata_ndjson, config.script_dir),
            "plot_prompt_template": relpath(config.plot_prompt_template, config.script_dir),
            "style_prompt_template": relpath(config.style_prompt_template, config.script_dir),
            "generation_prompt_template": relpath(config.generation_prompt_template, config.script_dir),
            "free_generation_prompt_template": relpath(config.free_generation_prompt_template, config.script_dir),
            "env_file": relpath(config.env_file, config.script_dir),
        },
        "output": {
            "plot_file": relpath(output_paths["plot"], config.script_dir),
            "style_file": relpath(output_paths["style"], config.script_dir),
            "llm_story_file": relpath(output_paths["llm_story"], config.script_dir),
            "llm_story_metadata_file": relpath(output_paths["metadata"], config.script_dir),
            "metadata_file": relpath(output_paths["metadata"], config.script_dir),
            "llm_free_story_file": relpath(output_paths["llm_free_story"], config.script_dir),
            "llm_free_metadata_file": relpath(output_paths["llm_free_metadata"], config.script_dir),
        },
        "environment": environment_metadata,
        "metadata_match": {
            "status": "not_started",
            "matching_field": None,
            "matching_value": None,
            "word_count": None,
            "row": None,
        },
        "hashes": {},
        "prompt_placeholders": {
            "generation_word_count_placeholder_found": None,
            "generation_word_count_placeholder_replaced": None,
            "word_count_replacement_value": None,
        },
        "model": {
            "configured_model": config.model,
            "plot_extraction_model": config.model,
            "style_extraction_model": config.model,
            "generation_model": config.model,
            "free_generation_model": config.model,
        },
        "segregation": {
            "plot_extraction_received_original_story": None,
            "style_extraction_received_original_story": None,
            "generation_received_original_story": False,
            "generation_request_reused_extraction_context": False,
            "generation_request_reused_uploaded_original_file": False,
            "generation_input_source": "persisted_plot_style_outputs_and_metadata_word_count_only",
            "free_generation_received_original_story": False,
            "free_generation_received_plot": False,
            "free_generation_received_style_profile": False,
            "free_generation_received_word_count": False,
            "free_generation_input_source": "self_contained_free_generation_prompt_only",
        },
        "stages": {
            "plot_extraction": stage_not_started(),
            "style_extraction": stage_not_started(),
            "generation": stage_not_started(),
            "free_generation": stage_not_started(),
        },
        "temperature": config.temperature,
        "temperature_sent_to_api": False,
        "created_at": utc_now_iso(),
        "duration_seconds": 0,
        "error": None,
    }


def existing_success(
    metadata_path: Path,
    llm_story_path: Path,
    llm_free_metadata_path: Path,
    llm_free_story_path: Path,
    plot_path: Path,
    style_path: Path,
) -> bool:
    required_paths = (
        metadata_path,
        llm_story_path,
        llm_free_metadata_path,
        llm_free_story_path,
        plot_path,
        style_path,
    )
    if not all(path.exists() for path in required_paths):
        return False

    try:
        guided_data = json.loads(metadata_path.read_text(encoding="utf-8"))
        free_data = json.loads(llm_free_metadata_path.read_text(encoding="utf-8"))
    except Exception:
        return False

    return guided_data.get("status") == "success" and free_data.get("status") == "success"


def process_one_story(
    story_file: Path,
    *,
    config: Config,
    client: Any,
    metadata_rows: List[Dict[str, Any]],
    metadata_ndjson_sha256: str,
    plot_prompt: str,
    style_prompt: str,
    generation_prompt_template: str,
    free_generation_prompt: str,
    prompt_hashes: Dict[str, str],
    environment_metadata: Dict[str, Any],
) -> Dict[str, Any]:
    start_time = time.time()

    basename = story_file.stem
    output_paths = {
        "plot": config.plot_style_dir / f"{basename}_plot.txt",
        "style": config.plot_style_dir / f"{basename}_style.txt",
        "llm_story": config.llm_dir / f"{basename}_llm.txt",
        "metadata": config.llm_dir / f"{basename}_llm.json",
        "llm_free_story": config.llm_free_dir / f"{basename}_llm_free.txt",
        "llm_free_metadata": config.llm_free_dir / f"{basename}_llm_free.json",
    }

    story_metadata = build_base_story_metadata(config, story_file, output_paths, environment_metadata)

    try:
        if not config.reprocess and existing_success(
            output_paths["metadata"],
            output_paths["llm_story"],
            output_paths["llm_free_metadata"],
            output_paths["llm_free_story"],
            output_paths["plot"],
            output_paths["style"],
        ):
            story_metadata = json.loads(output_paths["metadata"].read_text(encoding="utf-8"))
            story_metadata["status"] = "skipped_existing"
            story_metadata["skipped_at"] = utc_now_iso()
            return story_metadata

        story_text = read_text_file(story_file)
        if not story_text.strip():
            raise ValueError(f"Human story file is empty: {story_file.name}")

        story_metadata["hashes"]["human_story_sha256"] = sha256_text(story_text)
        story_metadata["hashes"]["metadata_ndjson_sha256"] = metadata_ndjson_sha256
        story_metadata["hashes"].update(prompt_hashes)

        matched_row, matching_field, matching_value = match_metadata_row(story_file, metadata_rows)
        word_count = safe_int(matched_row.get("word_count"))
        if word_count is None or word_count <= 0:
            raise ValueError(f"Matched metadata row has missing or invalid word_count for {story_file.name}")

        story_metadata["metadata_match"] = {
            "status": "matched",
            "matching_field": matching_field,
            "matching_value": matching_value,
            "word_count": word_count,
            "row": matched_row,
        }

        placeholder_found = WORD_COUNT_PLACEHOLDER in generation_prompt_template
        if not placeholder_found:
            raise ValueError(f"Generation prompt template lacks {WORD_COUNT_PLACEHOLDER}")

        rendered_generation_prompt = generation_prompt_template.replace(WORD_COUNT_PLACEHOLDER, str(word_count))
        story_metadata["prompt_placeholders"] = {
            "generation_word_count_placeholder_found": True,
            "generation_word_count_placeholder_replaced": True,
            "word_count_replacement_value": word_count,
        }
        story_metadata["hashes"]["rendered_generation_prompt_sha256"] = sha256_text(rendered_generation_prompt)

        plot_stage_start = time.time()
        if output_paths["plot"].exists() and not config.reprocess:
            plot_text = read_text_file(output_paths["plot"]).strip()
            if not plot_text:
                raise ValueError(f"Existing plot output is empty: {output_paths['plot'].name}")
            story_metadata["stages"]["plot_extraction"].update(
                {
                    "status": "success",
                    "submitted_to_llm": False,
                    "reused_existing_output": True,
                    "response_text": plot_text,
                    "duration_seconds": round(time.time() - plot_stage_start, 3),
                }
            )
        else:
            plot_request = build_plot_request(plot_prompt, story_file.name, story_text)
            plot_text, api_metadata, temperature_sent = call_openai_with_retries(
                client,
                model=config.model,
                prompt=plot_request,
                temperature=config.temperature,
                max_retries=config.max_retries,
                retry_backoff_seconds=config.retry_backoff_seconds,
            )
            write_text_file(output_paths["plot"], plot_text)
            story_metadata["temperature_sent_to_api"] = story_metadata["temperature_sent_to_api"] or temperature_sent
            story_metadata["stages"]["plot_extraction"].update(
                {
                    "status": "success",
                    "submitted_to_llm": True,
                    "reused_existing_output": False,
                    "response_text": plot_text,
                    "api_metadata": api_metadata,
                    "duration_seconds": round(time.time() - plot_stage_start, 3),
                }
            )

        story_metadata["segregation"]["plot_extraction_received_original_story"] = True
        story_metadata["hashes"]["plot_output_sha256"] = sha256_text(plot_text)

        style_stage_start = time.time()
        if output_paths["style"].exists() and not config.reprocess:
            style_text = read_text_file(output_paths["style"]).strip()
            if not style_text:
                raise ValueError(f"Existing style output is empty: {output_paths['style'].name}")
            story_metadata["stages"]["style_extraction"].update(
                {
                    "status": "success",
                    "submitted_to_llm": False,
                    "reused_existing_output": True,
                    "response_text": style_text,
                    "duration_seconds": round(time.time() - style_stage_start, 3),
                }
            )
        else:
            style_request = build_style_request(style_prompt, story_file.name, story_text)
            style_text, api_metadata, temperature_sent = call_openai_with_retries(
                client,
                model=config.model,
                prompt=style_request,
                temperature=config.temperature,
                max_retries=config.max_retries,
                retry_backoff_seconds=config.retry_backoff_seconds,
            )
            write_text_file(output_paths["style"], style_text)
            story_metadata["temperature_sent_to_api"] = story_metadata["temperature_sent_to_api"] or temperature_sent
            story_metadata["stages"]["style_extraction"].update(
                {
                    "status": "success",
                    "submitted_to_llm": True,
                    "reused_existing_output": False,
                    "response_text": style_text,
                    "api_metadata": api_metadata,
                    "duration_seconds": round(time.time() - style_stage_start, 3),
                }
            )

        story_metadata["segregation"]["style_extraction_received_original_story"] = True
        story_metadata["hashes"]["style_output_sha256"] = sha256_text(style_text)

        generation_stage_start = time.time()
        generation_request = build_generation_request(
            rendered_generation_prompt,
            story_filename=story_file.name,
            word_count=word_count,
            plot_file=relpath(output_paths["plot"], config.script_dir),
            style_file=relpath(output_paths["style"], config.script_dir),
            plot_text=plot_text,
            style_text=style_text,
        )

        llm_story_text, api_metadata, temperature_sent = call_openai_with_retries(
            client,
            model=config.model,
            prompt=generation_request,
            temperature=config.temperature,
            max_retries=config.max_retries,
            retry_backoff_seconds=config.retry_backoff_seconds,
        )
        write_text_file(output_paths["llm_story"], llm_story_text)

        story_metadata["temperature_sent_to_api"] = story_metadata["temperature_sent_to_api"] or temperature_sent
        story_metadata["hashes"]["llm_story_output_sha256"] = sha256_text(llm_story_text)
        story_metadata["stages"]["generation"].update(
            {
                "status": "success",
                "submitted_to_llm": True,
                "reused_existing_output": False,
                "target_word_count": word_count,
                "response_text": llm_story_text,
                "api_metadata": api_metadata,
                "duration_seconds": round(time.time() - generation_stage_start, 3),
                "error": None,
            }
        )

        free_generation_stage_start = time.time()
        free_generation_request = build_free_generation_request(free_generation_prompt)

        llm_free_story_text, api_metadata, temperature_sent = call_openai_with_retries(
            client,
            model=config.model,
            prompt=free_generation_request,
            temperature=config.temperature,
            max_retries=config.max_retries,
            retry_backoff_seconds=config.retry_backoff_seconds,
        )
        write_text_file(output_paths["llm_free_story"], llm_free_story_text)

        story_metadata["temperature_sent_to_api"] = story_metadata["temperature_sent_to_api"] or temperature_sent
        story_metadata["hashes"]["llm_free_story_output_sha256"] = sha256_text(llm_free_story_text)
        story_metadata["stages"]["free_generation"].update(
            {
                "status": "success",
                "submitted_to_llm": True,
                "reused_existing_output": False,
                "response_text": llm_free_story_text,
                "api_metadata": api_metadata,
                "duration_seconds": round(time.time() - free_generation_stage_start, 3),
                "error": None,
            }
        )

        free_story_metadata = {
            **story_metadata,
            "status": "success",
            "free_generation_only_metadata": True,
            "primary_free_output_file": relpath(output_paths["llm_free_story"], config.script_dir),
        }
        write_json_file(output_paths["llm_free_metadata"], free_story_metadata)

        story_metadata["status"] = "success"
        story_metadata["error"] = None

    except Exception as exc:
        story_metadata["status"] = "failed"
        story_metadata["error"] = str(exc)

        for stage_name, stage in story_metadata.get("stages", {}).items():
            if stage.get("status") == "not_started":
                stage["error"] = None

        logging.error("Failed story %s: %s", story_file.name, exc)
        logging.debug("Traceback for %s:\n%s", story_file.name, traceback.format_exc())

    finally:
        story_metadata["duration_seconds"] = round(time.time() - start_time, 3)
        try:
            write_json_file(output_paths["metadata"], story_metadata)
        except Exception as write_exc:
            logging.error("Could not write per-story metadata for %s: %s", story_file.name, write_exc)

        try:
            if not output_paths["llm_free_metadata"].exists():
                free_story_metadata = {
                    **story_metadata,
                    "free_generation_only_metadata": True,
                    "primary_free_output_file": relpath(output_paths["llm_free_story"], config.script_dir),
                }
                write_json_file(output_paths["llm_free_metadata"], free_story_metadata)
        except Exception as write_exc:
            logging.error("Could not write per-story free metadata for %s: %s", story_file.name, write_exc)

    return story_metadata


# ---------------------------------------------------------------------------
# Manifest
# ---------------------------------------------------------------------------


def count_statuses(results: List[Dict[str, Any]]) -> Dict[str, int]:
    counts = {
        "stories_succeeded": 0,
        "stories_failed": 0,
        "stories_skipped": 0,
        "submitted_plot_extraction": 0,
        "submitted_style_extraction": 0,
        "submitted_generation": 0,
        "submitted_free_generation": 0,
        "failed_metadata_matching": 0,
        "failed_missing_word_count": 0,
        "failed_api_errors": 0,
        "failed_empty_llm_responses": 0,
    }

    for result in results:
        status = result.get("status")
        if status == "success":
            counts["stories_succeeded"] += 1
        elif status == "skipped_existing":
            counts["stories_skipped"] += 1
        elif status == "failed":
            counts["stories_failed"] += 1

        stages = result.get("stages", {})
        if stages.get("plot_extraction", {}).get("submitted_to_llm"):
            counts["submitted_plot_extraction"] += 1
        if stages.get("style_extraction", {}).get("submitted_to_llm"):
            counts["submitted_style_extraction"] += 1
        if stages.get("generation", {}).get("submitted_to_llm"):
            counts["submitted_generation"] += 1
        if stages.get("free_generation", {}).get("submitted_to_llm"):
            counts["submitted_free_generation"] += 1

        error = result.get("error") or ""
        if "match" in error.lower() and "metadata" in error.lower():
            counts["failed_metadata_matching"] += 1
        if "word_count" in error.lower():
            counts["failed_missing_word_count"] += 1
        if "LLM request failed" in error or "API" in error:
            counts["failed_api_errors"] += 1
        if "no usable text" in error:
            counts["failed_empty_llm_responses"] += 1

    return counts


def build_manifest(
    config: Config,
    *,
    start_time: str,
    end_time: str,
    prompt_hashes: Dict[str, str],
    environment_metadata: Dict[str, Any],
    discovered_count: int,
    planned_files: List[Path],
    results: List[Dict[str, Any]],
) -> Dict[str, Any]:
    counts = count_statuses(results)

    return {
        "run_id": config.run_id,
        "programme": PROGRAMME_NAME,
        "start_time": start_time,
        "end_time": end_time,
        "project_phase": "Phase 2",
        "methodological_description": "Traditional / Functional Multi-dimensional Analysis of human-authored and LLM-generated fiction for variation of style",
        "paths": {
            "human_story_input_directory": relpath(config.human_dir, config.script_dir),
            "metadata_ndjson": relpath(config.metadata_ndjson, config.script_dir),
            "plot_style_output_directory": relpath(config.plot_style_dir, config.script_dir),
            "llm_story_output_directory": relpath(config.llm_dir, config.script_dir),
            "llm_free_story_output_directory": relpath(config.llm_free_dir, config.script_dir),
            "env_file": relpath(config.env_file, config.script_dir),
            "plot_prompt_template": relpath(config.plot_prompt_template, config.script_dir),
            "style_prompt_template": relpath(config.style_prompt_template, config.script_dir),
            "generation_prompt_template": relpath(config.generation_prompt_template, config.script_dir),
            "free_generation_prompt_template": relpath(config.free_generation_prompt_template, config.script_dir),
            "log_file": relpath(config.log_file, config.script_dir),
            "manifest_file": relpath(config.manifest_file, config.script_dir),
            "timestamped_manifest_file": relpath(config.timestamped_manifest_file, config.script_dir),
        },
        "environment": environment_metadata,
        "prompt_hashes": prompt_hashes,
        "model_configuration": {
            "model": config.model,
            "temperature": config.temperature,
        },
        "test_mode": {
            "enabled": config.test_mode,
            "test_limit": config.test_limit,
        },
        "processing": {
            "reprocess": config.reprocess,
            "workers": config.workers,
            "max_retries": config.max_retries,
            "retry_backoff_seconds": config.retry_backoff_seconds,
            "start_filename": config.start_filename,
            "order": "natural_filename_order",
        },
        "counts": {
            "human_stories_discovered": discovered_count,
            "stories_planned": len(planned_files),
            **counts,
        },
        "strategy": {
            "study_method": "Traditional / Functional Multi-dimensional Analysis",
            "corpus_design": "human_authored_subcorpus_mirrored_by_two_llm_generated_subcorpora_story_by_story",
            "llm_family": "GPT",
            "model_used_for_all_stages": config.model,
            "stage_1": "plot_extraction_from_original_human_story",
            "stage_2": "style_profile_extraction_from_original_human_story",
            "stage_3": "plot_style_guided_short_story_generation_from_extracted_plot_style_and_target_word_count_only",
            "stage_4": "free_short_story_generation_from_self_contained_prompt_only",
            "generation_context_segregation": "fresh_stateless_generation_request_without_original_story",
            "free_generation_context_segregation": "fresh_stateless_free_generation_request_without_original_story_plot_style_or_word_count",
        },
        "stories": [
            {
                "story_filename": result.get("story_filename"),
                "story_basename": result.get("story_basename"),
                "status": result.get("status"),
                "metadata_file": result.get("output", {}).get("llm_story_metadata_file")
                or result.get("output", {}).get("metadata_file"),
                "llm_story_file": result.get("output", {}).get("llm_story_file"),
                "llm_free_metadata_file": result.get("output", {}).get("llm_free_metadata_file"),
                "llm_free_story_file": result.get("output", {}).get("llm_free_story_file"),
                "error": result.get("error"),
            }
            for result in results
        ],
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> int:
    args = build_arg_parser().parse_args()
    config = make_config(args)

    setup_logging(config)
    run_start = utc_now_iso()

    logging.info("Starting %s run_id=%s", PROGRAMME_NAME, config.run_id)

    try:
        validate_basic_options(config)

        env_file_found = load_dotenv_file(config.env_file)
        api_key_available = bool(os.environ.get("OPENAI_API_KEY"))

        environment_metadata = {
            "env_file": relpath(config.env_file, config.script_dir),
            "env_file_found": env_file_found,
            "openai_api_key_available": api_key_available,
            "openai_api_key_source": "env_file_or_process_environment" if api_key_available else None,
            "openai_api_key_logged": False,
        }

        if not api_key_available:
            raise RuntimeError(
                f"OPENAI_API_KEY is not available after checking "
                f"{relpath(config.env_file, config.script_dir)} and the process environment"
            )

        validate_directories(config)

        plot_prompt = load_prompt(config.plot_prompt_template, "Plot-extraction")
        style_prompt = load_prompt(config.style_prompt_template, "Style-profile extraction")
        generation_prompt_template = load_prompt(config.generation_prompt_template, "Generation")
        free_generation_prompt = load_prompt(config.free_generation_prompt_template, "Free generation")

        if WORD_COUNT_PLACEHOLDER not in generation_prompt_template:
            raise ValueError(
                f"Generation prompt template must contain {WORD_COUNT_PLACEHOLDER}: "
                f"{relpath(config.generation_prompt_template, config.script_dir)}"
            )

        prompt_hashes = {
            "plot_prompt_template_sha256": sha256_text(plot_prompt),
            "style_prompt_template_sha256": sha256_text(style_prompt),
            "generation_prompt_template_sha256": sha256_text(generation_prompt_template),
            "free_generation_prompt_template_sha256": sha256_text(free_generation_prompt),
        }

        metadata_rows, metadata_ndjson_sha256 = load_metadata_rows(config)

        all_human_files = [
            path
            for path in config.human_dir.iterdir()
            if path.is_file() and path.suffix.lower() in SUPPORTED_TEXT_SUFFIXES
        ]
        discovered_count = len(all_human_files)

        planned_files = discover_human_story_files(config)
        logging.info("Discovered %s human story files; planned %s", discovered_count, len(planned_files))

        client = make_openai_client()

        results: List[Dict[str, Any]] = []

        if config.workers == 1:
            for story_file in planned_files:
                logging.info("Processing story: %s", story_file.name)
                result = process_one_story(
                    story_file,
                    config=config,
                    client=client,
                    metadata_rows=metadata_rows,
                    metadata_ndjson_sha256=metadata_ndjson_sha256,
                    plot_prompt=plot_prompt,
                    style_prompt=style_prompt,
                    generation_prompt_template=generation_prompt_template,
                    free_generation_prompt=free_generation_prompt,
                    prompt_hashes=prompt_hashes,
                    environment_metadata=environment_metadata,
                )
                results.append(result)
        else:
            with concurrent.futures.ThreadPoolExecutor(max_workers=config.workers) as executor:
                future_to_story = {
                    executor.submit(
                        process_one_story,
                        story_file,
                        config=config,
                        client=client,
                        metadata_rows=metadata_rows,
                        metadata_ndjson_sha256=metadata_ndjson_sha256,
                        plot_prompt=plot_prompt,
                        style_prompt=style_prompt,
                        generation_prompt_template=generation_prompt_template,
                        free_generation_prompt=free_generation_prompt,
                        prompt_hashes=prompt_hashes,
                        environment_metadata=environment_metadata,
                    ): story_file
                    for story_file in planned_files
                }

                for future in concurrent.futures.as_completed(future_to_story):
                    story_file = future_to_story[future]
                    try:
                        results.append(future.result())
                    except Exception as exc:
                        logging.error("Unexpected worker failure for %s: %s", story_file.name, exc)
                        results.append(
                            {
                                "story_filename": story_file.name,
                                "story_basename": story_file.stem,
                                "status": "failed",
                                "error": str(exc),
                            }
                        )

        run_end = utc_now_iso()
        manifest = build_manifest(
            config,
            start_time=run_start,
            end_time=run_end,
            prompt_hashes=prompt_hashes,
            environment_metadata=environment_metadata,
            discovered_count=discovered_count,
            planned_files=planned_files,
            results=results,
        )

        write_json_file(config.manifest_file, manifest)
        write_json_file(config.timestamped_manifest_file, manifest)

        logging.info(
            "Finished run_id=%s success=%s failed=%s skipped=%s",
            config.run_id,
            manifest["counts"]["stories_succeeded"],
            manifest["counts"]["stories_failed"],
            manifest["counts"]["stories_skipped"],
        )

        return 0 if manifest["counts"]["stories_failed"] == 0 else 1

    except Exception as exc:
        logging.error("Fatal error: %s", exc)
        logging.debug("Fatal traceback:\n%s", traceback.format_exc())

        run_end = utc_now_iso()
        fatal_manifest = {
            "run_id": config.run_id,
            "programme": PROGRAMME_NAME,
            "start_time": run_start,
            "end_time": run_end,
            "status": "failed",
            "error": str(exc),
            "paths": {
                "log_file": relpath(config.log_file, config.script_dir),
                "manifest_file": relpath(config.manifest_file, config.script_dir),
            },
        }

        try:
            write_json_file(config.manifest_file, fatal_manifest)
            write_json_file(config.timestamped_manifest_file, fatal_manifest)
        except Exception:
            pass

        return 1


if __name__ == "__main__":
    raise SystemExit(main())