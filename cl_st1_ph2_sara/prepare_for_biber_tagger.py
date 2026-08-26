"""
Prepare text files for the Biber Tagger.

This script reads all .txt files from a specified input directory, applies specific
text transformations required for the Biber Tagger, and saves the processed files
into an output directory.

Transformations applied:
1. Detects and replaces curly inverted commas with straight quotes.
2. Inserts a space between digits and letters (and vice-versa).
3. Wraps every 10 words within each text line.

Usage:
    python prepare_for_biber_tagger.py \
        --input-dir <path_to_input> \
        --output-dir <path_to_output>
"""

import argparse
import os
import re
from pathlib import Path
from tqdm import tqdm

def process_text(text: str) -> str:
    # 1. Detect and replace curly inverted commas by straight quotes
    text = text.replace('‘', "'").replace('’', "'").replace('“', '"').replace('”', '"')

    # 2. Insert a space between digit and letter (handles both digit->letter and letter->digit)
    text = re.sub(r'(\d)([a-zA-Z])', r'\1 \2', text)
    text = re.sub(r'([a-zA-Z])(\d)', r'\1 \2', text)

    # 3. Wrap every 10 words within each text line
    new_lines = []
    for line in text.splitlines():
        words = line.split()
        if not words:
            # Preserve empty lines
            new_lines.append('')
        else:
            # Chunk words into groups of 10
            for i in range(0, len(words), 10):
                new_lines.append(' '.join(words[i:i+10]))

    return '\n'.join(new_lines)

def main():
    parser = argparse.ArgumentParser(description="Prepare text files for Biber Tagger.")
    parser.add_argument('--input-dir', type=str, required=True, help="Path to the input directory containing .txt files")
    parser.add_argument('--output-dir', type=str, required=True, help="Path to the output directory")

    args = parser.parse_args()

    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir)

    if not input_dir.is_dir():
        print(f"Error: Input directory '{input_dir}' does not exist.")
        return

    # Ensure the output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)

    # Get all .txt files
    txt_files = list(input_dir.glob("*.txt"))

    if not txt_files:
        print(f"No .txt files found in {input_dir}")
        return

    # Process files with a progress bar
    for file_path in tqdm(txt_files, desc="Processing text files"):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            processed_content = process_text(content)

            output_file_path = output_dir / file_path.name
            with open(output_file_path, 'w', encoding='utf-8') as f:
                f.write(processed_content)

        except Exception as e:
            print(f"\nError processing {file_path.name}: {e}")

if __name__ == '__main__':
    main()