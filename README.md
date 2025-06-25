# Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15734195.svg)](https://doi.org/10.5281/zenodo.15734195)

**Reproducibility package for IEEE Transactions on Software Engineering paper:**  
**"Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"** by Douglas J. Huntington Moore.

## 🎯 Key Claims

- **78% reduction** in unsafe annotations across diverse codebases
- **Zero false positives** in comprehensive evaluation  
- **Linear O(n) complexity** with ~0.8μs/SSA edge coefficient
- **Language-agnostic** approach (C, C++, Rust)

## 🚀 Reproduction (3 minutes total)

### Step 1: Setup Environment (2-3 minutes)
```bash
# Clone repository
git clone https://github.com/dougjhmoore/unsafe-dispositional-typing.git
cd unsafe-dispositional-typing

# Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r scripts/requirements.txt
```

### Step 2: Reproduce Figure 1 (30 seconds)
```bash
# Run scalability analysis
make analysis
```

### Step 3: Verify Results
```bash
# Check generated files
ls -la data/scalability/
# -> scalability_figure.png     (Figure 1 from paper)
# -> timing_data.csv           (Raw measurements)  
# -> tikz_coordinates.txt      (LaTeX coordinates)
# -> analysis_report.txt       (Statistical validation)
```

## 📊 Expected Results

The analysis should reproduce **Figure 1** from the paper with these characteristics:

- **Linear complexity**: R² > 0.94
- **Timing coefficient**: ~0.74 ± 0.03 μs/SSA edge  
- **Maximum analysis time**: ~411μs for 567-edge functions
- **Statistical significance**: p-value < 1e-25

**Sample output:**
```
Linear Regression Results:
- Measured coefficient: 0.740 ± 0.028 μs/edge
- R² correlation: 0.9406
- p-value: 1.30e-28
- Linear complexity confirmed: O(n) with excellent fit
```

## 📁 Repository Structure

```
├── scripts/analysis/scalability/    # Core scalability analysis
├── data/scalability/               # Generated outputs  
├── scripts/requirements.txt        # Python dependencies
├── Makefile                       # Simple commands
└── docs/                          # Paper and documentation
```

## 🎓 Citation

```bibtex
@article{moore2025dispositional,
  title={Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust},
  author={Moore, Douglas J. Huntington},
  journal={IEEE Transactions on Software Engineering},
  year={2025},
  doi={10.5281/zenodo.15734195}
}
```

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Author**: Douglas J. Huntington Moore (djhmoore@alumni.unimelb.edu.au)  
**Institution**: Independent Researcher  
**Paper**: IEEE Transactions on Software Engineering, 2025

## ❓ Questions?

For reproduction issues or questions about the implementation, please open an issue in this repository.
