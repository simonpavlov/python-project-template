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

## Create a New Project

```bash
git clone git@github.com:simonpavlov/python-project-template.git my-cool-project
cd my-cool-project
./init_project.sh my_cool_project
```

The script will:

- Rename `src/my_package/` to `src/my_cool_project/`
- Replace all template names across project files
- Reset git history with a clean initial commit
- Install dependencies and run the full test suite
- Self-delete after successful initialization
