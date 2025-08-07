# Dispositional Typing – Complete Reproduction Guide

This repository contains everything needed to reproduce the results reported in the paper  
**“Dispositional Typing: Eliminating Unsafe Annotations in C, C++ and Rust.”**

---

## 🚀 1  Quick-Start (Docker – recommended)

### 1.1 What you need

| Host OS                    | Install                                                                                                                  | Notes                                                                               |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| **Windows 10/11**          | [Docker Desktop](https://docs.docker.com/desktop/windows/install/)                                                       | Requires **WSL 2** and CPU virtualization enabled (BIOS → *Intel VT-x* or *AMD-V*). |
| **macOS 12 +**             | [Docker Desktop](https://docs.docker.com/desktop/mac/install/)                                                           | Apple Silicon is supported via multi-arch image.                                    |
| **Linux (Ubuntu 20.04 +)** | `sudo apt install docker.io` or follow the [Docker Engine install guide](https://docs.docker.com/engine/install/ubuntu/) | Add yourself to the `docker` group: `sudo usermod -aG docker $USER` then re-login.  |

Verify the installation:

```bash
docker version

# both Client and Server information should print without errors

1.2 Clone & build
bash
Copy
Edit
git clone https://github.com/<YOUR-FORK>/dispositional-typing.git
cd dispositional-typing

# Build the image (≈ 5 min the first time)

docker build -t dispositional-typing .
The Dockerfile installs:

Ubuntu 22.04 base

Python 3.11 + required scientific stack

LLVM 17 for C/C++ analysis

Rust nightly-1.77 tool-chain

All project source code & scripts (copied into /workspace)

1.3 Run the analyses
bash
Copy
Edit

# Start an interactive container

docker run --rm -it \
  -v "$(pwd)":/workspace \
  dispositional-typing bash

# Inside the container:

cd /workspace/scripts/analysis/scalability/
python scalability_analysis.py --output-dir ../../../data/scalability/

# Optional: full LLVM evaluation

cd /workspace/scripts/evaluation/
./driver.sh --full-evaluation
All artefacts (figures, CSV files, reports) appear in the host directory because the repository was mounted with -v "$(pwd)":/workspace.

Tip: Repeat executions are much faster: the Docker image and LLVM build cache persist on disk.

🔧 2 Manual Setup (no Docker)
2.1 Prerequisites
OS: Ubuntu 22.04 LTS (or compatible), macOS 12+, Windows 10 + WSL2

Python: 3.8 – 3.11

LLVM/Clang: 17.0.1 +

Rust: nightly-1.77 + (only if reproducing Rust results)

Memory: ≥ 2 GB Disk: ≈ 500 MB

2.2 Python environment
bash
Copy
Edit
python -m venv venv
source venv/bin/activate
pip install -r scripts/requirements.txt
Confirm:

bash
Copy
Edit
python - <<'PY'
import numpy, matplotlib, scipy, llvmlite, rustworkx
print("✅   Python stack ready")
PY
2.3 LLVM plugin build
bash
Copy
Edit
cd tools/clang-plugin/
mkdir -p build && cd build
cmake .. && make -j$(nproc)
Add build/bin to your PATH or set CLANG_PLUGIN_PATH.

2.4 Reproduce results
bash
Copy
Edit

# Scalability figure (Figure 1)

cd scripts/analysis/scalability/
python scalability_analysis.py --output-dir ../../../data/scalability/

# LLVM test-suite evaluation (Table 1)

cd ../../../scripts/evaluation/
./driver.sh --full-evaluation
Rust experiments:

bash
Copy
Edit
rustup install nightly-2025-01-01
rustup default nightly-2025-01-01
cd evaluation/rust-libstd/
./run_libstd_eval.sh
✅ 3 Validation Checklist
Target    Pass criterion
Figure 1 generated    data/scalability/scalability_figure.png exists
Linearity R²    > 0.99
LLVM evaluation    ≥ 78 % unsafe-elimination, 0 false-positives
Max analysis time    ≤ 500 µs for 567 + SSA edges

🐛 4 Troubleshooting
Symptom    Fix
docker build fails on Windows    Ensure WSL2 is active (wsl -l -v) and virtualization enabled in BIOS.
Python import errors (manual path)    Activate the venv and reinstall requirements.
Clang cannot find plugin    Export CLANG_PLUGIN_PATH=<repo>/tools/clang-plugin/build/lib.
High memory usage    Close other heavy apps; 2 GB RAM is sufficient for all scripts.

📞 5 Contact
Author: Douglas J. Huntington Moore
Email: djhmoore@alumni.unimelb.edu.au
Project DOI and Zenodo archive are listed in CITATION.cff.
