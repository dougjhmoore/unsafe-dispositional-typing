# Dispositional Typing Project Makefile
# IEEE TSE 2025 Paper Implementation

.PHONY: all setup clean test analysis evaluation help

# Default target
all: setup analysis

# Setup Python environment and dependencies
setup:
	python -m venv venv
	. venv/bin/activate && pip install -r scripts/requirements.txt
	@echo "✅ Environment setup complete"

# Run scalability analysis (reproduces Figure 1)
analysis:
	@echo "🔬 Running scalability analysis..."
	cd scripts/analysis/scalability && \
	python scalability_analysis.py --output-dir ../../../data/scalability/
	@echo "✅ Scalability analysis complete. Check data/scalability/"

# Build LLVM plugin and run evaluation
evaluation: setup
	@echo "🏗️  Building LLVM plugin..."
	cd tools/clang-plugin && mkdir -p build && cd build && cmake .. && make
	@echo "🔬 Running LLVM test suite evaluation..."
	cd scripts/evaluation && ./driver.sh
	@echo "✅ Evaluation complete. Check evaluation/llvm-test-suite/"

# Run test suite
test:
	@echo "🧪 Running tests..."
	# Future: cd tests && python -m pytest

# Clean generated files
clean:
	rm -rf data/scalability/*
	rm -rf evaluation/*/build/
	rm -rf tools/*/build/
	rm -rf venv/
	@echo "✅ Cleaned generated files"

# Development targets
dev-setup: setup
	. venv/bin/activate && pip install pytest black flake8
	@echo "✅ Development environment ready"

# Show help
help:
	@echo "Dispositional Typing Project - Available targets:"
	@echo ""
	@echo "  setup       Setup Python environment and dependencies"
	@echo "  analysis    Run scalability analysis (Figure 1 reproduction)"
	@echo "  evaluation  Build plugin and run LLVM evaluation (Table 1)"
	@echo "  test        Run test suite"
	@echo "  clean       Clean all generated files"
	@echo "  dev-setup   Setup development environment"
	@echo "  help        Show this help message"
	@echo ""
	@echo "Quick start: make setup && make analysis"
