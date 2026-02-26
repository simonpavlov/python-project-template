# AGENTS.md

## Project Overview

Python 3.14 project. Uses `uv` for dependency management.

Source code: `src/my_package/`
Tests: `tests/`
Config: `pyproject.toml`

## Commands

### IMPORTANT: Run `make test` after every change.

`make test` runs the full pipeline: lint -> type-check -> complexity -> tests with coverage.

| Command | Description |
|---|---|
| `make test` | **Full check** -- lint + mypy + complexipy + pytest (run after every change) |
| `make test-run` | Tests only with coverage (90% minimum) |
| `make lint` | Ruff check + format check |
| `make format` | Auto-fix lint and formatting |
| `make type-check` | Mypy strict type checking |
| `make complexity` | Complexipy analysis (max complexity 10) |
| `make install` | `uv sync` |
| `make dev-install` | `uv sync --extra dev` |

### Running a Single Test

```bash
# Single test file
uv run pytest tests/test_basic.py

# Single test class
uv run pytest tests/test_basic.py::TestPackageImport

# Single test method
uv run pytest tests/test_basic.py::TestPackageImport::test_import_package

# With verbose output
uv run pytest tests/test_basic.py::TestPackageImport::test_import_package -v
```

Note: `pyproject.toml` has `addopts` that adds `--cov` flags by default. To skip coverage
during single-test runs, use `--no-cov`:

```bash
uv run pytest tests/test_basic.py::TestPackageImport -v --no-cov
```

## Code Style

See `code_style.md` for general Python style principles.

### Formatting & Linting

- **Ruff** handles both linting and formatting (line length: 88)
- Target: Python 3.14 (`py314`)
- Enabled rule sets: pycodestyle, pyflakes, isort, flake8-bugbear, flake8-comprehensions,
  pyupgrade, flake8-simplify, flake8-type-checking, flake8-use-pathlib, eradicate, pylint,
  tryceratops, ruff-specific rules
- Run `make format` to auto-fix before committing

### Type Annotations

- **Mypy strict mode** is enforced on `src/` -- every function must have full type annotations
- Use modern built-in generics: `dict[str, int]`, `list[str]`, `tuple[str, ...]`
  (not `typing.Dict`, `typing.List`, etc.)
- Use `str | None` instead of `Optional[str]`
- Tests are exempt from `disallow_untyped_defs`

### Imports

Ordered by ruff/isort (enforced by `I` rule set):

```python
# 1. Standard library
import logging
import re
from dataclasses import dataclass
from pathlib import Path

# 2. Third-party
import pytest

# 3. Local
from my_package.module import SomeClass
```

- Unused imports are errors (`F401`), except in `__init__.py`
- Use `from __future__ import annotations` is NOT used -- project targets 3.14

### Naming Conventions

- Module-level constants: `UPPER_SNAKE_CASE`
- Functions/methods: `snake_case`; private helpers prefixed with `_`
- Classes: `PascalCase`
- Test classes: `TestPascalCase` grouping related tests
- Test methods: `test_descriptive_name`
- Magic numbers in tests: extract to module-level constants

### Documentation

- Every module starts with a docstring describing its purpose
- Every public function/class has a Google-style docstring with Args/Returns sections:

```python
def process(data: str, *, verbose: bool = False) -> dict[str, int]:
    """Process the input data and return results.

    Args:
        data: Input data to process.
        verbose: Enable verbose output.

    Returns:
        Mapping of keys to computed values.
    """
```

- Private helper functions have a single-line docstring

### Test Structure

- One test file per source module (`test_module.py` <-> `module.py`)
- Group tests in classes by function under test (`TestFunctionName`)
- Each test method has a docstring explaining what it tests
- Shared fixtures live in `tests/conftest.py`
- Test data fixtures in `tests/fixtures/`
- Coverage minimum: 90%
