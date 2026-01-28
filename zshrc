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

# === Shell Enhancements ===

# Eza (modern ls)
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias la='eza -a --icons --group-directories-first'

# Better defaults
alias cat='bat --style=plain 2>/dev/null || cat'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -pv'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias proj='cd ~/Projects'

# Zsh autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Zsh syntax highlighting (must be last plugin)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fzf keybindings and completion
source <(fzf --zsh)

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Starship prompt (must be at end)
eval "$(starship init zsh)"
