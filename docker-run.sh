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
