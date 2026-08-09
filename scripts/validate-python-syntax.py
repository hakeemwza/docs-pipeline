#!/usr/bin/env python3
"""
Validate that every extracted Python code sample is at least syntactically
valid (compiles). This catches copy-paste errors, indentation mistakes, and
stale API usage that no longer parses -- the most common way documentation
code samples silently rot.

Usage:
    python validate_python_syntax.py /tmp/py_blocks
"""
import pathlib
import py_compile
import sys


def main():
    if len(sys.argv) != 2:
        print("Usage: validate_python_syntax.py <dir_of_py_files>", file=sys.stderr)
        sys.exit(2)

    target_dir = pathlib.Path(sys.argv[1])
    py_files = sorted(target_dir.glob("*.py"))

    if not py_files:
        print(f"No .py files found in {target_dir} -- nothing to validate.")
        sys.exit(0)

    failures = []
    for f in py_files:
        try:
            py_compile.compile(str(f), doraise=True)
            print(f"OK   {f.name}")
        except py_compile.PyCompileError as e:
            print(f"FAIL {f.name}\n     {e}")
            failures.append(f.name)

    if failures:
        print(f"\n{len(failures)} of {len(py_files)} sample(s) failed to compile: {failures}")
        sys.exit(1)

    print(f"\nAll {len(py_files)} Python sample(s) are syntactically valid.")


if __name__ == "__main__":
    main()
