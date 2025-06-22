# 🐳 Docker Reproduction Guide

**One-Command Reproduction for IEEE TSE Reviewers**

This Docker setup provides a **pre-built environment** for reproducing all results from:
> "Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"  
> IEEE Transactions on Software Engineering, 2025

## 🚀 Quick Start (For Busy Reviewers)

### Prerequisites
- **Docker** installed ([Get Docker](https://docs.docker.com/get-docker/))
- **5 minutes** for initial setup
- **30 seconds** for analysis reproduction

### Three Commands to Reproduce Everything

```bash
# 1. Build environment (one-time, ~5 minutes)
./docker-run.sh build

# 2. Reproduce Figure 1 (30 seconds)
./docker-run.sh quick

# 3. Reproduce Table 1 (5-15 minutes, optional)
./docker-run.sh full
```

## 📊 Expected Results

### Quick Analysis (`./docker-run.sh quick`)
```
✅ Scalability analysis complete!
📊 Results saved to: data/scalability/
🖼️  View figure: data/scalability/scalability_figure.png

Key Metrics:
- Linear coefficient: ~0.74 ± 0.03 μs/SSA edge
- R² correlation: >0.94
- Maximum time: <450μs for 567+ edge functions
- Complexity: Confirmed O(n) linear
```

### Full Evaluation (`./docker-run.sh full`)
```
✅ Full evaluation complete!
📊 Results saved to: evaluation/

Expected Results:
- LLVM Test Suite: ~78% unsafe elimination
- Zero false positives across corpus
- Linear analysis time confirmed
```

## 🎯 Reviewer Workflow Options

### Option 1: Minimal Validation (2 minutes)
```bash
./docker-run.sh build   # One-time setup
./docker-run.sh quick   # Validate Figure 1 claims
```

### Option 2: Complete Verification (20 minutes)
```bash
./docker-run.sh build   # One-time setup  
./docker-run.sh quick   # Figure 1 reproduction
./docker-run.sh full    # Table 1 reproduction
```

### Option 3: Interactive Exploration
```bash
./docker-run.sh build      # One-time setup
./docker-run.sh interact   # Enter container shell
# Inside container:
make analysis              # Run analysis manually
make evaluation           # Run evaluation manually
tree data/                # Explore results
exit                      # Leave container
```
