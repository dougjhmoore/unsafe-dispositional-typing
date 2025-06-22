#!/bin/bash
# setup_docker.sh
# Creates Docker environment for IEEE TSE reproducibility

echo "🐳 Setting up Docker environment for IEEE TSE reviewers..."

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Dockerfile for Dispositional Typing - IEEE TSE 2025
# Pre-built environment for easy reviewer reproduction

FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # LLVM 17 and development tools
    wget \
    gnupg \
    software-properties-common \
    build-essential \
    cmake \
    git \
    # Python environment
    python3 \
    python3-pip \
    python3-venv \
    # Utilities
    tree \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add LLVM 17 repository and install
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
    llvm-17 \
    llvm-17-dev \
    clang-17 \
    libclang-17-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up LLVM environment
ENV LLVM_DIR=/usr/lib/llvm-17
ENV PATH="/usr/lib/llvm-17/bin:${PATH}"

# Create working directory
WORKDIR /dispositional-typing

# Copy project files
COPY . .

# Set up Python environment
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r scripts/requirements.txt

# Pre-build the Clang plugin to save reviewer time
RUN . venv/bin/activate && \
    cd tools/clang-plugin && \
    mkdir -p build && \
    cd build && \
    cmake -DLLVM_DIR=/usr/lib/llvm-17/lib/cmake/llvm .. && \
    make

# Create convenience scripts
RUN echo '#!/bin/bash\n\
cd /dispositional-typing\n\
. venv/bin/activate\n\
exec "$@"' > /usr/local/bin/run-analysis && \
    chmod +x /usr/local/bin/run-analysis

# Set default command
CMD ["/bin/bash"]

# Labels for metadata
LABEL maintainer="Douglas J. Huntington Moore <djhmoore@alumni.unimelb.edu.au>"
LABEL description="Dispositional Typing: IEEE TSE 2025 Reproducibility Container"
LABEL version="1.0"
LABEL paper="Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
# docker-compose.yml
# IEEE TSE 2025 - Dispositional Typing Reproducibility

version: '3.8'

services:
  dispositional-typing:
    build: .
    container_name: dispositional-typing-ieee-tse
    volumes:
      # Mount results directory to host for easy access
      - ./results:/dispositional-typing/results
      - ./data:/dispositional-typing/data
    working_dir: /dispositional-typing
    environment:
      - TERM=xterm-256color
    # Keep container running for interactive use
    tty: true
    stdin_open: true

  # Quick analysis service (for reviewers in a hurry)
  quick-analysis:
    build: .
    container_name: dispositional-typing-quick
    volumes:
      - ./data:/dispositional-typing/data
    working_dir: /dispositional-typing
    command: >
      bash -c "
      . venv/bin/activate &&
      echo '🔬 Running quick scalability analysis...' &&
      cd scripts/analysis/scalability &&
      python scalability_analysis.py --output-dir ../../../data/scalability/ &&
      echo '✅ Quick analysis complete! Results in data/scalability/' &&
      echo '📊 Key results:' &&
      cat ../../../data/scalability/analysis_report.txt &&
      echo '' &&
      echo '🖼️  Figure 1 generated: data/scalability/scalability_figure.png' &&
      echo '📈 TikZ coordinates: data/scalability/tikz_coordinates.txt'
      "

  # Full evaluation service (for thorough reviewers)
  full-evaluation:
    build: .
    container_name: dispositional-typing-full
    volumes:
      - ./data:/dispositional-typing/data
      - ./evaluation:/dispositional-typing/evaluation
    working_dir: /dispositional-typing
    command: >
      bash -c "
      . venv/bin/activate &&
      echo '🏗️  Clang plugin already built during container creation' &&
      echo '🔬 Running full LLVM test suite evaluation...' &&
      cd scripts/evaluation &&
      ./driver.sh &&
      echo '✅ Full evaluation complete!' &&
      echo '📊 Results available in evaluation/ directory'
      "

  # Interactive development environment
  interactive:
    build: .
    container_name: dispositional-typing-dev
    volumes:
      - .:/dispositional-typing
    working_dir: /dispositional-typing
    environment:
      - TERM=xterm-256color
    tty: true
    stdin_open: true
    command: >
      bash -c "
      . venv/bin/activate &&
      echo '🐳 Dispositional Typing Development Environment Ready!' &&
      echo '📋 Available commands:' &&
      echo '  make analysis    - Run scalability analysis' &&
      echo '  make evaluation  - Run full LLVM evaluation' &&
      echo '  tree data/       - View generated results' &&
      echo '  exit            - Leave container' &&
      echo '' &&
      /bin/bash
      "
