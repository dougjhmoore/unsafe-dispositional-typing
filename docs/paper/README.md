# Paper

This folder contains manuscripts and source files for the IEEE TSE paper.

- **Submitted version**: moore2025_dispositional_typing_submitted.pdf  
- **LaTeX source**: Dispositional_Typing.tex (submitted version source)
- **ArXiv preprint**: arxiv_preprint_Dispositional_Typing.pdf
- **Figure 1**: Reproduced by running `make analysis` in project root
- **Key claims**: Verified by scalability analysis in `scripts/analysis/scalability/`

## Cross-Reference

The scalability analysis in this repository reproduces Figure 1 from the paper, demonstrating:
- Linear O(n) complexity with R² > 0.94
- Timing coefficient ~0.74 μs/SSA edge  
- Statistical validation with p-value < 1e-25

## Complete Reproducibility

This package provides full reproducibility:
- **LaTeX Source**: Complete paper source for recompilation
- **Code**: Dispositional typing implementation  
- **Data**: Generated analysis results
- **Verification**: Cross-referenced claims and figures

For questions about reproducing paper results, run the analysis and compare with Figure 1 in the submitted manuscript.