#!/usr/bin/env bash
# Automated tests for init_project.sh.
#
# Copies the template to a temp directory for each test case, runs the init
# script (or validates it rejects bad input), and asserts the expected outcomes.
#
# Usage:
#   ./test_init_project.sh
#
# Each test is isolated -- it creates and destroys its own temp directory.
# The real template directory is never modified.

set -euo pipefail

# -- Colors & helpers -------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"

pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    echo -e "  ${GREEN}PASS${NC}  $1"
}

fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo -e "  ${RED}FAIL${NC}  $1: $2"
}

# Copy template to a fresh temp directory, excluding .git, .venv, caches
setup_tmpdir() {
    local tmpdir
    tmpdir=$(mktemp -d "/tmp/test_init_XXXXXX")

    rsync -a \
        --exclude='.git' \
        --exclude='.venv' \
        --exclude='.mypy_cache' \
        --exclude='.ruff_cache' \
        --exclude='.pytest_cache' \
        --exclude='.complexipy_cache' \
        --exclude='htmlcov' \
        --exclude='__pycache__' \
        --exclude='uv.lock' \
        "${TEMPLATE_DIR}/" "${tmpdir}/"

    # Initialize a git repo so the script can reset it
    git -C "$tmpdir" init --quiet
    git -C "$tmpdir" add -A
    git -C "$tmpdir" commit --quiet -m "template"

    echo "$tmpdir"
}

cleanup() {
    [[ -n "${1:-}" && -d "${1:-}" ]] && rm -rf "$1"
}

# -- Test cases -------------------------------------------------------------

