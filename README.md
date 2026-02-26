# Python Project Template

Python 3.14 project template with uv, ruff, mypy (strict), pytest, and complexipy.

## Setup

```bash
make dev-install
```

## Usage

```bash
make test          # full pipeline: lint + type-check + complexity + tests
make format        # auto-fix lint and formatting
make build         # build package
```

## Rename Package

```bash
mv src/my_package src/your_package
```

Then find-and-replace `my_package` -> `your_package` and `my-package` -> `your-package`
in `pyproject.toml`, `AGENTS.md`, and `tests/`.