EOF

# Create docker-run.sh script
cat > docker-run.sh << 'EOF'
#!/bin/bash
# docker-run.sh
# Easy Docker commands for IEEE TSE reviewers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}🐳 Dispositional Typing - IEEE TSE 2025 Reproducibility${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker daemon is not running. Please start Docker.${NC}"
        exit 1
    fi
}

# Function to build the container
build_container() {
    echo -e "${YELLOW}🏗️  Building Docker container (first time only)...${NC}"
    echo "This may take 5-10 minutes to download and build LLVM environment."
    echo ""
    docker-compose build dispositional-typing
    echo -e "${GREEN}✅ Container built successfully!${NC}"
    echo ""
}

# Function to run quick analysis
quick_analysis() {
    echo -e "${BLUE}🚀 Running Quick Analysis (Figure 1 reproduction)${NC}"
    echo "Expected time: 30 seconds"
    echo ""
    docker-compose run --rm quick-analysis
    echo ""
    echo -e "${GREEN}✅ Quick analysis complete!${NC}"
    echo -e "📊 Results saved to: ${YELLOW}data/scalability/${NC}"
    echo -e "🖼️  View figure: ${YELLOW}data/scalability/scalability_figure.png${NC}"
}

# Function to run full evaluation
full_evaluation() {
    echo -e "${BLUE}🔬 Running Full LLVM Evaluation (Table 1 reproduction)${NC}"
    echo "Expected time: 5-15 minutes depending on system"
    echo ""
    docker-compose run --rm full-evaluation
    echo ""
    echo -e "${GREEN}✅ Full evaluation complete!${NC}"
    echo -e "📊 Results saved to: ${YELLOW}evaluation/${NC}"
}

# Function to run interactive mode
interactive_mode() {
    echo -e "${BLUE}💻 Starting Interactive Development Environment${NC}"
    echo ""
    docker-compose run --rm interactive
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up Docker containers and images...${NC}"
    docker-compose down
    docker system prune -f
    echo -e "${GREEN}✅ Cleanup complete!${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build      Build the Docker container (run first time)"
    echo "  quick      Run quick scalability analysis (Figure 1)"
    echo "  full       Run full LLVM evaluation (Table 1)" 
    echo "  interact   Start interactive development environment"
    echo "  cleanup    Remove Docker containers and clean up"
    echo "  help       Show this help message"
    echo ""
    echo "Quick start for reviewers:"
    echo "  $0 build    # One-time setup"
    echo "  $0 quick    # 30-second validation"
    echo "  $0 full     # Complete reproduction"
    echo ""
}

# Main script logic
check_docker

case "${1:-help}" in
    "build")
        build_container
        ;;
    "quick")
        quick_analysis
        ;;
    "full")
        full_evaluation
        ;;
    "interact")
        interactive_mode
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|"--help"|"-h"|"")
        show_usage
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac
EOF

# Make docker-run.sh executable
chmod +x docker-run.sh

# Create Docker-specific README
cat > docs/reproduction/DOCKER_SETUP.md << 'EOF'
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
EOF

# Update main README with Docker instructions
cat >> README.md << 'EOF'

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

EOF

echo ""
echo "✅ Docker environment setup complete!"
echo ""
echo "📁 Created files:"
echo "├── Dockerfile                     # Pre-built LLVM environment"
echo "├── docker-compose.yml            # Multi-service configuration"  
echo "├── docker-run.sh                 # Easy reviewer commands"
echo "└── docs/reproduction/DOCKER_SETUP.md  # Complete Docker guide"
echo ""
echo "🚀 Reviewer workflow:"
echo "1. ./docker-run.sh build    # 5-minute one-time setup"
echo "2. ./docker-run.sh quick    # 30-second Figure 1 validation"
echo "3. ./docker-run.sh full     # 15-minute complete reproduction"
echo ""
echo "🎯 This solves the LLVM installation complexity for reviewers!"
echo "Docker pre-installs everything, making reproduction trivial."