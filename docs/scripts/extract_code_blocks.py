#!/usr/bin/env python3
"""
Extract fenced code blocks of a given language from one or more Markdown
files and write each block to its own file in an output directory.

Usage:
    python extract_code_blocks.py --lang python --out /tmp/py_blocks docs/*.md
    python extract_code_blocks.py --lang bash   --out /tmp/curl_blocks docs/*.md
"""
import argparse
import pathlib
import re
import sys

FENCE_RE = re.compile(r"```(\w+)\n(.*?)```", re.DOTALL)

EXT_MAP = {
    "python": "py",
    "bash": "sh",
    "sh": "sh",
    "json": "json",
}


def extract(md_path: pathlib.Path, lang: str):
    text = md_path.read_text(encoding="utf-8")
    blocks = []
    for match in FENCE_RE.finditer(text):
        block_lang, body = match.group(1), match.group(2)
        if block_lang.lower() == lang.lower():
            blocks.append(body.strip("\n"))
    return blocks


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lang", required=True, help="Fence language to extract, e.g. python, bash")
    parser.add_argument("--out", required=True, help="Output directory for extracted blocks")
    parser.add_argument("files", nargs="+", help="Markdown files to scan")
    args = parser.parse_args()

    out_dir = pathlib.Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    ext = EXT_MAP.get(args.lang.lower(), "txt")

    total = 0
    for file_arg in args.files:
        md_path = pathlib.Path(file_arg)
        if not md_path.exists():
            print(f"WARN: {md_path} not found, skipping", file=sys.stderr)
            continue
        blocks = extract(md_path, args.lang)
        for i, block in enumerate(blocks, start=1):
            out_file = out_dir / f"{md_path.stem}__block{i}.{ext}"
            out_file.write_text(block + "\n", encoding="utf-8")
            total += 1
            print(f"Extracted {out_file}")

    print(f"\n{total} '{args.lang}' block(s) extracted to {out_dir}")
    if total == 0:
        sys.exit(0)


if __name__ == "__main__":
    main()
