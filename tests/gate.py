#!/usr/bin/env python3
"""Generation gate for openprime-infra-templates.

Runs Injecto over the templates with a fixture and fails on the failure modes
Injecto itself reports only as warnings while still exiting 0:

  1. a file was dropped from the output (Injecto logs the exception, continues)
  2. an @param under an ENABLED service did not resolve, so the template default
     ships to the customer instead of their value
  3. an @param resolved but the output still carries the template default
  4. a NEW inert @param appeared - a decorator sitting above a line Injecto's
     substitution can never rewrite, so it silently parameterizes nothing

Exit code 0 = pass, 1 = gate failure, 2 = harness error.

Usage:
    python tests/gate.py --injecto <path-to-Injecto> --fixture tests/fixtures/standard.json
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PARAM_RE = re.compile(r"#\s*@param\s+([\w.-]+)")
SECTION_RE = re.compile(r"#\s*@section\s+([\w.-]+)")
# Mirrors Injecto processing.py: only this shape can be rewritten.
VALUE_LINE_RE = re.compile(r"^(\s*(?:-\s+)?[\w.-]+\s*[:=])(.*)$")
NOT_FOUND_RE = re.compile(r"Path '([\w.-]+)' not found in the data values")
FILE_ERROR_RE = re.compile(r"An unexpected error occurred processing (\S+)")
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

REPO_ROOT = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = REPO_ROOT / "templates"
INERT_BASELINE = REPO_ROOT / "tests" / "inert-params.txt"
KNOWN_UNRESOLVED = REPO_ROOT / "tests" / "known-unresolved.txt"


def read_baseline(path):
    """Read a baseline file, ignoring blanks and # comments."""
    if not path.exists():
        return set()
    return {
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }


class Failure(list):
    """Collected gate failures; truthy when the gate should fail."""

    def add(self, code, detail):
        self.append((code, detail))


def materialize_clean_templates(dest):
    """Copy only git-tracked template files into dest.

    The gate must see exactly what a fresh CI checkout sees. A developer's
    working tree carries .terraform/ provider caches and vendored module
    checkouts; feeding those to Injecto produces a flood of phantom dropped-file
    errors and @param paths that belong to third-party modules, not to us.
    """
    listing = subprocess.run(
        ["git", "-C", str(REPO_ROOT), "ls-files", "-z", "templates"],
        capture_output=True,
        check=True,
    )
    names = [n for n in listing.stdout.decode().split("\0") if n]
    if not names:
        raise RuntimeError("git ls-files returned no template files")
    for name in names:
        src = REPO_ROOT / name
        if not src.is_file():
            continue  # deleted-but-tracked
        target = dest / Path(name).relative_to("templates")
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, target)
    return len(names)


def scan_decorators(templates_dir):
    """Return (substitutable, inert, sections) for @param/@section in the templates.

    substitutable: [(path, relfile, line_index_of_value_line)]
    inert:         ["relfile:line path -> reason"]  (sorted, stable for baselining)
    sections:      {dotted condition path}
    """
    substitutable, inert, sections = [], [], set()
    for path in sorted(templates_dir.rglob("*")):
        if not path.is_file():
            continue
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue
        rel = path.relative_to(templates_dir).as_posix()
        for i, line in enumerate(lines):
            s = SECTION_RE.search(line)
            if s:
                sections.add(s.group(1))
            m = PARAM_RE.search(line)
            if not m:
                continue
            param = m.group(1)
            if i + 1 >= len(lines):
                inert.append(f"{rel}:{i + 1} {param} -> no following line")
                continue
            nxt = lines[i + 1]
            if nxt.lstrip().startswith("#"):
                inert.append(f"{rel}:{i + 1} {param} -> next line is a comment")
            elif not VALUE_LINE_RE.match(nxt):
                inert.append(f"{rel}:{i + 1} {param} -> next line is not a key/value line")
            else:
                substitutable.append((param, rel, i + 1))
    return substitutable, sorted(inert), sections


def lookup(data, dotted):
    """Resolve a dotted path in the fixture, mirroring Injecto's get_value_by_path."""
    node = data
    for key in dotted.split("."):
        try:
            node = node[key]
        except (KeyError, TypeError, AttributeError):
            return None
    return node


