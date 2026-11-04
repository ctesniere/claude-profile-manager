#!/bin/zsh

# ============================================================================
# Install Claude Scripts - Install claude-cli and claude-app to PATH
# ============================================================================
#
# Usage:
#   ./scripts/install-commands.sh
#   or
#   sudo ./scripts/install-commands.sh  (for /usr/local/bin)
#
# This script installs:
#   - claude-cli    (Launch Claude CLI with profile)
#   - claude-app    (Launch Claude.app with profile)
#
# They will be available as commands like: ls, ll, etc.
#
# ============================================================================

set -e

readonly SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/messages.sh"

# ============================================================================
# Determine Installation Directory
# ============================================================================

determine_install_dir() {
  # Check if running with sudo
  if [[ $EUID -eq 0 ]]; then
    # Can use /usr/local/bin
    INSTALL_DIR="/usr/local/bin"
    print_step "Running as root - using /usr/local/bin"
  else
    # Use ~/.local/bin or ~/bin
    if [[ -d "$HOME/.local/bin" ]]; then
      INSTALL_DIR="$HOME/.local/bin"
      print_step "Using ~/.local/bin"
    elif [[ -d "$HOME/bin" ]]; then
      INSTALL_DIR="$HOME/bin"
      print_step "Using ~/bin"
    else
      # Create ~/.local/bin
      mkdir -p "$HOME/.local/bin"
      INSTALL_DIR="$HOME/.local/bin"
      print_step "Creating ~/.local/bin"
    fi
  fi

  # Check if directory is in PATH
  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_warning "Install directory not in PATH: $INSTALL_DIR"
    echo "Add to your ~/.zshrc:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
  fi
}

# ============================================================================
# Install Scripts (Using Symbolic Links)
# ============================================================================

install_scripts() {
  print_header "Installing Claude Commands (Symbolic Links)"

  determine_install_dir

  # Look for scripts/ directory relative to current working directory
  local scripts_dir=""
  
  # Check if ./commands/claude-cli exists (most common case)
  if [[ -f "./commands/claude-cli" ]] && [[ -f "./commands/claude-app" ]]; then
    scripts_dir="./commands"
  fi
  
  # Check absolute path
  if [[ -z "$scripts_dir" ]] && [[ -f "$(pwd)/commands/claude-cli" ]]; then
    scripts_dir="$(pwd)/commands"
  fi
  
  # Check if we're already in the scripts directory
  if [[ -z "$scripts_dir" ]] && [[ -f "./claude-cli" ]] && [[ -f "./claude-app" ]]; then
    scripts_dir="."
  fi
  
  # If still not found, error
  if [[ -z "$scripts_dir" ]]; then
    print_error "Scripts not found!"
    print_error "Could not locate claude-cli and claude-app"
    return 1
  fi

  # Convert to absolute path for symlinks (important!)
  scripts_dir=$(cd "$scripts_dir" && pwd)

  # Install each command via a symlink into the install directory
  local cmd
  for cmd in claude-cli claude-app; do
    print_step "Creating symlink for $cmd..."

    if [[ ! -f "$scripts_dir/$cmd" ]]; then
      print_warning "Source not found, skipping: $scripts_dir/$cmd"
      continue
    fi

    # Remove existing symlink/file if present
    if [[ -e "$INSTALL_DIR/$cmd" ]] || [[ -L "$INSTALL_DIR/$cmd" ]]; then
      rm -f "$INSTALL_DIR/$cmd"
    fi

    ln -s "$scripts_dir/$cmd" "$INSTALL_DIR/$cmd"
    chmod +x "$scripts_dir/$cmd"
    print_success "Symlink created: $INSTALL_DIR/$cmd → $scripts_dir/$cmd"
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Installation Complete! ✅"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Commands installed via symlinks:"
  echo "  Source: $scripts_dir/"
  echo "  Links:  $INSTALL_DIR/"
  echo ""
  echo "Benefits of symlinks:"
  echo "  ✅ Script updates are immediate"
  echo "  ✅ No disk space duplication"
  echo "  ✅ Single source of truth"
  echo ""
  echo "Usage:"
  echo "  claude-cli <profile>      # Launch Claude CLI"
  echo "  claude-app <profile>      # Launch Claude.app"
  echo ""
  echo "Examples:"
  echo "  claude-cli perso"
  echo "  claude-app sfeir"
  echo ""

  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "⚠️  Add to PATH in ~/.zshrc:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
  fi

  echo "Verify installation:"
  echo "  which claude-cli"
  echo "  which claude-app"
  echo "  ls -la $INSTALL_DIR/claude-*"
  echo ""
}

# ============================================================================
# Tab Completion Setup (Optional)
# ============================================================================

