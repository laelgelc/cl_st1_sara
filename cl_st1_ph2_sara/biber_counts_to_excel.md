## `biber_counts_to_excel` command-line programme specification

### Programme name

```bash
biber_counts_to_excel
```

or as a script:

```bash
python biber_counts_to_excel.py
```

## Supported input modes

The programme should support **two mutually exclusive input modes**.

### 1. Single-file mode

```bash
python biber_counts_to_excel.py --input-file counts.txt --output counts.xlsx
```

This reads one Biber Tag Count file and writes one `.xlsx` file.

### 2. Directory mode

```bash
python biber_counts_to_excel.py --input-dir counts --output-dir excel
```

This reads every regular file in `counts/` and writes one workbook per input file:

```text
excel/counts.xlsx
```

or, if the input file is `counts.txt`:

```text
excel/counts.xlsx
```

An alternative naming strategy would be:

```text
excel/counts.txt.xlsx
```

I would recommend:

```text
counts.xlsx
```

because it is cleaner and avoids stacked extensions.

## Optional combined workbook mode

It may also be useful to support a combined output workbook:

```bash
python biber_counts_to_excel.py \
  --input-dir counts \
  --combined-output all_biber_counts.xlsx
```

In that case, the programme could either:

1. create one worksheet per input file; or
2. append all rows into one worksheet named `biber_counts`.

For statistical analysis, the second option is usually more convenient:

```text
all_biber_counts.xlsx
└── biber_counts
```

## Proposed CLI

```bash
python biber_counts_to_excel.py \
  (--input-file PATH | --input-dir PATH) \
  [--output PATH | --output-dir PATH | --combined-output PATH] \
  [--sheet-name NAME] \
  [--overwrite] \
  [--verbose]
```

## Recommended option behaviour

| Option | Required | Description |
|---|---:|---|
| `--input-file` | Either this or `--input-dir` | Parse one Biber Tag Count file |
| `--input-dir` | Either this or `--input-file` | Parse all files in a directory |
| `--output` | Required with `--input-file`, unless default is used | Output `.xlsx` path |
| `--output-dir` | Required with `--input-dir`, unless default is used | Directory for per-file `.xlsx` outputs |
| `--combined-output` | Optional | Create one combined `.xlsx` workbook |
| `--sheet-name` | Optional | Worksheet name, default `biber_counts` |
| `--overwrite` | Optional | Replace existing output files |
| `--verbose` | Optional | Print progress messages |

## Example commands

### Single file to Excel

```bash
python biber_counts_to_excel.py \
  --input-file counts.txt \
  --output counts.xlsx
```

### Single file with default output name

```bash
python biber_counts_to_excel.py --input-file counts.txt
```

Expected output:

```text
counts.xlsx
```

### Directory to individual Excel files

```bash
python biber_counts_to_excel.py \
  --input-dir counts \
  --output-dir excel
```

### Directory to one combined Excel file

```bash
python biber_counts_to_excel.py \
  --input-dir counts \
  --combined-output all_counts.xlsx
```

## Hardcoded header

The script can define the column names directly as a Python list:

```python
BIBER_COLUMNS = [
    "filename",
    "ttr",
    "wrlengh",
    "wcount",
    "prv_vb",
    "that_del",
    "contrac",
    "pres",
    "pro2",
    "pro_do",
    "pdem",
    "gen_emph",
    "pro1",
    "it",
    "be_state",
    "sub_cos",
    "prtcle",
    "pany",
    "gen_hdg",
    "amplifr",
    "wh_ques",
    "pos_mod",
    "o_and",
    "wh_cl",
    "finlprep",
    "n",
    "prep",
    "adj_attr",
    "pasttnse",
    "pro3",
    "perfects",
    "pub_vb",
    "rel_obj",
    "rel_subj",
    "rel_pipe",
    "p_and",
    "n_nom",
    "tm_adv",
    "pl_adv",
    "advs",
    "inf",
    "prd_mod",
    "sua_vb",
    "sub_cnd",
    "nec_mod",
    "spl_aux",
    "conjncts",
    "agls_psv",
    "by_pasv",
    "whiz_vbn",
    "sub_othr",
    "vcmo",
    "downtone",
    "pred_adj",
    "allmodal",
    "allconj",
    "allpasv",
    "allwh",
    "allwhrel",
    "alladj",
    "allpro",
    "have",
    "allverb",
    "vprogrsv",
    "that_rel",
    "jcmp",
    "nonf_vth",
    "att_vth",
    "fact_vth",
    "lkly_vth",
    "att_jth",
    "fact_jth",
    "lkly_jth",
    "nfct_nth",
    "att_nth",
    "fct_nth",
    "lkly_nth",
    "spch_vto",
    "mntl_vto",
    "dsre_vto",
    "efrt_vto",
    "prob_vto",
    "x1_jto",
    "x2_jto",
    "x3_jto",
    "x4_jto",
    "x5_jto",
    "all_nto",
    "nonfadvl",
    "atadvl",
    "factadvl",
    "lklydvl",
    "all_vth",
    "all_jth",
    "all_nth",
    "all_th",
    "all_vto",
    "all_jto",
    "all_to",
    "all_advl",
    "act_ipv",
    "act_tpv",
    "mentalpv",
    "commpv",
    "occurpv",
    "copulapv",
    "aspectpv",
    "humann",
    "prcessn",
    "cognitn",
    "abstrcn",
    "concrtn",
    "tccncrt",
    "quann",
    "placen",
    "groupn",
    "sizej",
    "timej",
    "colorj",
    "evalj",
    "relatnj",
    "topicj",
    "actv",
    "commv",
    "mentalv",
    "causev",
    "occurv",
    "existv",
    "aspectv",
    "dim1",
    "dim2",
    "dim3",
    "dim4",
    "dim5",
]
```

