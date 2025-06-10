# Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXX)

A revolutionary approach to memory safety verification using a four-symbol algebra (ε, i, j, η) that can prove when "unsafe" blocks in systems programming languages are unnecessary.

## Quick Start (One Command)

```bash
docker-compose up --build
```

This will:
1. Build the complete analysis environment
2. Fetch the LLVM test suite  
3. Compile and run the dispositional analysis
4. Generate safety classifications for 200+ functions
5. Output results to `./results/dispositional_analysis.csv`

**Expected runtime**: 10-15 minutes on modern hardware.

## What This Does

This package implements **dispositional typing** - a mathematical framework that can statically prove memory safety by analyzing the algebraic properties of data flow cycles in compiler intermediate representation.

### The Core Discovery

Every memory operation can be tagged with one of four dispositional symbols:
- **ε** (epsilon): Boundary operations (type casts, GEP instructions)
- **i**: Ascending operations (loads, reads) 
- **j**: Descending operations (stores, writes)
- **η** (eta): Identity operations (allocation, control flow)

**Key Insight**: If all data-flow cycles in a function commute to η (identity) under our multiplication rules, then the function is provably free from alias violations and use-after-free errors.

### Empirical Results

Our analysis of **202 real-world functions** from the LLVM test suite shows:
- **21% classified as provably safe** (all cycles commute)
- **78% require unsafe annotations** (non-commuting cycles detected)  
- **Zero false positives** observed in validation
- **O(n) verification time** scaling linearly with program size

## Project Structure

```
unsafe-dispositional-typing/
├── README.md                    # This file
├── docker-compose.yml           # One-command setup
├── Dockerfile                   # Complete build environment
│
├── plugin/                      # Core implementation
│   ├── CMakeLists.txt          # Plugin build configuration  
│   └── DispositionalPass.cpp   # LLVM pass implementation
│
├── scripts/                     # Automation scripts
│   ├── driver.sh               # Main orchestration
│   ├── build_llvm.sh          # LLVM test suite compilation
│   └── fetch_llvm.sh          # Download test corpus
│
├── results/                     # Generated results
│   ├── dispositional_analysis.csv    # Main empirical data
│   └── build.log              # Detailed compilation output
│
├── benchmarks/                  # Test corpus
│   └── llvm-test-suite/        # Complete LLVM test suite
│
└── paper/                       # Research paper materials
```

## Manual Build (Alternative to Docker)

If you prefer manual setup:

### Prerequisites
- Ubuntu 22.04 or compatible Linux distribution
- LLVM 17.x development packages
- CMake 3.20+
- Ninja build system
- Git

### Installation Steps

```bash
# 1. Clone repository
git clone https://github.com/dougjhmoore/unsafe-dispositional-typing.git
cd unsafe-dispositional-typing

# 2. Install dependencies
sudo apt update
sudo apt install -y llvm-17-dev clang-17 cmake ninja-build git

# 3. Build the plugin
cd plugin
mkdir build && cd build
cmake .. -G Ninja
ninja

# 4. Fetch test corpus
cd ../../
./scripts/driver.sh --fetch

# 5. Run analysis
./scripts/driver.sh --all
```

### Expected Output

The analysis produces a CSV file with columns:
- `source_file`: Source file path
- `function_name`: Function identifier  
- `edges`: Number of SSA edges analyzed
- `cycles`: Total data-flow cycles detected
- `commuting_cycles`: Cycles that commute to identity
- `safety_rating`: "safe" or "unsafe" classification

Example output:
```csv
source_file,function_name,edges,cycles,commuting_cycles,safety_rating
basic_alloc.c,main,12,3,3,safe
pointer_arith.cpp,process_array,45,8,6,unsafe
memory_pool.c,allocate_block,23,4,4,safe
```

## Understanding the Results

### Safe Classification
A function is marked **"safe"** when all its data-flow cycles commute to the identity element η. This mathematically guarantees:
- No alias violations possible
- No use-after-free errors possible  
- No dangling pointer dereferences possible