setup_completion() {
  print_header "Setting up Tab Completion (Optional)"

  # Delegate to the dedicated completions installer, located next to this
  # script (both live in scripts/).
  local completions_installer="$SCRIPT_DIR/install-completions.sh"

  if [[ ! -f "$completions_installer" ]]; then
    print_error "Completions installer not found: $completions_installer"
    print_warning "Skipping tab completion setup."
    return 0
  fi

  print_step "Running install-completions.sh..."
  echo ""

  # Run it as a separate process so its own `set -e` doesn't abort this script.
  if "$completions_installer"; then
    print_success "Tab completion setup finished"
  else
    print_warning "Tab completion setup did not complete successfully"
  fi
  echo ""
}

# ============================================================================
# Verification
# ============================================================================

verify_installation() {
  print_header "Verifying Installation"

  if command -v claude-cli &> /dev/null; then
    print_success "claude-cli is available"
    echo "  Location: $(which claude-cli)"
  else
    print_error "claude-cli not found in PATH"
    echo "  Make sure $INSTALL_DIR is in your PATH"
    return 1
  fi

  if command -v claude-app &> /dev/null; then
    print_success "claude-app is available"
    echo "  Location: $(which claude-app)"
  else
    print_error "claude-app not found in PATH"
    echo "  Make sure $INSTALL_DIR is in your PATH"
    return 1
  fi

  echo ""
  print_step "Testing claude-cli..."
  if claude-cli -h &> /dev/null || claude-cli 2>&1 | grep -q "Missing profile"; then
    print_success "claude-cli is working"
  fi

  echo ""
  print_step "Available profiles:"
  if command -v claude-cli &> /dev/null; then
    claude-cli 2>&1 | grep "Available profiles:" -A 10 || echo "  (create ~/.claude-{name} directories)"
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Installation Verified ✅"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# ============================================================================
# Post-Installation Help
# ============================================================================

post_install_help() {
  print_header "Next Steps"

  cat << 'EOF'
1. ✅ Commands installed

2. 🔧 If commands not available:
   - Add to your ~/.zshrc:
     export PATH="/usr/local/bin:$PATH"   (if sudo)
     export PATH="$HOME/.local/bin:$PATH" (if user)
   
   - Then reload: exec zsh

3. 🚀 Try the commands:
   claude-cli perso
   claude-app sfeir

4. 📚 Create profiles:
   mkdir -p ~/.claude-perso
   mkdir -p ~/.claude-work

5. 💡 Tab completion (optional):
   Run: ./scripts/install-commands.sh (again)
   Choose "Enable completion"

Need help? Read:
  - README.md (overview)
  - docs/INSTALLATION.md (detailed guide)
  - docs/TROUBLESHOOTING.md (common issues)

EOF
}

# ============================================================================
# Main
# ============================================================================

main() {
  print_header "Claude CLI/APP Installation"

  echo "This script will install:"
  echo "  • claude-cli    (Launch Claude CLI with a profile)"
  echo "  • claude-app    (Launch Claude.app with a profile)"
  echo ""
  echo "After installation, you can use them like any system command:"
  echo "  claude-cli perso"
  echo "  claude-app sfeir"
  echo ""

  # Check if running from correct directory
  # Look for scripts/ directory relative to current working directory
  
  local scripts_dir=""
  
  # Check if ./commands/claude-cli exists (most common case)
  if [[ -f "./commands/claude-cli" ]] && [[ -f "./commands/claude-app" ]]; then
    scripts_dir="./commands"
  fi
  
  # Check absolute path
  if [[ -z "$scripts_dir" ]] && [[ -f "$(pwd)/commands/claude-cli" ]]; then
    scripts_dir="$(pwd)/commands"
  fi
  
  # Check if we're already in the scripts directory
  if [[ -z "$scripts_dir" ]] && [[ -f "./claude-cli" ]] && [[ -f "./claude-app" ]]; then
    scripts_dir="."
  fi
  
  # If still not found, error with helpful message
  if [[ -z "$scripts_dir" ]]; then
    print_error "Scripts not found!"
    echo ""
    echo "Expected to find:"
    echo "  - ./commands/claude-cli"
    echo "  - ./commands/claude-app"
    echo ""
    echo "Make sure you're running from the repository root:"
    echo "  cd /path/to/claude-profile-manager"
    echo "  ./scripts/install-commands.sh"
    echo ""
    echo "Files in current directory:"
    ls -la | grep -E "scripts|claude" || echo "  (no scripts or claude files found)"
    return 1
  fi

  read -q "?Continue? (y/n) " || return 0
  echo ""
  echo ""

  # Install scripts
  install_scripts || return 1

  # Verify
  echo ""
  verify_installation || return 1

  # Help
  post_install_help
}

main "$@"