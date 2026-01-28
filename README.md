# Mac Mini M4 Performance Optimization Guide

> Transforming a Mac Mini M4 (16GB) into a high-performance coding and AI development machine.

## System Specifications

| Component | Details |
|-----------|---------|
| Model | Mac Mini (Mac16,10) |
| Chip | Apple M4 |
| CPU | 10 cores (4 performance + 6 efficiency) |
| GPU | 10 cores with Metal 4 |
| RAM | 16GB LPDDR5 unified memory |
| Storage | 228GB SSD |
| Display | 3440x1440 @ 100Hz ultrawide |

---

## Table of Contents

1. [Power Management](#1-power-management)
2. [App Nap](#2-app-nap)
3. [File Descriptor Limits](#3-file-descriptor-limits)
4. [RAM Disk](#4-ram-disk)
5. [Kernel Optimizations](#5-kernel-optimizations)
6. [Environment Variables](#6-environment-variables)
7. [UI Performance](#7-ui-performance)
8. [Background Services](#8-background-services)
9. [Network Optimization](#9-network-optimization)
10. [Spotlight Indexing](#10-spotlight-indexing)
11. [Git & SSH Setup](#11-git--ssh-setup)
12. [Files Created](#12-files-created)
13. [Quick Setup](#13-quick-setup)

---

## 1. Power Management

### What It Does
Prevents the Mac from entering power-saving states that throttle performance.

### Commands Applied
```bash
sudo pmset -a sleep 0
sudo pmset -a disksleep 0
sudo pmset -a displaysleep 0
sudo pmset -a powernap 0
sudo pmset -a standby 0
```

### Before vs After

| Setting | Before | After | Effect |
|---------|--------|-------|--------|
| `sleep` | 1 | 0 | CPU never enters low-power state |
| `disksleep` | 10 | 0 | SSD stays fully powered, no spin-up delay |
| `displaysleep` | varies | 0 | Display stays on (useful for long tasks) |
| `powernap` | 1 | 0 | No background wake cycles |
| `standby` | 0 | 0 | RAM stays powered, instant resume |

### Why It Matters
- Long-running AI training jobs won't be interrupted
- No random throttling during compilation
- Consistent peak performance at all times

### Verify
```bash
pmset -g
```

---

## 2. App Nap

### What It Does
macOS normally "freezes" background applications to save energy. Disabling App Nap keeps all apps running at full speed.

### Command Applied
```bash
defaults write NSGlobalDomain NSAppSleepDisabled -bool YES
```

### Before vs After

| State | Behavior |
|-------|----------|
| Before | Background apps throttled/paused |
| After | All apps run at full speed regardless of focus |

### Why It Matters
- Python scripts in background terminals keep running at full speed
- Jupyter notebooks don't pause when you switch windows
- Background servers maintain full performance
- Long-running processes aren't interrupted

### Verify
```bash
defaults read NSGlobalDomain NSAppSleepDisabled
# Should return: 1
```

---

## 3. File Descriptor Limits

### What It Does
Increases the maximum number of files and network connections that can be open simultaneously.

### Configuration (in ~/.zshrc)
```bash
ulimit -n 65536
```

### Before vs After

| Limit | Before | After |
|-------|--------|-------|
| Open files per process | 256 | 65536 (or unlimited) |

### Why It Matters
- Web servers can handle thousands of connections
- AI tools that load many model files won't hit limits
- Large codebases with many imports work smoothly
- No "too many open files" errors

### Verify
```bash
ulimit -n
```

---

## 4. RAM Disk

### What It Does
Allocates 2GB of RAM as a virtual disk for ultra-fast temporary file storage.

### How It Works
```
Normal file write:  CPU → RAM → SSD (slower)
RAM disk write:     CPU → RAM (instant)
```

### Speed Comparison

| Storage | Speed |
|---------|-------|
| SSD | ~3,000 MB/s |
| RAM | ~100,000 MB/s |
| **Improvement** | **~30x faster** |

### Commands Applied
```bash
# Create RAM disk (2GB = 4194304 512-byte blocks)
diskutil erasevolume HFS+ "RAMDisk" $(hdiutil attach -nomount ram://4194304)

# Create subdirectories
mkdir -p /Volumes/RAMDisk/pip-cache /Volumes/RAMDisk/build
```

### Auto-Mount on Startup
Launch agent installed at: `~/Library/LaunchAgents/com.user.ramdisk.plist`

### Environment Variables (in ~/.zshrc)
```bash
export TMPDIR=/Volumes/RAMDisk
export PIP_CACHE_DIR=/Volumes/RAMDisk/pip-cache
```

### Why It Matters
- Python package installs are nearly instant
- Build artifacts compile faster
- Temp files don't wear out your SSD
- AI model loading is accelerated

### Verify
```bash
df -h /Volumes/RAMDisk
# Should show ~2GB mounted
```

---

## 5. Kernel Optimizations

### What It Does
Tunes low-level system parameters for high-performance workloads.

### Commands Applied
```bash
sudo sysctl kern.ipc.somaxconn=2048
sudo sysctl kern.maxfiles=524288
sudo sysctl kern.maxfilesperproc=262144
sudo sysctl net.inet.tcp.delayed_ack=0
```

### Before vs After

| Parameter | Before | After | Purpose |
|-----------|--------|-------|---------|
| `kern.ipc.somaxconn` | 128 | 2048 | Socket connection queue size |
| `kern.maxfiles` | 122,880 | 524,288 | System-wide file limit |
| `kern.maxfilesperproc` | 61,440 | 262,144 | Per-process file limit |
| `net.inet.tcp.delayed_ack` | 3 | 0 | TCP acknowledgment delay |

### Why It Matters
- **somaxconn**: More simultaneous network connections
- **maxfiles**: Handle large projects with many files
- **delayed_ack=0**: Faster network response (instant TCP ACKs)

### Persistence
Launch daemon installed at: `/Library/LaunchDaemons/com.user.sysctl.plist`

### Verify
```bash
sysctl kern.ipc.somaxconn kern.maxfiles kern.maxfilesperproc net.inet.tcp.delayed_ack
```

---

## 6. Environment Variables

### Complete ~/.zshrc Configuration

```bash
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
```

### Variable Explanations

| Variable | Value | Purpose |
|----------|-------|---------|
| `OBJC_DISABLE_INITIALIZE_FORK_SAFETY` | YES | Fixes Python multiprocessing on macOS |
| `TMPDIR` | /Volumes/RAMDisk | Temp files go to RAM |
| `PIP_CACHE_DIR` | /Volumes/RAMDisk/pip-cache | Python packages cache in RAM |
| `PYTHONUTF8` | 1 | Force UTF-8 encoding |
| `PYTORCH_ENABLE_MPS_FALLBACK` | 1 | Enable Metal GPU for PyTorch |
| `PYTHONOPTIMIZE` | 1 | Run Python in optimized mode |
| `PYTHONDONTWRITEBYTECODE` | 1 | Skip .pyc file generation |
| `CFLAGS` | -O3 -march=native | Maximum compiler optimization for M4 |
| `CXXFLAGS` | -O3 -march=native | Same for C++ |
| `MAKEFLAGS` | -j10 | Use all 10 CPU cores for compilation |
| `NODE_OPTIONS` | --max-old-space-size=8192 | 8GB RAM for Node.js |
| `XZ_OPT` | -T0 | Use all cores for xz compression |
| `ZSTD_NBTHREADS` | 10 | Use all cores for zstd compression |
| `HOMEBREW_NO_ANALYTICS` | 1 | Disable Homebrew telemetry |
| `HOMEBREW_NO_AUTO_UPDATE` | 1 | Faster brew commands |

### Verify
```bash
source ~/.zshrc
echo $TMPDIR $MAKEFLAGS $PYTORCH_ENABLE_MPS_FALLBACK
```

---

## 7. UI Performance

### What It Does
Reduces visual effects to free up GPU cycles for actual work.

### Commands Applied
```bash
# Instant Dock response
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# No bouncing icons
defaults write com.apple.dock no-bouncing -bool true

# Fast Mission Control
defaults write com.apple.dock expose-animation-duration -float 0.1

# Fastest keyboard repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable press-and-hold for accents (enables key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Apply changes
killall Dock
```

### Before vs After

| Setting | Before | After |
|---------|--------|-------|
| Dock autohide delay | ~0.5s | 0s (instant) |
| Dock animation | ~0.5s | 0.3s |
| Mission Control animation | ~0.3s | 0.1s |
| Key repeat rate | 2 | 1 (fastest) |
| Initial key repeat | 15 | 10 (fastest) |
| Press-and-hold | Accent menu | Key repeat |

### Why It Matters
- Less GPU overhead from animations
- Snappier window management
- Faster text editing with rapid key repeat
- More responsive UI overall

### Manual Step (System Settings)
**System Settings → Accessibility → Display:**
- ✅ Reduce motion
- ✅ Reduce transparency

---

## 8. Background Services

### What It Does
Disables unnecessary services that consume CPU/RAM in the background.

### Commands Applied
```bash
# Disable Siri
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# Disable Game Center
defaults write com.apple.gamed Disabled -bool true

# Disable smart quotes and dashes (breaks code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable automatic updates
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool false
defaults write com.apple.commerce AutoUpdate -bool false

# Disable crash reporter dialogs
defaults write com.apple.CrashReporter DialogType -string "none"
```

### Services Disabled

| Service | Why Disable |
|---------|-------------|
| Siri | CPU/RAM overhead, not needed for coding |
| Game Center | Unnecessary background daemon |
| Smart quotes/dashes | Breaks code when copy-pasting |
| Auto-correct | Annoying for coding |
| Auto-updates | Prevent surprise downloads during work |
| Crash dialogs | Logs still captured, no popup interruption |

### Why It Matters
- Less background CPU usage
- No interruptions during work
- Code pastes correctly without smart substitutions

---

## 9. Network Optimization

### What It Does
Configures faster DNS resolution and optimized TCP settings.

### DNS Configuration
```bash
sudo networksetup -setdnsservers "Ethernet" 1.1.1.1 8.8.8.8 1.0.0.1 8.8.4.4
```

### DNS Servers Used

| Provider | Primary | Secondary |
|----------|---------|-----------|
| Cloudflare | 1.1.1.1 | 1.0.0.1 |
| Google | 8.8.8.8 | 8.8.4.4 |

### Why It Matters
- Faster DNS resolution than ISP defaults
- Cloudflare DNS is typically the fastest globally
- Redundancy with Google as backup
- Better for package downloads, git operations

### TCP Optimization
```bash
sudo sysctl net.inet.tcp.delayed_ack=0
```

| Setting | Before | After | Effect |
|---------|--------|-------|--------|
| delayed_ack | 3 | 0 | Instant TCP acknowledgments |

### Verify
```bash
networksetup -getdnsservers "Ethernet"
```

---

## 10. Spotlight Indexing

### What It Does
Prevents Spotlight from indexing your code directories, reducing I/O overhead.

### Configuration
```bash
# Create marker file to prevent indexing
touch ~/Projects/.metadata_never_index
```

### Why It Matters
- Spotlight constantly indexes file changes
- Code projects change frequently
- Reduces disk I/O during development
- Faster file operations in project directories

### Alternative (for entire volumes)
```bash
sudo mdutil -i off /Volumes/ExternalDrive
```

---

## 11. Git & SSH Setup

### SSH Key Generation
```bash
# Generate Ed25519 key (fastest, most secure)
ssh-keygen -t ed25519 -C "seanpizarroclawdbot" -f ~/.ssh/id_ed25519 -N ""

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### SSH Config (~/.ssh/config)
```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

### Git Configuration
```bash
git config --global user.name "seanpizarroclawdbot"
git config --global user.email "seanpizarroclawdbot@users.noreply.github.com"
```

### Why SSH over HTTPS
| Aspect | SSH | HTTPS |
|--------|-----|-------|
| Authentication | Key-based (no password) | Token required |
| Setup | Once, then automatic | Need credential manager |
| Security | Private key stays local | Token can leak |
| Speed | Slightly faster | Slightly slower |

### Verify
```bash
ssh -T git@github.com
# Should say: Hi username! You've successfully authenticated...
```

---

## 12. Files Created

### User Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| `.zshrc` | `~/.zshrc` | Shell configuration and environment variables |
| SSH key | `~/.ssh/id_ed25519` | Private SSH key |
| SSH public key | `~/.ssh/id_ed25519.pub` | Public SSH key (added to GitHub) |
| SSH config | `~/.ssh/config` | SSH client configuration |

### Launch Agents (User)

| File | Location | Purpose |
|------|----------|---------|
| RAM disk agent | `~/Library/LaunchAgents/com.user.ramdisk.plist` | Auto-creates RAM disk on login |

### Launch Daemons (System)

| File | Location | Purpose |
|------|----------|---------|
| Sysctl daemon | `/Library/LaunchDaemons/com.user.sysctl.plist` | Applies kernel settings on boot |

### Project Files

| File | Location | Purpose |
|------|----------|---------|
| Spotlight blocker | `~/Projects/.metadata_never_index` | Prevents Spotlight indexing |

---

## 13. Quick Setup

### For a Fresh Mac Mini M4

1. Clone this repository:
```bash
git clone git@github.com:seanpizarroclawdbot/macm4mini.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
```

2. Run the setup script:
```bash
chmod +x setup.sh
./setup.sh
```

3. Add SSH key to GitHub (manual step):
```bash
cat ~/.ssh/id_ed25519.pub
# Copy output to: https://github.com/settings/ssh/new
```

4. Restart terminal or:
```bash
source ~/.zshrc
```

---

## System Status Check

Run this command to verify all optimizations:

```bash
echo "=== M4 OPTIMIZATION STATUS ==="
echo ""
echo "1. Power: $(pmset -g | grep -E '^\s+sleep\s' | awk '{print $2}')"
echo "2. App Nap: $(defaults read NSGlobalDomain NSAppSleepDisabled 2>/dev/null && echo 'disabled' || echo 'enabled')"
echo "3. File descriptors: $(ulimit -n)"
echo "4. RAM disk: $([ -d /Volumes/RAMDisk ] && echo 'mounted' || echo 'not mounted')"
echo "5. Socket queue: $(sysctl -n kern.ipc.somaxconn)"
echo "6. Max files: $(sysctl -n kern.maxfiles)"
echo "7. TCP delayed_ack: $(sysctl -n net.inet.tcp.delayed_ack)"
echo "8. DNS: $(networksetup -getdnsservers Ethernet | head -1)"
echo "9. Metal: $(system_profiler SPDisplaysDataType 2>/dev/null | grep 'Metal Support' | awk -F': ' '{print $2}')"
```

Expected output:
```
=== M4 OPTIMIZATION STATUS ===

1. Power: 0
2. App Nap: 1 disabled
3. File descriptors: unlimited (or 65536+)
4. RAM disk: mounted
5. Socket queue: 2048
6. Max files: 524288
7. TCP delayed_ack: 0
8. DNS: 1.1.1.1
9. Metal: Metal 4
```

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────┐
│              MAC MINI M4 - BEAST MODE                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   CPU       │  │    GPU      │  │    RAM      │     │
│  │  10 cores   │  │  10 cores   │  │   16 GB     │     │
│  │  no sleep   │  │  Metal 4    │  │  LPDDR5     │     │
│  │  no throttle│  │  low UI load│  │  +2GB disk  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │                OPTIMIZATIONS                     │   │
│  ├─────────────────────────────────────────────────┤   │
│  │ ✓ Power management disabled                     │   │
│  │ ✓ App Nap disabled                              │   │
│  │ ✓ 524K file handles                             │   │
│  │ ✓ 2GB RAM disk for temp/cache                   │   │
│  │ ✓ Kernel TCP/socket optimizations               │   │
│  │ ✓ Cloudflare + Google DNS                       │   │
│  │ ✓ UI animations minimized                       │   │
│  │ ✓ Background services disabled                  │   │
│  │ ✓ Parallel builds enabled (-j10)                │   │
│  │ ✓ Compiler optimizations (-O3)                  │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Trade-offs

| Optimization | Trade-off |
|--------------|-----------|
| No sleep | ~5-10W higher idle power (plugged in, doesn't matter) |
| RAM disk | 2GB less app memory (14GB still plenty) |
| No auto-updates | Must manually update occasionally |
| Disabled Siri | Can't use voice commands |
| No smart quotes | Must type special characters manually |

---

## License

MIT - Do whatever you want with this.

---

*Generated with the help of Claude Code (Opus 4.5)*
