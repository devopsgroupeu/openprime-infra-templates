#!/usr/bin/env python3
"""Rewrite a fixture's service keys from the frontend service config.

A fixture authored from the templates agrees with them by construction, so it
cannot show that the frontend sends something else. That is how
`services.rds.engineVersion` survived in the templates while the wizard sent
`services.rds.version`: the engine version a user picked never arrived, and the
gate was green throughout (OP-227).

Keys come from the frontend. Values do not: the gate fails a param that resolved
to the template's own default, so a fixture value has to stay distinguishable
from it. Existing values are carried over untouched -- several are pinned by
check_secure_defaults -- and only genuinely new keys are synthesised.

Usage:
    # in the openprime-app checkout
    ./node_modules/.bin/esbuild src/config/services/aws.js \
        --bundle --format=esm --platform=node --outfile=/tmp/aws.bundle.mjs
    node -e 'import("/tmp/aws.bundle.mjs").then(m =>
        process.stdout.write(JSON.stringify(m.awsServices)))' > /tmp/aws.json

    # here
    python tests/derive_fixture.py --aws-json /tmp/aws.json \
        --fixture tests/fixtures/standard.json

Manual until OP-208 hydrates the frontend from the runtime catalog, after which
the two cannot disagree and this script stops being load-bearing.
"""

import argparse
import json
from pathlib import Path

# Keys the frontend stores under a service without declaring them as fields in
# aws.js. `helmCharts` is written by environmentsConfig.js for every Kubernetes
# service, so it reaches Injecto even though it is not a wizard field.
EXTRA_KEYS = {"eks": {"helmCharts"}}


def synthesise(key, spec):
    """A value for a key the fixture does not have yet, distinguishable from the
    template default so the gate can tell substitution from a default."""
    default = spec.get("defaultValue")
    if isinstance(default, bool):
        return default          # a boolean cannot be CI-marked; the FE default is the honest choice
    if isinstance(default, (int, float)):
        return default
    if isinstance(default, list):
        return default
    return f"ci-{default}" if default else f"ci-{key}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--aws-json", type=Path, required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--check", action="store_true", help="Report drift and exit non-zero, write nothing")
    args = parser.parse_args()

    fe = json.loads(args.aws_json.read_text())
    fixture = json.loads(args.fixture.read_text())

    drift = []
    for service, config in fixture["services"].items():
        if not config.get("enabled"):
            continue
        fields = (fe.get(service) or {}).get("fields") or {}
        allowed = set(fields) | EXTRA_KEYS.get(service, set()) | {"enabled"}

        for key in sorted(set(config) - allowed):
            drift.append(f"{service}.{key}: in the fixture, not in the frontend")
            if not args.check:
                del config[key]

        for key in sorted(allowed - set(config) - {"enabled"}):
            drift.append(f"{service}.{key}: in the frontend, not in the fixture")
            if not args.check:
                config[key] = synthesise(key, fields[key])

    for line in drift:
        print(line)

    if args.check:
        print(f"\n{len(drift)} difference(s)")
        return 1 if drift else 0

    args.fixture.write_text(json.dumps(fixture, indent=2, sort_keys=False) + "\n")
    print(f"\nrewrote {args.fixture} ({len(drift)} change(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
