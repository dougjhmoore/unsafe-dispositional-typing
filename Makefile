# Dispositional Typing Project – Makefile
# Python-only workflow (no Docker).  Tabs are required after each rule.

.PHONY: all setup analysis evaluation test clean dev-setup help

# ───────── Default target ─────────
all: setup analysis

# ---------- Environment ----------
setup:
	python3 -m venv venv
	. venv/bin/activate && pip install -r scripts/requirements.txt
	@echo "✅ Environment setup complete"

# ---------- Scalability analysis (Figure 1) ----------
# 1. Generate PNG via the Python script
data/scalability/scalability_figure.png: setup
	@echo "🔬 Running scalability analysis..."
	cd scripts/analysis/scalability && \
	python3 scalability_analysis.py --output-dir ../../../data/scalability/

# 2. Convert the PNG to a compact JPEG for the manuscript
data/scalability/scalability_figure.jpg: data/scalability/scalability_figure.png
	@echo "🖼️  Converting PNG → JPEG (quality 80)…"
	convert $< -quality 80 $@

# 3. High-level alias: produces both data files and the JPEG
analysis: data/scalability/scalability_figure.jpg
	@echo "✅ Scalability analysis complete. Check data/scalability/"

# ---------- LLVM evaluation (optional, Table 1) ----------
evaluation: setup
	@echo "🏗️  Building LLVM plugin..."
	cd tools/clang-plugin && mkdir -p build && cd build && cmake .. && make
	@echo "🔬 Running LLVM test-suite evaluation..."
	cd scripts/evaluation && ./driver.sh
	@echo "✅ Evaluation complete. Check evaluation/llvm-test-suite/"

# ---------- Tests ----------
test:
	@echo "🧪 Running tests..."
	# Future: cd tests && python -m pytest

# ---------- House-keeping ----------
clean:
	rm -rf data/scalability/*.{png,jpg}
	rm -rf evaluation/*/build/
	rm -rf tools/*/build/
	rm -rf venv/
	@echo "✅ Cleaned generated files"

dev-setup: setup
	. venv/bin/activate && pip install pytest black flake8
	@echo "✅ Development environment ready"

help:
	@echo "Dispositional Typing Project – Available targets:"
	@echo ""
	@echo "  setup       Create Python venv and install dependencies"
	@echo "  analysis    Reproduce Figure 1 (PNG → JPEG)"
	@echo "  evaluation  Build plugin and run LLVM evaluation (Table 1)"
	@echo "  test        Run test suite"
	@echo "  clean       Remove generated files and venv"
	@echo "  dev-setup   Add developer tooling to the venv"
	@echo ""
@echo "Quick start: make setup && make analysis"
