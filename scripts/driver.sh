#driver.sh
#!/usr/bin/env bash
set -e
case "$1" in
  --fetch)
      bash /scripts/fetch_llvm.sh ;;
  --all)
      bash /scripts/fetch_llvm.sh
      bash /scripts/build_llvm.sh ;;
  --reproduce)
      bash /scripts/build_llvm.sh ;;
  *)
      echo "usage: driver.sh --fetch|--all|--reproduce"; exit 1 ;;
esac