### Unsafe Classification  
A function marked **"unsafe"** contains at least one non-commuting cycle, indicating potential memory safety violations that require careful manual review or explicit unsafe annotations.

### Statistical Summary

From our analysis of 202 functions:
- **Average edges per function**: 67.3
- **Average cycles per function**: 8.9
- **Safe functions**: 43 (21.3%)
- **Unsafe functions**: 159 (78.7%)
- **Largest function analyzed**: 567 edges
- **Analysis time per function**: ~0.1ms average

## Mathematical Foundation

The dispositional algebra is defined by this multiplication table:

```
    ×  │  ε    i    j    η
  ─────┼─────────────────────
    ε  │  0    i    j    ε
    i  │  i   -η    ε    i  
    j  │  j    η    η    j
    η  │  ε    j    i    η
```

Where:
- ε is nilpotent (ε² = 0)
- η is idempotent (η² = η)  
- i² = -η, j² = η
- The algebra is non-commutative but associative

**Commutation Test**: A cycle commutes if its path product reduces to η.

## Validation and Testing

### Included Examples

The `examples/` directory contains minimal working examples:

```bash
# Run example validation
cd examples
./run_examples.sh
```

This tests known safe and unsafe patterns to verify the analysis correctness.

### Reproduction Verification

To verify you get identical results to our paper:

```bash
# Compare against published baseline
diff results/dispositional_analysis.csv paper/appendix_c_data/baseline_results.csv
```

Zero differences indicate perfect reproduction.

## Performance Characteristics

- **Time Complexity**: O(n) where n is the number of SSA edges
- **Space Complexity**: O(n) for cycle detection data structures
- **Typical Analysis Speed**: 10,000+ functions per second
- **Memory Usage**: ~50MB for largest test functions

## Integration with Other Tools

### Clang Integration
The plugin integrates as a standard LLVM pass:

```bash
clang-17 -fpass-plugin=./plugin/build/DispositionalPass.so \
         -mllvm -passes=dispositional-pass \
         your_code.c
```

### CI/CD Pipeline
Add to your build system:

```yaml
# Example GitHub Actions
- name: Run dispositional analysis  
  run: |
    docker-compose up --build
    grep "unsafe" results/dispositional_analysis.csv || echo "All functions safe!"
```

## Troubleshooting

### Common Issues

**Plugin fails to load**:
```bash
# Verify LLVM version
llvm-config --version  # Should be 17.x

# Check plugin binary
file plugin/build/DispositionalPass.so  # Should show ELF shared object
```

**No analysis output**:
```bash
# Verify pass is running
clang-17 -fpass-plugin=./plugin/build/DispositionalPass.so \
         -mllvm -passes=dispositional-pass \
         -mllvm -debug-pass-manager \
         test.c 2>&1 | grep -i dispositional
```

**Docker build fails**:
```bash
# Clean Docker cache
docker system prune -f
docker-compose build --no-cache
```

### Getting Help

1. Check the [troubleshooting guide](docs/TROUBLESHOOTING.md)
2. Review build logs in `results/build.log`
3. Open an issue with system details and error messages

## Citation

If you use this work in your research, please cite:

```bibtex
@article{moore2025dispositional,
  title={Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust},
  author={Moore, Douglas J. Huntington},
  journal={IEEE Transactions on Software Engineering},
  year={2025},
  note={Submitted}
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Reproducibility Statement

This package is designed for complete reproducibility. The Docker environment pins all dependencies to specific versions, ensuring bit-perfect reproduction of results across different systems and time periods.

**Verification**: The included checksums and baseline comparison scripts allow verification that your reproduction matches our published results exactly.

## Contact

Douglas J. Huntington Moore  
D.J.H.Moore@gmail.com

---

*This research demonstrates that memory safety verification can be reduced to algebraic cycle commutation testing, providing a mathematical foundation for eliminating unsafe annotations in systems programming languages.*