test_happy_path() {
    local name="test_happy_path"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    # Run init script
    if ! (cd "$tmpdir" && ./init_project.sh cool_project); then
        fail "$name" "init_project.sh exited with non-zero"
        cleanup "$tmpdir"
        return
    fi

    # Assert: source directory renamed
    if [[ ! -d "$tmpdir/src/cool_project" ]]; then
        fail "$name" "src/cool_project/ does not exist"
        cleanup "$tmpdir"
        return
    fi
    if [[ -d "$tmpdir/src/my_package" ]]; then
        fail "$name" "src/my_package/ still exists"
        cleanup "$tmpdir"
        return
    fi

    # Assert: no leftover old names in key files
    local check_files=("pyproject.toml" "src/cool_project/__init__.py" "tests/test_basic.py")
    for f in "${check_files[@]}"; do
        if grep -q "my_package" "$tmpdir/$f" 2>/dev/null; then
            fail "$name" "'my_package' still found in $f"
            cleanup "$tmpdir"
            return
        fi
        if grep -q "my-package" "$tmpdir/$f" 2>/dev/null; then
            fail "$name" "'my-package' still found in $f"
            cleanup "$tmpdir"
            return
        fi
    done

    # Assert: new names present
    if ! grep -q 'name = "cool-project"' "$tmpdir/pyproject.toml"; then
        fail "$name" "'cool-project' not in pyproject.toml"
        cleanup "$tmpdir"
        return
    fi
    if ! grep -q 'import cool_project' "$tmpdir/tests/test_basic.py"; then
        fail "$name" "'cool_project' not in test_basic.py"
        cleanup "$tmpdir"
        return
    fi
    if ! grep -q '"""Cool Project."""' "$tmpdir/src/cool_project/__init__.py"; then
        fail "$name" "title case docstring not in __init__.py"
        cleanup "$tmpdir"
        return
    fi

    # Assert: scripts self-deleted
    if [[ -f "$tmpdir/init_project.sh" ]]; then
        fail "$name" "init_project.sh was not self-deleted"
        cleanup "$tmpdir"
        return
    fi
    if [[ -f "$tmpdir/test_init_project.sh" ]]; then
        fail "$name" "test_init_project.sh was not self-deleted"
        cleanup "$tmpdir"
        return
    fi

    # Assert: git has exactly 1 commit and working tree is clean
    local commit_count
    commit_count=$(git -C "$tmpdir" rev-list --count HEAD)
    if [[ "$commit_count" -ne 1 ]]; then
        fail "$name" "expected 1 git commit, got $commit_count"
        cleanup "$tmpdir"
        return
    fi
    local git_status
    git_status=$(git -C "$tmpdir" status --porcelain)
    if [[ -n "$git_status" ]]; then
        fail "$name" "git working tree is not clean: $git_status"
        cleanup "$tmpdir"
        return
    fi

    # Assert: scripts not tracked in git
    if git -C "$tmpdir" show HEAD -- init_project.sh | grep -q "init_project"; then
        fail "$name" "init_project.sh is tracked in git commit"
        cleanup "$tmpdir"
        return
    fi

    # Assert: make test passes (the real proof)
    if ! (cd "$tmpdir" && make test > /dev/null 2>&1); then
        fail "$name" "make test failed in initialized project"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_underscore_name_with_numbers() {
    local name="test_underscore_name_with_numbers"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if ! (cd "$tmpdir" && ./init_project.sh data_pipeline_v2 > /dev/null 2>&1); then
        fail "$name" "init_project.sh failed for valid name 'data_pipeline_v2'"
        cleanup "$tmpdir"
        return
    fi

    if [[ ! -d "$tmpdir/src/data_pipeline_v2" ]]; then
        fail "$name" "src/data_pipeline_v2/ does not exist"
        cleanup "$tmpdir"
        return
    fi

    if ! grep -q 'name = "data-pipeline-v2"' "$tmpdir/pyproject.toml"; then
        fail "$name" "hyphenated name not in pyproject.toml"
        cleanup "$tmpdir"
        return
    fi

    if ! (cd "$tmpdir" && make test > /dev/null 2>&1); then
        fail "$name" "make test failed"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_single_word_name() {
    local name="test_single_word_name"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if ! (cd "$tmpdir" && ./init_project.sh mylib > /dev/null 2>&1); then
        fail "$name" "init_project.sh failed for 'mylib'"
        cleanup "$tmpdir"
        return
    fi

    if [[ ! -d "$tmpdir/src/mylib" ]]; then
        fail "$name" "src/mylib/ does not exist"
        cleanup "$tmpdir"
        return
    fi

    if ! grep -q 'name = "mylib"' "$tmpdir/pyproject.toml"; then
        fail "$name" "'mylib' not in pyproject.toml"
        cleanup "$tmpdir"
        return
    fi

    if ! grep -q '"""Mylib."""' "$tmpdir/src/mylib/__init__.py"; then
        fail "$name" "title case docstring not correct in __init__.py"
        cleanup "$tmpdir"
        return
    fi

    if ! (cd "$tmpdir" && make test > /dev/null 2>&1); then
        fail "$name" "make test failed"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_rejects_uppercase() {
    local name="test_rejects_uppercase"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if (cd "$tmpdir" && ./init_project.sh MyProject > /dev/null 2>&1); then
        fail "$name" "should have rejected 'MyProject'"
        cleanup "$tmpdir"
        return
    fi

    # Source directory should be untouched
    if [[ ! -d "$tmpdir/src/my_package" ]]; then
        fail "$name" "src/my_package/ was modified despite rejection"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_rejects_hyphens() {
    local name="test_rejects_hyphens"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if (cd "$tmpdir" && ./init_project.sh my-project > /dev/null 2>&1); then
        fail "$name" "should have rejected 'my-project'"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_rejects_leading_digit() {
    local name="test_rejects_leading_digit"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if (cd "$tmpdir" && ./init_project.sh 1project > /dev/null 2>&1); then
        fail "$name" "should have rejected '1project'"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_rejects_empty_name() {
    local name="test_rejects_empty_name"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if (cd "$tmpdir" && ./init_project.sh "" > /dev/null 2>&1); then
        fail "$name" "should have rejected empty string"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_rejects_no_args() {
    local name="test_rejects_no_args"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if (cd "$tmpdir" && ./init_project.sh > /dev/null 2>&1); then
        fail "$name" "should have rejected missing argument"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_rejects_my_package() {
    local name="test_rejects_my_package"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if (cd "$tmpdir" && ./init_project.sh my_package > /dev/null 2>&1); then
        fail "$name" "should have rejected 'my_package' (template default)"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

test_agents_md_updated() {
    local name="test_agents_md_updated"
    local tmpdir
    tmpdir=$(setup_tmpdir)

    if ! (cd "$tmpdir" && ./init_project.sh web_server > /dev/null 2>&1); then
        fail "$name" "init_project.sh failed"
        cleanup "$tmpdir"
        return
    fi

    if grep -q "my_package" "$tmpdir/AGENTS.md"; then
        fail "$name" "'my_package' still found in AGENTS.md"
        cleanup "$tmpdir"
        return
    fi

    if ! grep -q "src/web_server/" "$tmpdir/AGENTS.md"; then
        fail "$name" "'src/web_server/' not found in AGENTS.md"
        cleanup "$tmpdir"
        return
    fi

    if ! grep -q "from web_server.module import SomeClass" "$tmpdir/AGENTS.md"; then
        fail "$name" "import example not updated in AGENTS.md"
        cleanup "$tmpdir"
        return
    fi

    pass "$name"
    cleanup "$tmpdir"
}

# -- Run all tests ----------------------------------------------------------

echo ""
echo -e "${BOLD}Running init_project.sh tests...${NC}"
echo ""

test_rejects_no_args
test_rejects_empty_name
test_rejects_uppercase
test_rejects_hyphens
test_rejects_leading_digit
test_rejects_my_package
test_single_word_name
test_underscore_name_with_numbers
test_agents_md_updated
test_happy_path

# -- Summary ----------------------------------------------------------------

echo ""
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo -e "${BOLD}Results: ${PASS_COUNT}/${TOTAL} passed${NC}"

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}${FAIL_COUNT} test(s) failed${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
