#driver.sh
#!/usr/bin/env bash



set -euo pipefail

case "$1" in
  --fetch)
    /scripts/fetch_llvm.sh
    ;;
  --all)
    /scripts/build_llvm.sh
    ;;
  *)
    echo "usage: driver.sh {--fetch|--all}" >&2 ; exit 1 ;;
esac