def is_enabled(data, param):
    """Is this param's owning service enabled in the fixture?

    Injecto emits a not-found warning for every unresolved path, including
    params of services the user deliberately left off. Only params belonging to
    an ENABLED service (or a non-service root path) are the gate's business.
    """
    if not param.startswith("services."):
        return True
    parts = param.split(".")
    if len(parts) < 3:
        return True
    service = lookup(data, f"services.{parts[1]}")
    return bool(service) and bool(service.get("enabled"))


def format_expected(value):
    """Mirror Injecto processing.format_value_for_file exactly.

    Kept in the same order as the original so the two cannot drift apart
    silently: str (with already-quoted passthrough) -> bool -> list/dict -> str().
    """
    if isinstance(value, str):
        if (value.startswith('"') and value.endswith('"')) or (
            value.startswith("'") and value.endswith("'")
        ):
            return value
        return f'"{value}"'
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, (list, dict)):
        return json.dumps(value)
    return str(value)


def hcl_spacing(text):
    """Collapse whitespace around HCL structural punctuation, nothing else."""
    return re.sub(r"\s*([{}:,])\s*", r"\1", text)


def run_injecto(injecto_dir, templates_dir, fixture_path, out_dir):
    """Run the Injecto CLI; return (exit_code, ansi-stripped combined output)."""
    # Resolved up front: the CLI runs with cwd=<injecto>/src, so a relative
    # --injecto (".injecto" in CI) would otherwise be re-resolved against that
    # cwd and double the path.
    injecto_src = (Path(injecto_dir).resolve() / "src")
    env = dict(os.environ, PYTHONPATH=str(injecto_src))
    proc = subprocess.run(
        [
            sys.executable,
            str(injecto_src / "main.py"),
            # Injecto runs with cwd=<injecto>/src, so every path must be absolute.
            "--input-dir", str(Path(templates_dir).resolve()),
            "--output-dir", str(Path(out_dir).resolve()),
            "--data-files", str(Path(fixture_path).resolve()),
        ],
        cwd=str(injecto_src),
        env=env,
        capture_output=True,
        text=True,
    )
    return proc.returncode, ANSI_RE.sub("", proc.stdout + proc.stderr)


def check_dropped_files(log, failures):
    for m in FILE_ERROR_RE.finditer(log):
        failures.add("DROPPED_FILE", f"{m.group(1)} threw during processing and is absent from the output")


def check_unresolved(log, data, param_paths, sections, failures):
    """Fail on unresolved @param paths that belong to enabled services.

    Injecto emits the same "not found" warning for @param lookups and @section
    condition lookups, but the consequences are opposite:

      - an unresolved @section leaves the section switched OFF. Safe default.
      - an unresolved @param leaves the TEMPLATE DEFAULT in the output, which is
        how a customer ends up with the vendor's repo URL or a placeholder
        bucket name while the request still reports success.

    Only the second kind is a gate failure. Paths that are section-only are
    reported so an unexpected one is still visible.
    """
    known = read_baseline(KNOWN_UNRESOLVED)
    section_only = []
    seen = set()
    for m in NOT_FOUND_RE.finditer(log):
        path = m.group(1)
        if path in seen or path in known:
            continue
        seen.add(path)
        if path not in param_paths:
            if path in sections:
                section_only.append(path)
            else:
                failures.add("UNKNOWN_PATH", f"{path} was looked up but is neither an @param nor an @section")
            continue
        if is_enabled(data, path):
            failures.add(
                "UNRESOLVED_PARAM",
                f"{path} is unset but its service is enabled - the template default ships instead",
            )
    return sorted(section_only)


def check_substituted(substitutable, data, out_dir, failures):
    """Every resolvable param must actually appear substituted in the output."""
    by_file = {}
    for param, rel, value_line_no in substitutable:
        by_file.setdefault(rel, []).append((param, value_line_no))

    for rel, entries in sorted(by_file.items()):
        out_file = out_dir / rel
        if not out_file.exists():
            failures.add("MISSING_OUTPUT", f"{rel} is missing from the generated tree")
            continue
        lines = out_file.read_text(encoding="utf-8").splitlines()
        for param, value_line_no in entries:
            expected = lookup(data, param)
            if expected is None:
                continue  # unset; already judged by check_unresolved
            if value_line_no >= len(lines):
                failures.add("MISSING_OUTPUT", f"{rel}: line {value_line_no + 1} vanished")
                continue
            actual = lines[value_line_no]
            if actual.lstrip().startswith("#"):
                continue  # section-disabled; nothing to substitute
            rendered = format_expected(expected)
            if isinstance(expected, (list, dict)):
                # Injecto writes json.dumps() output, then terraform fmt rewrites it
                # into canonical HCL spacing ({"a": "b"} -> { "a" : "b" }). Compare
                # with spacing around structural punctuation collapsed. Scalars stay
                # byte-exact so a wrong string value is still caught.
                found = hcl_spacing(rendered) in hcl_spacing(actual)
            else:
                found = rendered in actual
            if not found:
                failures.add(
                    "NOT_SUBSTITUTED",
                    f"{rel}:{value_line_no + 1} {param} -> expected {rendered}, line reads: {actual.strip()}",
                )


