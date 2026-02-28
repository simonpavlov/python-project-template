#!/usr/bin/env bash
# Initialize a new Python project from this template.
#
# Usage:
#   ./init_project.sh <package_name>
#
# Example:
#   git clone git@github.com:simonpavlov/python-project-template.git my-cool-project
#   cd my-cool-project
#   ./init_project.sh my_cool_project

set -euo pipefail

# -- Colors ----------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()  { echo -e "${BOLD}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
error() { echo -e "${RED}[error]${NC} $*" >&2; }
die()   { error "$@"; exit 1; }

# -- Validation ------------------------------------------------------------

[[ $# -eq 1 ]] || die "Usage: $0 <package_name>  (e.g. $0 my_cool_project)"

PACKAGE_NAME="$1"

# Must be a valid Python identifier: lowercase letters, digits, underscores.
# Must start with a letter. No hyphens, no uppercase.
if [[ ! "$PACKAGE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    die "Invalid package name: '${PACKAGE_NAME}'
    Must be a valid Python identifier: lowercase letters, digits, underscores.
    Must start with a lowercase letter.
    Examples: my_project, cool_lib, data_pipeline_v2"
fi

if [[ "$PACKAGE_NAME" == "my_package" ]]; then
    die "Package name 'my_package' is the template default. Nothing to do."
fi

# Must be run from the template root (src/my_package/ must exist)
if [[ ! -d "src/my_package" ]]; then
    die "Directory 'src/my_package' not found.
    Are you running this from the template root directory?"
fi

# -- Derive name variants --------------------------------------------------

SNAKE_NAME="$PACKAGE_NAME"                                          # my_cool_project
HYPHEN_NAME="${SNAKE_NAME//_/-}"                                    # my-cool-project
TITLE_NAME="$(echo "$SNAKE_NAME" | sed 's/_/ /g; s/\b\w/\u&/g')"  # My Cool Project

info "Initializing new project:"
info "  Python package : ${BOLD}${SNAKE_NAME}${NC}"
info "  PyPI name      : ${BOLD}${HYPHEN_NAME}${NC}"
info "  Display name   : ${BOLD}${TITLE_NAME}${NC}"
echo ""

# -- Rename source directory -----------------------------------------------

info "Renaming src/my_package/ -> src/${SNAKE_NAME}/"
mv "src/my_package" "src/${SNAKE_NAME}"
ok "Directory renamed"

# -- Find and replace in files ---------------------------------------------

# Files that contain template names to replace.
# Order matters: replace the more specific patterns first.
TARGET_FILES=(
    "pyproject.toml"
    "src/${SNAKE_NAME}/__init__.py"
    "tests/test_basic.py"
    "AGENTS.md"
    "README.md"
)

info "Replacing template names in project files..."

for file in "${TARGET_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        # Title case: "My Package" -> "My Cool Project" (in docstrings)
        sed -i "s/My Package/${TITLE_NAME}/g" "$file"
        # Hyphenated: "my-package" -> "my-cool-project" (in pyproject.toml)
        sed -i "s/my-package/${HYPHEN_NAME}/g" "$file"
        # Underscore: "my_package" -> "my_cool_project" (imports, paths)
        sed -i "s/my_package/${SNAKE_NAME}/g" "$file"
    else
        warn "File not found, skipping: ${file}"
    fi
done

ok "All replacements done"

# -- Reset git -------------------------------------------------------------

info "Resetting git history..."
rm -rf .git
git init --quiet
ok "Git initialized"

# -- Self-delete ------------------------------------------------------------

info "Removing initialization scripts..."
SELF="$(basename "$0")"
rm -f "$SELF"
rm -f "test_init_project.sh"
ok "Scripts removed"

# -- Initial commit ---------------------------------------------------------

info "Creating initial commit..."
git add -A
git commit --quiet -m "Initial commit from python-project-template"
ok "Initial commit created"

# -- Install dependencies ---------------------------------------------------

info "Installing dependencies (uv sync --extra dev)..."
uv sync --extra dev --quiet
ok "Dependencies installed"

# -- Verify -----------------------------------------------------------------

info "Running full test suite (make test)..."
echo ""
if make test; then
    echo ""
    ok "All checks passed!"
else
    echo ""
    die "make test failed. Check the output above for errors."
fi

# -- Done -------------------------------------------------------------------

echo ""
echo -e "${GREEN}${BOLD}Project '${SNAKE_NAME}' is ready!${NC}"
echo ""
echo "  Next steps:"
echo "    1. Update description and authors in pyproject.toml"
echo "    2. Add a git remote:  git remote add origin <url>"
echo "    3. Start coding in src/${SNAKE_NAME}/"
echo ""
