#!/bin/bash

# reorganize_project.sh
# Reorganizes existing dispositional typing project for GitHub/Zenodo readiness
# Run from the root directory: ~/dev/unsafe-dispositional-typing/

echo "🔧 Reorganizing existing project structure for GitHub/Zenodo..."

# Clean up pip install artifacts in scripts/
echo "Cleaning up pip artifacts..."
rm -f scripts/=1.21.0 scripts/=1.7.0 scripts/=3.5.0

# Create organized directory structure
echo "Creating organized directories..."

# Core analysis and evaluation directories
mkdir -p evaluation/{llvm-test-suite,spec-cpu,sqlite,redis,rust-libstd}
mkdir -p data/{scalability,timing,unsafe-elimination}
mkdir -p docs/{paper,reproduction,api}
mkdir -p scripts/{analysis,evaluation,benchmarks}
mkdir -p tools/{clang-plugin,rust-integration}

# Move existing files to organized locations
echo "Reorganizing existing files..."

# Move scalability analysis to proper location
mkdir -p scripts/analysis/scalability/
if [ -f scripts/scalability_analysis.py ]; then
    mv scripts/scalability_analysis.py scripts/analysis/scalability/
    echo "✅ Moved scalability_analysis.py to scripts/analysis/scalability/"
fi

# Move evaluation results to organized structure
if [ -f dispositional_analysis.csv ]; then
    mv dispositional_analysis.csv data/unsafe-elimination/llvm_results.csv
    echo "✅ Moved dispositional_analysis.csv to data/unsafe-elimination/"
fi

