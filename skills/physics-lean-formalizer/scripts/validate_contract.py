#!/usr/bin/env python3
"""Validate v1 JSON contracts; requires Python jsonschema>=4 (host provisioning)."""
import argparse
import json
from pathlib import Path
import sys


def validate(kind, value):
    try:
        from jsonschema import Draft202012Validator
    except ImportError as exc:
        raise ValueError('Install jsonschema>=4 in the host environment to validate contracts') from exc
    name = 'input' if kind == 'input' else 'run-report'
    schema = json.loads((Path(__file__).resolve().parents[1] / 'schemas' / f'{name}.schema.json').read_text())
    Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(value), key=lambda e: str(list(e.path)))
    if errors:
        raise ValueError('\n'.join(f'{list(e.path)}: {e.message}' for e in errors))
    if kind == 'report':
        checks = [value['units_checked'], value['build_status'], *value['verification_status'].values()]
        for check in checks:
            if check['status'] in ('skipped', 'not_applicable', 'not_run') and not check['reason']:
                raise ValueError('Skipped/not-applicable/not-run checks need a reason')
            if check['status'] == 'passed' and not check['evidence']:
                raise ValueError('Passed checks need evidence')
        if value['status'] == 'success' and not value['artifacts']:
            raise ValueError('Success needs hashed artifacts')
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kind', choices=['input', 'report'])
    parser.add_argument('file', type=Path)
    args = parser.parse_args()
    try:
        validate(args.kind, json.loads(args.file.read_text()))
    except (ValueError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    print('VALID')
    return 0


if __name__ == '__main__':
    sys.exit(main())