def check_inert_baseline(inert, failures):
    """Fail on NEW inert decorators; the known ones are baselined."""
    if not INERT_BASELINE.exists():
        failures.add("NO_BASELINE", f"{INERT_BASELINE.relative_to(REPO_ROOT)} is missing - run with --write-baseline")
        return
    known = {
        line.strip()
        for line in INERT_BASELINE.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.startswith("#")
    }
    for entry in inert:
        if entry not in known:
            failures.add("NEW_INERT_PARAM", f"{entry} (this decorator parameterizes nothing)")
    for entry in sorted(known - set(inert)):
        failures.add("STALE_BASELINE", f"{entry} is baselined but no longer present - remove it from the baseline")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--injecto", required=True, help="Path to a checkout of the Injecto repository")
    parser.add_argument("--fixture", required=True, type=Path, help="Fixture JSON in prepareInjectoData shape")
    parser.add_argument("--out-dir", type=Path, help="Keep the generated tree here instead of a temp dir")
    parser.add_argument("--write-baseline", action="store_true", help="Rewrite the inert-param baseline and exit")
    args = parser.parse_args()

    staging = Path(tempfile.mkdtemp(prefix="injecto-gate-src-"))
    try:
        tracked = materialize_clean_templates(staging)
        return run_gate(args, staging, tracked)
    finally:
        shutil.rmtree(staging, ignore_errors=True)


def run_gate(args, templates_dir, tracked):
    substitutable, inert, sections = scan_decorators(templates_dir)
    param_paths = {p for p, _, _ in substitutable}

    if args.write_baseline:
        INERT_BASELINE.write_text(
            "# @param decorators that sit above a line Injecto cannot rewrite.\n"
            "# They parameterize nothing. Baselined so the gate fails only on NEW ones.\n"
            "# Regenerate with: python tests/gate.py --write-baseline --injecto <path> --fixture <path>\n"
            + "\n".join(inert)
            + "\n",
            encoding="utf-8",
        )
        print(f"wrote {len(inert)} inert decorators to {INERT_BASELINE.relative_to(REPO_ROOT)}")
        return 0

    try:
        data = json.loads(args.fixture.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"gate: cannot read fixture {args.fixture}: {exc}", file=sys.stderr)
        return 2

    tmp = None
    if args.out_dir:
        out_dir = args.out_dir
        if out_dir.exists():
            shutil.rmtree(out_dir)
        out_dir.mkdir(parents=True)
    else:
        tmp = tempfile.mkdtemp(prefix="injecto-gate-")
        out_dir = Path(tmp)

    try:
        code, log = run_injecto(args.injecto, templates_dir, args.fixture, out_dir)
        if code != 0:
            print(log, file=sys.stderr)
            print(f"gate: Injecto exited {code}", file=sys.stderr)
            return 2

        failures = Failure()
        check_dropped_files(log, failures)
        section_only = check_unresolved(log, data, param_paths, sections, failures)
        check_substituted(substitutable, data, out_dir, failures)
        check_inert_baseline(inert, failures)

        inputs = sum(1 for p in templates_dir.rglob("*") if p.is_file())
        outputs = sum(1 for p in out_dir.rglob("*") if p.is_file())
        if inputs != outputs:
            failures.add("FILE_COUNT_MISMATCH", f"{inputs} files in, {outputs} files out")

        print(f"fixture       : {args.fixture.name}")
        print(f"tracked files : {tracked} listed / {inputs} staged / {outputs} generated")
        print(f"@param sites  : {len(substitutable)} substitutable, {len(inert)} inert")
        print(f"sections off  : {len(section_only)} unset @section condition(s)")

        if failures:
            print(f"\nFAIL - {len(failures)} problem(s):\n")
            for code_, detail in failures:
                print(f"  [{code_}] {detail}")
            return 1

        print("\nPASS")
        return 0
    finally:
        if tmp:
            shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
