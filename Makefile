.PHONY: test clean install dev-install lint format type-check complexity test-run build dev-check

# Install production dependencies
install:
	uv sync

# Install development dependencies
dev-install:
	uv sync --extra dev

# Run all tests, linting, type checking, and complexity analysis
test: lint type-check complexity test-run

# Run only tests with coverage
test-run:
	uv run pytest tests/ --cov=src --cov-report=html --cov-report=term-missing --cov-fail-under=90

# Run linting and format check
lint:
	uv run ruff check src/ tests/
	uv run ruff format --check src/ tests/

# Auto-fix formatting
format:
	uv run ruff check --fix src/ tests/
	uv run ruff format src/ tests/

# Run type checking
type-check:
	uv run mypy src/

# Run complexity analysis
complexity:
	uv run complexipy src/

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf .pytest_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Build package
build:
	uv build

# Quick development check
dev-check: lint test-run
	@echo "Development check complete!"
