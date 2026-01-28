# === M4 Performance Optimizations ===
ulimit -n 65536

# Python multiprocessing fix for macOS
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Use RAM disk for temp files (faster builds)
export TMPDIR=/Volumes/RAMDisk
export PIP_CACHE_DIR=/Volumes/RAMDisk/pip-cache
export PYTHONUTF8=1

# Enable Metal acceleration for ML frameworks
export PYTORCH_ENABLE_MPS_FALLBACK=1

# Optimize Python for performance
export PYTHONOPTIMIZE=1
export PYTHONDONTWRITEBYTECODE=1

# Compiler optimizations for native builds
export CFLAGS="-O3 -march=native"
export CXXFLAGS="-O3 -march=native"

# Parallelization for builds
export MAKEFLAGS="-j10"

# Faster git operations
export GIT_TERMINAL_PROMPT=0

# Node.js optimization (if used)
export NODE_OPTIONS="--max-old-space-size=8192"

# Use all cores for compression
export XZ_OPT="-T0"
export ZSTD_NBTHREADS=10

# Homebrew optimization
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# Faster ZSH startup
skip_global_compinit=1

# Snapshot aliases (APFS/Time Machine)
alias snap='sudo tmutil localsnapshot'
alias snaplist='tmutil listlocalsnapshots /'
alias snapdelete='sudo tmutil deletelocalsnapshots'
