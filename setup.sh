#!/bin/bash
# Mac Mini M4 Performance Setup Script
# Run: chmod +x setup.sh && ./setup.sh

set -e

echo "=== M4 Mac Mini Performance Setup ==="

# 1. Shell config
echo "Installing .zshrc..."
cp zshrc ~/.zshrc

# 2. RAM disk launch agent
echo "Installing RAM disk auto-mount..."
mkdir -p ~/Library/LaunchAgents
cp com.user.ramdisk.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.ramdisk.plist 2>/dev/null || true

# 3. Create RAM disk now
echo "Creating RAM disk..."
diskutil erasevolume HFS+ "RAMDisk" $(hdiutil attach -nomount ram://4194304) || true
mkdir -p /Volumes/RAMDisk/pip-cache /Volumes/RAMDisk/build

# 4. Kernel settings (requires sudo)
echo "Applying kernel settings..."
sudo cp com.user.sysctl.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.user.sysctl.plist
sudo chmod 644 /Library/LaunchDaemons/com.user.sysctl.plist
sudo launchctl load /Library/LaunchDaemons/com.user.sysctl.plist 2>/dev/null || true
sudo sysctl kern.ipc.somaxconn=2048 kern.maxfiles=524288 kern.maxfilesperproc=262144 net.inet.tcp.delayed_ack=0

# 5. Power management
echo "Setting power management..."
sudo pmset -a sleep 0 disksleep 0 displaysleep 0 powernap 0 standby 0

# 6. macOS tweaks
echo "Applying macOS tweaks..."
defaults write NSGlobalDomain NSAppSleepDisabled -bool YES
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock expose-animation-duration -float 0.1
killall Dock

# 7. DNS
echo "Setting DNS..."
sudo networksetup -setdnsservers "Ethernet" 1.1.1.1 8.8.8.8 1.0.0.1 8.8.4.4

# 8. Projects folder
echo "Creating Projects folder..."
mkdir -p ~/Projects
touch ~/Projects/.metadata_never_index

# 9. Shell enhancements
echo "Installing shell tools..."
brew install starship zsh-autosuggestions zsh-syntax-highlighting fzf zoxide eza bat

# 10. Starship config
echo "Installing starship config..."
mkdir -p ~/.config
cp starship.toml ~/.config/

# 11. Terminals (optional)
echo "Installing terminals..."
brew install --cask iterm2 warp

# 12. SSH config
echo "Installing SSH config..."
mkdir -p ~/.ssh
cp ssh_config ~/.ssh/config
chmod 600 ~/.ssh/config

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Generate SSH key: ssh-keygen -t ed25519 -C 'your-email'"
echo "3. Add SSH key to GitHub: cat ~/.ssh/id_ed25519.pub"
echo ""
echo "Installed apps:"
echo "- iTerm2: Better terminal"
echo "- Warp: Modern AI terminal"
