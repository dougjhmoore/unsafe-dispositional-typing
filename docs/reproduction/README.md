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
