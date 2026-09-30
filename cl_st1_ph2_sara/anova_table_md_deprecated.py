#!/usr/bin/env python3
"""
Reads the SAS GLM HTML output and generates a Markdown ANOVA table.
Extracts Dimension, F, p, and R^2 % using the Type I SS tables.
"""

import argparse
import re
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate ANOVA Markdown table from SAS GLM HTML output.")
    parser.add_argument(
        "--input-file",
        default="sas/output_cl_st1_ph2_sara/glm_meta.html",
        help="Path to the SAS HTML output file."
    )
    parser.add_argument(
        "--output-dir",
        default="anova_table_md",
        help="Directory to save the Markdown table."
    )
    return parser.parse_args()


def extract_stats(html_content: str) -> list[dict[str, str]]:
    """Extract ANOVA statistics for each dependent variable."""
    # Split the document into sections by dependent variable
    sections = re.split(r'<div class="c proctitle">Dependent Variable:\s*(f\d+)', html_content)

    results = []

    # sections[0] is everything before the first Dependent Variable, skip it.
    # sections[1] is the first var name (e.g., 'f1'), sections[2] is its content, etc.
    for i in range(1, len(sections), 2):
        dim_name = sections[i].strip()
        dim_num = dim_name.replace('f', '')
        content = sections[i + 1]

        # Extract R-Square
        r_square_match = re.search(
            r'summary="Procedure GLM: Fit Statistics".*?<tbody>\s*<tr>\s*<td[^>]*>([\d.-]+)</td>',
            content,
            re.DOTALL | re.IGNORECASE
        )
        r_square = float(r_square_match.group(1)) if r_square_match else 0.0
        r_square_pct = f"{r_square * 100:.2f}"

        # Extract Type I ANOVA F and p for 'prompt'
        # The row structure: <th scope="row">prompt</th> <td>DF</td> <td>Type I SS</td> <td>Mean Square</td> <td>F Value</td> <td>Pr > F</td>
        type_i_match = re.search(
            r'summary="Procedure GLM: Type I Model ANOVA".*?<th[^>]*>prompt</th>\s*<td[^>]*>.*?</td>\s*<td[^>]*>.*?</td>\s*<td[^>]*>.*?</td>\s*<td[^>]*>([\d.-]+)</td>\s*<td[^>]*>([^<]+)</td>',
            content,
            re.DOTALL | re.IGNORECASE
        )

        if type_i_match:
            f_value = type_i_match.group(1).strip()
            p_value = type_i_match.group(2).strip().replace('&lt;', '<')
        else:
            f_value = "N/A"
            p_value = "N/A"

        results.append({
            "Dimension": dim_num,
            "F": f_value,
            "p": p_value,
            "R2": r_square_pct
        })

    return results


def main() -> None:
    args = parse_args()
    input_path = Path(args.input_file)
    output_dir = Path(args.output_dir)

    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    html_content = input_path.read_text(encoding="utf-8")
    stats = extract_stats(html_content)

    if not stats:
        print("No ANOVA statistics found in the HTML file.")
        return

    output_dir.mkdir(parents=True, exist_ok=True)
    out_file = output_dir / "anova_by_prompt.md"

    # Build the Markdown table
    md_lines = [
        "Table: ANOVA by Prompt",
        "",
        "| Dimension | F | p | R² % |",
        "|---|---|---|---|"
    ]

    for stat in stats:
        md_lines.append(f"| {stat['Dimension']} | {stat['F']} | {stat['p']} | {stat['R2']} |")

    out_file.write_text("\n".join(md_lines) + "\n", encoding="utf-8")
    print(f"✓ Created {out_file}")


if __name__ == "__main__":
    main()