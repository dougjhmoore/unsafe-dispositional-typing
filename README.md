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

## 🐳 Docker Reproduction (Recommended for Reviewers)

**Easiest reproduction method - pre-built environment with LLVM 17:**

```bash
# One-time setup (5 minutes)
./docker-run.sh build

# Quick validation (30 seconds)
./docker-run.sh quick     # Reproduces Figure 1

# Full evaluation (15 minutes)  
./docker-run.sh full      # Reproduces Table 1
```

See [Docker Setup Guide](docs/reproduction/DOCKER_SETUP.md) for detailed instructions.