## Important design point

Because the output columns are fixed, the parser can return each row as a list with exactly the same length and order as `BIBER_COLUMNS`.

That means the programme does **not** need to expose intermediate `c11`, `c21`, etc. variables outside the parser. Internally, however, keeping a mapping from fixed-width positions to output fields is still useful because the original record layout is irregular.

## Excel output

Since `openpyxl` is already available in the Python environment, the programme can create real Excel files directly.

Example writer function:

```python
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Font
from openpyxl.utils import get_column_letter


def write_xlsx(
    output_path: Path,
    columns: list[str],
    rows: list[list[object]],
    sheet_name: str = "biber_counts",
) -> None:
    workbook = Workbook()
    worksheet = workbook.active
    worksheet.title = sheet_name

    worksheet.append(columns)

    for cell in worksheet[1]:
        cell.font = Font(bold=True)

    for row in rows:
        worksheet.append(row)

    worksheet.freeze_panes = "A2"
    worksheet.auto_filter.ref = worksheet.dimensions

    for column_index, column_name in enumerate(columns, start=1):
        column_letter = get_column_letter(column_index)
        width = max(10, min(max(len(column_name) + 2, 12), 30))
        worksheet.column_dimensions[column_letter].width = width

    output_path.parent.mkdir(parents=True, exist_ok=True)
    workbook.save(output_path)
```

## Type handling

The output should ideally store:

- `filename` as text;
- all other columns as numbers where possible.

So the parser can convert values like:

```text
6.8
34
-32.62
0.0
```

to Python `int` or `float`.

Suggested helper:

```python
def coerce_value(value: str) -> str | int | float:
    value = value.strip()

    if value == "":
        return ""

    try:
        number = float(value)
    except ValueError:
        return value

    if number.is_integer() and "." not in value:
        return int(number)

    return number
```

This helps Excel treat columns as numeric data immediately, which is better than writing everything as text.

## Single-file versus directory logic

The script should enforce that exactly one of `--input-file` or `--input-dir` is provided.

Example with `argparse`:

```python
import argparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert fixed-format Biber Tag Count output to Excel .xlsx."
    )

    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument("--input-file", type=Path)
    input_group.add_argument("--input-dir", type=Path)

    parser.add_argument("--output", type=Path)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--combined-output", type=Path)
    parser.add_argument("--sheet-name", default="biber_counts")
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--verbose", action="store_true")

    return parser.parse_args()
```

## Suggested output defaults

### If `--input-file counts.txt` is used

Default output:

```text
counts.xlsx
```

### If `--input-dir counts` is used

Default output directory:

```text
xlsx
```

or:

```text
excel
```

I would recommend:

```text
excel
```

## Proposed processing flow

### Single-file mode

1. Validate input file exists.
2. Parse the file into rows.
3. Validate each row has the same number of fields as `BIBER_COLUMNS`.
4. Write `.xlsx`.

### Directory mode

1. Validate input directory exists.
2. Find all regular files inside it.
3. Ignore hidden files unless an option such as `--include-hidden` is added.
4. Parse each file.
5. Either:
   - write one `.xlsx` per file, or
   - append all rows to a combined workbook.

## Recommended validation

The programme should fail fast if the fixed format is violated.

Useful checks:

```python
if len(record) != 12:
    raise ValueError("Incomplete 12-line Biber record")

if len(row) != len(BIBER_COLUMNS):
    raise ValueError(
        f"Column mismatch: parsed {len(row)} values, "
        f"expected {len(BIBER_COLUMNS)}"
    )
```

## Proposed script capabilities summary

The revised Python programme should:

- be self-contained;
- hardcode the fixed Biber column names;
- parse a single Biber count file;
- parse a directory of Biber count files;
- output real `.xlsx` workbooks;
- write numeric cells as numbers;
- freeze the header row;
- add Excel autofilters;
- optionally produce one workbook per input file or one combined workbook.

## Recommended final command examples

For your current workflow, the likely replacement command would be:

```bash
python biber_counts_to_excel.py \
  --input-file counts.txt \
  --output counts.xlsx
```

For a directory workflow:

```bash
python biber_counts_to_excel.py \
  --input-dir counts \
  --output-dir excel
```

For one combined workbook from a directory:

```bash
python biber_counts_to_excel.py \
  --input-dir counts \
  --combined-output counts.xlsx
```
