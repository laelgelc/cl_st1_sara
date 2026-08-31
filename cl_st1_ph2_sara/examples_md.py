#!/usr/bin/env python3
"""
Generate Markdown example text extracts based on extreme factor scores by prompt condition.

For each factor dimension (f1, f2, etc.):
    - Calculate the mean score for each prompt group (human, llm, llm_free).
    - Positive pole: groups ranked by descending mean factor score.
    - Negative pole: groups ranked by ascending mean factor score.
    - Top prompt group: 20 examples.
    - All other prompt groups: 10 examples each.
    - Skip any text where the factor score == 0.

The project name is inferred from the current working directory.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

import pandas as pd


# =============================================================================
# DEFAULTS
# =============================================================================

DEFAULT_PROJECT = Path.cwd().name
DEFAULT_CORPUS_DIR = Path("corpus")
DEFAULT_OUTPUT_DIR = Path("examples_md")
DEFAULT_METADATA_FILE = Path("../cl_st1_ph1_sara/corpus/short_stories.ndjson")


# =============================================================================
# ARGUMENTS
# =============================================================================

def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate Markdown example extracts for factor poles by prompt condition."
    )

    parser.add_argument(
        "--project",
        default=DEFAULT_PROJECT,
        help="Project name. Default: current directory name.",
    )
    parser.add_argument(
        "--sas-output-dir",
        default=None,
        help="Directory containing SAS outputs. Default: sas/output_<project>.",
    )
    parser.add_argument(
        "--corpus-dir",
        default=str(DEFAULT_CORPUS_DIR),
        help="Root directory containing subcorpora. Default: corpus.",
    )
    parser.add_argument(
        "--metadata-file",
        default=str(DEFAULT_METADATA_FILE),
        help="Path to Phase 1 metadata NDJSON file. Default: ../cl_st1_ph1_sara/corpus/short_stories.ndjson",
    )
    parser.add_argument(
        "--loadtable-file",
        default=None,
        help="Path to SAS loadtable HTML file. Default: sas/output_<project>/loadtable.html",
    )
    parser.add_argument(
        "--output-dir",
        default=str(DEFAULT_OUTPUT_DIR),
        help="Directory where example Markdown files will be written. Default: examples_md.",
    )
    parser.add_argument(
        "--top-prompt-examples",
        type=int,
        default=20,
        help="Number of examples for the top-ranked prompt group.",
    )
    parser.add_argument(
        "--other-prompt-examples",
        type=int,
        default=10,
        help="Number of examples for the other prompt groups.",
    )

    return parser.parse_args()


def resolve_sas_output_dir(project: str, sas_output_dir_arg: str | None) -> Path:
    """Resolve the SAS output directory."""
    if sas_output_dir_arg is None:
        return Path("sas") / f"output_{project}"
    return Path(sas_output_dir_arg)


def resolve_loadtable_file(sas_output_dir: Path, loadtable_file_arg: str | None) -> Path:
    """Resolve the SAS loadtable HTML file path."""
    if loadtable_file_arg is None:
        return sas_output_dir / "loadtable.html"
    return Path(loadtable_file_arg)


# =============================================================================
# HELPERS
# =============================================================================

def natural_sort_key(value: str) -> list[Any]:
    """Return a natural-sort key that treats digit runs as integers."""
    return [int(part) if part.isdigit() else part.lower() for part in re.split(r"(\d+)", value)]


def detect_factor_columns(scores_df: pd.DataFrame) -> list[str]:
    """Detect factor-score columns named f1, f2, etc."""
    factor_columns = [
        column for column in scores_df.columns
        if re.fullmatch(r"f\d+", str(column))
    ]

    if not factor_columns:
        raise RuntimeError("No f<n> columns found in scores CSV file.")

    return sorted(factor_columns, key=natural_sort_key)


def get_story_id(filename: str) -> str:
    """Extract the base story ID from a filename by stripping expected suffixes."""
    return re.sub(r'(_llm_free|_llm)?\.txt$', '', filename)


def get_full_text_path(prompt: str, filename: str, corpus_dir: Path) -> Path:
    """Resolve the path to the raw text file based on the prompt condition."""
    if prompt == "human":
        return corpus_dir / "01_human" / filename
    elif prompt == "llm":
        return corpus_dir / "03_llm" / filename
    elif prompt == "llm_free":
        return corpus_dir / "04_llm_free" / filename
    raise ValueError(f"Unknown prompt type: {prompt}")


def format_author_title(prompt: str, original_author: str, original_title: str) -> tuple[str, str]:
    """Prefix the author and title for LLM texts."""
    if prompt == "human":
        return original_author, original_title
    elif prompt == "llm":
        return f"LLM mirror of {original_author}", f"LLM mirror of {original_title}"
    elif prompt == "llm_free":
        return f"LLM free mirror of {original_author}", f"LLM free mirror of {original_title}"
    return original_author, original_title


def load_metadata(ndjson_path: Path) -> dict[str, dict[str, str]]:
    """Load the short stories NDJSON metadata into a lookup by story_id."""
    if not ndjson_path.exists():
        raise FileNotFoundError(f"Metadata file not found: {ndjson_path}")

    meta = {}
    with ndjson_path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            data = json.loads(line)
            story_id = data.get("story_id")
            if story_id:
                meta[story_id] = {
                    "author": data.get("author", "Unknown Author"),
                    "title": data.get("title", "Unknown Title")
                }

    if not meta:
        raise ValueError(f"No valid records found in metadata file: {ndjson_path}")

    return meta


def parse_loadtable(html_path: Path) -> dict[str, list[str]]:
    """Parse the SAS loadtable HTML to extract linguistic features per factor pole."""
    if not html_path.exists():
        print(f"⚠ Warning: Loadtable file missing ({html_path}). Loading features will be empty.")
        return {}

    content = html_path.read_text(encoding="utf-8")

    # The SAS HTML puts the factor pole headers into a td or th with class "systemtitle" or "systemtitle2"
    pattern = re.compile(r'>\s*(Factor\s+\d+\s+(?:pos|neg))\s*<', re.IGNORECASE)
    matches = list(pattern.finditer(content))

    features_lookup = {}

    for i, match in enumerate(matches):
        raw_name = match.group(1).lower()
        parts = raw_name.split()
        # parts -> ["factor", "1", "pos"] -> key: "f1_pos"
        key = f"f{parts[1]}_{parts[2]}"

        start_idx = match.end()
        end_idx = matches[i+1].start() if i + 1 < len(matches) else len(content)
        block = content[start_idx:end_idx]

        # Features are listed in <td class="l data">Feature Name</td>
        feature_matches = re.findall(r'<td class="l data">([^<]+)</td>', block)
        features_lookup[key] = [f.strip() for f in feature_matches if f.strip()]

    return features_lookup


def write_md_example(
        out_file: Path,
        prompt: str,
        filepath: Path,
        author: str,
        title: str,
        score: float,
        label: str,
        features: list[str],
        raw_text: str
) -> None:
    """Write one Markdown example file."""
    features_str = ", ".join(features)

    # Using two spaces at the end of each line forces a line break in Markdown,
    # preventing the header lines from being collapsed into a single paragraph.
    content = (
        f"**Prompt:** {prompt}  \n"
        f"**Filepath**: {filepath.as_posix()}  \n"
        f"**Author**: {author}  \n"
        f"**Title:** {title}  \n"
        f"**Score ({label}):** {score:.2f}  \n"
        f"**Loading features ({label}), N={len(features)}:** {features_str}  \n\n"
        f"---\n\n"
        f"{raw_text}\n"
    )

    out_file.write_text(content, encoding="utf-8")


# =============================================================================
# MAIN
# =============================================================================

def main() -> None:
    """Generate Markdown example extracts for all factors and poles."""
    args = parse_args()

    project = args.project
    sas_output_dir = resolve_sas_output_dir(project, args.sas_output_dir)
    corpus_dir = Path(args.corpus_dir)
    metadata_file = Path(args.metadata_file)
    loadtable_file = resolve_loadtable_file(sas_output_dir, args.loadtable_file)
    output_dir = Path(args.output_dir)

    # Validate inputs
    scores_file = sas_output_dir / f"{project}_scores_only.csv"
    if not scores_file.exists():
        raise FileNotFoundError(f"Scores CSV file not found: {scores_file}")

    if not corpus_dir.exists():
        raise FileNotFoundError(f"Corpus directory not found: {corpus_dir}")

    # Load lookup structures
    metadata_lookup = load_metadata(metadata_file)
    loading_features_lookup = parse_loadtable(loadtable_file)

    # Load and process scores
    scores_df = pd.read_csv(scores_file)

    required_columns = {"prompt", "filename"}
    missing_columns = required_columns - set(scores_df.columns)
    if missing_columns:
        raise ValueError(
            f"{scores_file} is missing required columns: "
            f"{', '.join(sorted(missing_columns))}"
        )

    factor_columns = detect_factor_columns(scores_df)

    print(f"Project: {project}")
    print(f"Scores file: {scores_file}")
    print(f"Detected {len(factor_columns)} factors: {', '.join(factor_columns)}.\n")

    output_dir.mkdir(exist_ok=True, parents=True)
    missing_files = set()

    # Calculate means per prompt group for ranking
    means_df = scores_df.groupby("prompt")[factor_columns].mean()

    for factor_column in factor_columns:
        for pole, ascending in (("pos", False), ("neg", True)):
            label = f"{factor_column}_{pole}"

            # Rank prompts based on the calculated means
            ranked_prompts = means_df[factor_column].sort_values(ascending=ascending).index.tolist()

            if not ranked_prompts:
                print(f"  No prompts found for {label}; skipping.")
                continue

            top_prompt = ranked_prompts[0]
            other_prompts = ranked_prompts[1:]

            print(
                f"→ {label}: selecting by prompt means "
                f"(ranked: {', '.join(ranked_prompts)})"
            )

            out_dir = output_dir / label
            out_dir.mkdir(parents=True, exist_ok=True)

            features = loading_features_lookup.get(label, [])

            # Sort the entire dataset for this factor
            sorted_df = scores_df.sort_values(by=factor_column, ascending=ascending)

            example_id = 1

            # Top prompt group: more examples.
            top_prompt_df = sorted_df[sorted_df["prompt"] == top_prompt]
            count = 0
            for _, row in top_prompt_df.iterrows():
                if row[factor_column] == 0:
                    continue
                if count >= args.top_prompt_examples:
                    break

                filename = str(row["filename"]).strip()
                prompt = str(row["prompt"]).strip()
                score = float(row[factor_column])

                raw_text_path = get_full_text_path(prompt, filename, corpus_dir)
                if not raw_text_path.exists():
                    missing_files.add(str(raw_text_path))
                    continue

                story_id = get_story_id(filename)
                meta = metadata_lookup.get(story_id, {"author": "Unknown", "title": "Unknown"})

                formatted_author, formatted_title = format_author_title(prompt, meta["author"], meta["title"])
                raw_text = raw_text_path.read_text(encoding="utf-8", errors="ignore")

                out_file = out_dir / f"{label}_{example_id:03d}.md"
                write_md_example(
                    out_file=out_file,
                    prompt=prompt,
                    filepath=raw_text_path,
                    author=formatted_author,
                    title=formatted_title,
                    score=score,
                    label=label,
                    features=features,
                    raw_text=raw_text
                )
                count += 1
                example_id += 1

            # Other prompt groups: fewer examples each.
            for other_prompt in other_prompts:
                other_prompt_df = sorted_df[sorted_df["prompt"] == other_prompt]
                count = 0
                for _, row in other_prompt_df.iterrows():
                    if row[factor_column] == 0:
                        continue
                    if count >= args.other_prompt_examples:
                        break

                    filename = str(row["filename"]).strip()
                    prompt = str(row["prompt"]).strip()
                    score = float(row[factor_column])

                    raw_text_path = get_full_text_path(prompt, filename, corpus_dir)
                    if not raw_text_path.exists():
                        missing_files.add(str(raw_text_path))
                        continue

                    story_id = get_story_id(filename)
                    meta = metadata_lookup.get(story_id, {"author": "Unknown", "title": "Unknown"})

                    formatted_author, formatted_title = format_author_title(prompt, meta["author"], meta["title"])
                    raw_text = raw_text_path.read_text(encoding="utf-8", errors="ignore")

                    out_file = out_dir / f"{label}_{example_id:03d}.md"
                    write_md_example(
                        out_file=out_file,
                        prompt=prompt,
                        filepath=raw_text_path,
                        author=formatted_author,
                        title=formatted_title,
                        score=score,
                        label=label,
                        features=features,
                        raw_text=raw_text
                    )
                    count += 1
                    example_id += 1

            print(f"  ✓ Wrote {example_id - 1} examples for {label}\n")

    if missing_files:
        missing_path = Path("missing_files.txt")
        missing_path.write_text("\n".join(sorted(missing_files)), encoding="utf-8")
        print(f"⚠ Missing files written to {missing_path}")


if __name__ == "__main__":
    main()