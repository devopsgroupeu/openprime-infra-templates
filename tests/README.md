# Generation gate

Injecto reports its two most damaging failures as warnings and still exits `0`:
a missing `@param` leaves the **template default** in the customer's generated
repository, and a file that throws during processing is simply **absent** from
the output. Both look like success to the caller. This gate turns them into a
red build.

## Running it locally

```bash
pip install -r <path-to-Injecto>/requirements.txt

python tests/gate.py \
  --injecto <path-to-Injecto> \
  --fixture tests/fixtures/standard.json \
  --out-dir generated          # optional; keeps the generated tree
```

Exit `0` pass, `1` gate failure, `2` harness error.

The gate always runs against a clean `git ls-files` export of `templates/`, not
your working tree — otherwise `.terraform/` provider caches and vendored module
checkouts flood it with phantom failures.

## What it checks

| Code | Meaning |
|---|---|
| `DROPPED_FILE` | a file threw during processing and is missing from the output |
| `UNRESOLVED_PARAM` | an `@param` of an **enabled** service is unset, so the template default ships |
| `NOT_SUBSTITUTED` | the param resolved but the output still does not carry the value |
| `NEW_INERT_PARAM` | a decorator sits above a line Injecto can never rewrite — it parameterizes nothing |
| `STALE_BASELINE` | a baselined entry no longer exists; remove it |
| `UNKNOWN_PATH` | a path was looked up that is neither an `@param` nor an `@section` |
| `MISSING_OUTPUT` / `FILE_COUNT_MISMATCH` | the output tree does not match the input |

`@section` conditions are deliberately **not** failures when unset: an unresolved
section switches its block off, which is a safe default. An unresolved `@param`
is the opposite — it silently keeps the vendor's value.

## Fixtures

`tests/fixtures/*.json` are in the shape the backend actually sends
(`prepareInjectoData`, `openprime-app-backend/src/services/environmentService.js`).

**Fixture values must differ from the template defaults.** If a fixture repeats
the default, a broken substitution is invisible — the output looks right for the
wrong reason.

## Baselines

Two files record known debt so the gate fails on *new* problems instead of
staying permanently red. Both should only ever shrink.

- `inert-params.txt` — decorators that cannot substitute anything (mostly
  `@param` above a `variable "x" {` block opener in `_variables.tf`).
  Regenerate with `--write-baseline`.
- `known-unresolved.txt` — `@param` paths no producer supplies. Each entry is a
  bug with its reason recorded inline.