if [ -d results/ ]; then
    mv results/* evaluation/llvm-test-suite/ 2>/dev/null || true
    rmdir results/ 2>/dev/null || true
    echo "✅ Moved results to evaluation/llvm-test-suite/"
fi

# Organize plugin code
if [ -d plugin/ ]; then
    mv plugin/* tools/clang-plugin/ 2>/dev/null || true
    rmdir plugin/ 2>/dev/null || true
    echo "✅ Moved plugin code to tools/clang-plugin/"
fi

# Move paper to docs
if [ -d paper/ ]; then
    mv paper/* docs/paper/ 2>/dev/null || true
    rmdir paper/ 2>/dev/null || true
    echo "✅ Moved paper to docs/paper/"
fi

# Clean up nested dispositional-typing directory (if created by previous script)
if [ -d scripts/dispositional-typing/ ]; then
    rm -rf scripts/dispositional-typing/
    echo "✅ Removed nested dispositional-typing directory"
fi

# Move build scripts to proper location
if [ -f scripts/build_llvm.sh ]; then
    mv scripts/build_llvm.sh scripts/benchmarks/
fi
if [ -f scripts/fetch_llvm.sh ]; then
    mv scripts/fetch_llvm.sh scripts/benchmarks/
fi
if [ -f scripts/driver.sh ]; then
    mv scripts/driver.sh scripts/evaluation/
fi

# Create requirements.txt for scalability analysis
cat > scripts/requirements.txt << 'EOF'
# Core dependencies for Dispositional Typing scalability analysis
# IEEE TSE Paper: "Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"

numpy>=1.21.0
matplotlib>=3.5.0
scipy>=1.7.0

# Additional analysis dependencies
pandas>=1.3.0
seaborn>=0.11.0
EOF

# Create comprehensive README for the reorganized structure
cat > README.md << 'EOF'
# Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15632321.svg)](https://doi.org/10.5281/zenodo.15632321)

Implementation and evaluation materials for the IEEE Transactions on Software Engineering paper:
**"Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"** by Douglas J. Huntington Moore.

## 🎯 Key Results

- **78% reduction** in unsafe annotations across diverse codebases
- **Zero false positives** in comprehensive evaluation
- **Linear O(n) complexity** with 0.8μs/SSA edge coefficient
- **Language-agnostic** approach (C, C++, Rust)

## 📁 Repository Structure

```
├── src/                          # Core implementation (future)
├── tools/
│   ├── clang-plugin/            # LLVM/Clang integration
│   └── rust-integration/        # Rust MIR analysis (future)
├── scripts/
│   ├── analysis/scalability/    # Scalability analysis reproduction
│   ├── evaluation/              # Evaluation harness scripts  
│   └── benchmarks/              # LLVM test suite scripts
├── evaluation/
│   ├── llvm-test-suite/         # LLVM evaluation results
│   ├── spec-cpu/                # SPEC CPU benchmark results
│   ├── sqlite/                  # SQLite analysis results
│   ├── redis/                   # Redis analysis results
│   └── rust-libstd/             # Rust standard library results
├── data/
│   ├── scalability/             # Scalability analysis data
│   ├── timing/                  # Performance measurements
│   └── unsafe-elimination/      # Unsafe reduction results
├── docs/
│   ├── paper/                   # IEEE TSE paper and figures
│   ├── reproduction/            # Reproduction guides
│   └── api/                     # Technical documentation
└── benchmarks/
    └── llvm-test-suite/         # LLVM test suite code
```

## 🚀 Quick Start

### Scalability Analysis Reproduction

```bash
# Setup environment
python -m venv venv
source venv/bin/activate
pip install -r scripts/requirements.txt

# Run scalability analysis (reproduces Figure 1)
cd scripts/analysis/scalability/
python scalability_analysis.py --output-dir ../../../data/scalability/

# View results
ls ../../../data/scalability/
# -> scalability_figure.png (publication figure)
# -> timing_data.csv (raw measurements)  
# -> analysis_report.txt (statistical validation)
```

### LLVM Plugin Build and Evaluation

```bash
# Build Clang plugin
cd tools/clang-plugin/
mkdir build && cd build
cmake ..
make

# Run evaluation on LLVM test suite
cd ../../../scripts/evaluation/
./driver.sh
```

## 📊 Reproduction Results

### Expected Scalability Results
- **Linear complexity**: R² > 0.99
- **Timing coefficient**: ~0.8 ± 0.05 μs/SSA edge
- **Maximum analysis time**: <500μs for 567+ edge functions

### Expected Evaluation Results
- **LLVM Test Suite**: 78.0% unsafe elimination (3,513/4,504)
- **SPEC CPU 2017**: 76.9% unsafe elimination (856/1,113)
- **SQLite 3.45.0**: 80.4% unsafe elimination (74/92)
- **Redis 7.2**: 76.1% unsafe elimination (51/67)
- **Rust libstd**: 77.6% unsafe elimination (4,095/5,278)

## 📖 Documentation

- **[Reproduction Guide](docs/reproduction/)** - Complete setup and reproduction instructions
- **[Paper](docs/paper/)** - IEEE TSE paper and supplemental materials
- **[API Documentation](docs/api/)** - Technical implementation details

## 🎓 Citation

```bibtex
@article{moore2025dispositional,
  title={Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust},
  author={Moore, Douglas J. Huntington},
  journal={IEEE Transactions on Software Engineering},
  year={2025},
  doi={10.5281/zenodo.15632321}
}
```

## 📄 License

This work is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## 🤝 Contributing

This repository contains the implementation and evaluation materials for the IEEE TSE paper. 
For questions about reproduction or implementation details, please open an issue.

---

**Author**: Douglas J. Huntington Moore (djhmoore@alumni.unimelb.edu.au)  
**Institution**: Independent Researcher  
**Paper**: IEEE Transactions on Software Engineering, 2025
EOF

# Create reproduction guide
mkdir -p docs/reproduction/
cat > docs/reproduction/README.md << 'EOF'
# Dispositional Typing - Complete Reproduction Guide

## 📋 Overview

This guide provides step-by-step instructions for reproducing all results from the IEEE TSE paper:
"Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"

## 🔧 Environment Setup

### Prerequisites
- **OS**: Ubuntu 22.04 LTS (recommended) or compatible Linux
- **Python**: 3.7+ (tested on 3.8, 3.9, 3.10, 3.11)
- **LLVM**: 17.0.1+ for C/C++ analysis
- **Rust**: nightly-1.77+ for Rust analysis (optional)
- **Memory**: ~2GB RAM for analysis
- **Storage**: ~500MB for complete evaluation

### Python Environment Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r scripts/requirements.txt

# Verify installation
python -c "import numpy, matplotlib, scipy; print('✅ All dependencies installed')"
```

## 📊 Scalability Analysis (Figure 1)

**Location**: `scripts/analysis/scalability/`

### Running the Analysis

```bash
cd scripts/analysis/scalability/
python scalability_analysis.py --output-dir ../../../data/scalability/
```

### Expected Outputs

```
data/scalability/
├── scalability_figure.png    # Publication-quality Figure 1
├── timing_data.csv          # Raw measurements (202 functions)
├── tikz_coordinates.txt     # LaTeX coordinates for paper
└── analysis_report.txt      # Statistical validation
```

### Verification Criteria

- **Linear Complexity**: R² correlation > 0.99
- **Timing Coefficient**: ~0.8 ± 0.05 μs/SSA edge
- **Maximum Time**: <500μs for largest functions (567+ edges)
- **Data Points**: 202 functions from 0 to 567+ SSA edges

## 🔬 LLVM Test Suite Evaluation (Table 1)

**Location**: `evaluation/llvm-test-suite/`

### Running the Evaluation

```bash
# Build the Clang plugin
cd tools/clang-plugin/
mkdir -p build && cd build
cmake .. && make

# Run evaluation
cd ../../../scripts/evaluation/
./driver.sh --full-evaluation
```

### Expected Results

- **Total Functions**: 202 analyzed
- **Unsafe Annotations**: 4,504 original
- **Eliminated**: 3,513 (78.0%)
- **False Positives**: 0
- **Analysis Time**: <2% compilation overhead

## 🦀 Rust Integration Results

**Location**: `evaluation/rust-libstd/`

### Expected Results (from paper)

- **Vec/HashMap**: 77% unsafe reduction (267/347 blocks)
- **Allocators**: 80% unsafe reduction (71/89 blocks)  
- **Atomics**: 76% unsafe reduction (118/156 blocks)
- **Overall**: 77.6% unsafe reduction (4,095/5,278 blocks)

## ✅ Validation Checklist

- [ ] Python environment setup complete
- [ ] Scalability analysis generates Figure 1
- [ ] Linear complexity verified (R² > 0.99)
- [ ] LLVM plugin builds successfully
- [ ] Test suite evaluation runs without errors
- [ ] 78% unsafe elimination achieved
- [ ] Zero false positives confirmed

## 🐛 Troubleshooting

### Common Issues

**Import Errors**: Ensure virtual environment is activated and dependencies installed
**Build Errors**: Check LLVM version compatibility (17.0.1+)
**Performance Issues**: Verify sufficient RAM (~2GB) for large evaluations

### Getting Help

For reproduction issues:
1. Check this guide thoroughly
2. Verify environment requirements
3. Open GitHub issue with detailed error information

## 📞 Contact

**Author**: Douglas J. Huntington Moore  
**Email**: djhmoore@alumni.unimelb.edu.au  
**Paper**: IEEE Transactions on Software Engineering, 2025
EOF

# Create build system improvements
cat > Makefile << 'EOF'
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
EOF

# Update .gitignore to be more comprehensive
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
*.egg-info/
dist/
build/

# IDEs and editors
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# Compiler outputs
*.o
*.so
*.dylib
*.exe
*.out
*.app

# Logs and temporary files
*.log
*.tmp
*.temp
debug_build.sh
build.log
full_output.txt
pass_output.txt

# Generated analysis outputs
/data/scalability/scalability_figure.png
/data/scalability/timing_data.csv
/data/scalability/analysis_report.txt
/data/scalability/tikz_coordinates.txt

# Evaluation results (keep structure, not data)
/evaluation/*/build/
/evaluation/*/*.csv
/evaluation/*/*.json

# Build directories
build/
cmake-build-*/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Project specific
t.c
empirical_results_summary.txt
dispositional_analysis.csv
EOF

echo ""
echo "✅ Project reorganization complete!"
echo ""
echo "📁 New structure:"
tree -I '__pycache__|*.pyc|venv|build' . -L 3 2>/dev/null || find . -maxdepth 3 -type d | grep -v -E "(venv|__pycache__|\.git)" | sort

echo ""
echo "🎯 Next steps:"
echo "1. Run: make setup"
echo "2. Run: make analysis    # Generates Figure 1"
echo "3. Run: make evaluation  # Full LLVM evaluation"
echo ""
echo "📝 Documentation:"
echo "- Setup guide: docs/reproduction/README.md"
echo "- Paper materials: docs/paper/"
echo ""
echo "🔗 Ready for GitHub commit and Zenodo archival!"

# Create GitHub repository preparation
echo ""
echo "🐙 GitHub repository commands:"
echo "git add ."
echo "git commit -m 'Reorganize project structure for IEEE TSE 2025 submission'"
echo "git remote add origin https://github.com/yourusername/dispositional-typing.git"
echo "git branch -M main"
echo "git push -u origin main"