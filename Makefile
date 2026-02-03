.PHONY: help install test lint format type-check security pre-commit clean coverage ci-local

help:  ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install:  ## Install dependencies and pre-commit hooks
	python -m pip install -U pip uv pre-commit
	uv sync
	pre-commit install
	@echo "✅ Setup complete!"

test:  ## Run tests
	uv run pytest tests/ -v

test-cov:  ## Run tests with coverage
	uv run pytest tests/ --cov=src --cov-report=term-missing --cov-report=html
	@echo "📊 Coverage report: htmlcov/index.html"

test-fast:  ## Run tests excluding slow ones
	uv run pytest tests/ -m "not slow" -v

test-watch:  ## Run tests in watch mode
	uv run pytest-watch tests/ --clear

lint:  ## Run linter (ruff)
	uv run ruff check .

lint-fix:  ## Run linter with auto-fix
	uv run ruff check --fix .

format:  ## Format code with ruff
	uv run ruff format .

format-check:  ## Check if code is formatted
	uv run ruff format --check .

type-check:  ## Run type checker (mypy)
	uv run mypy --show-error-codes --show-column-numbers src

security:  ## Run security checks
	@echo "🔒 Running Bandit..."
	-bandit -r src/ -f json -o bandit-report.json
	@echo "🔍 Running pip-audit..."
	-pip-audit
	@echo "✅ Running Safety..."
	-safety check

pre-commit:  ## Run pre-commit on all files
	pre-commit run --all-files

pre-commit-update:  ## Update pre-commit hooks
	pre-commit autoupdate

clean:  ## Clean build artifacts and cache
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete
	find . -type f -name '*.pyo' -delete
	@echo "🧹 Cleaned build artifacts"

coverage:  ## Generate and open coverage report
	uv run pytest tests/ --cov=src --cov-report=html
	@command -v open > /dev/null && open htmlcov/index.html || echo "Open htmlcov/index.html manually"

ci-local:  ## Run full CI pipeline locally
	@echo "🚀 Running full CI pipeline locally..."
	@echo ""
	@echo "1️⃣  Pre-commit checks..."
	pre-commit run --all-files
	@echo ""
	@echo "2️⃣  Type checking..."
	uv run mypy src
	@echo ""
	@echo "3️⃣  Running tests..."
	uv run pytest tests/ --cov=src --cov-report=term
	@echo ""
	@echo "4️⃣  Security scan..."
	-bandit -r src/
	@echo ""
	@echo "✅ Local CI pipeline complete!"

build:  ## Build package
	python -m pip install build
	python -m build
	twine check dist/*
	@echo "📦 Package built successfully"

deps-update:  ## Update all dependencies
	uv lock --upgrade
	pre-commit autoupdate
	@echo "🔄 Dependencies updated"

dev:  ## Start development environment
	@echo "🔧 Development environment ready!"
	@echo ""
	@echo "Useful commands:"
	@echo "  make test       - Run tests"
	@echo "  make lint       - Run linter"
	@echo "  make format     - Format code"
	@echo "  make ci-local   - Run full CI locally"