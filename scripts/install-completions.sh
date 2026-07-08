#!/bin/zsh

# ============================================================================
# Install zsh completions for claude-cli and claude-app
# ============================================================================
#
# Detects your zsh setup (Oh-My-Zsh, custom fpath, or system) and installs
# completion files via symbolic links.
#
# Usage:
#   ./scripts/install-completions.sh
#
# ============================================================================

set -e

readonly SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/completions-install-output.sh"

# ----------------------------------------------------------------------------
# Find source files
# ----------------------------------------------------------------------------

# Locate the completions directory (../completions relative to this script)
find_completions_dir() {
  local candidates=(
    "./completions"
    "$(pwd)/completions"
  )

  for dir in "${candidates[@]}"; do
    if [[ -f "$dir/_claude-cli" ]] && [[ -f "$dir/_claude-app" ]]; then
      # Return absolute path
      (cd "$dir" && pwd)
      return 0
    fi
  done

  return 1
}

# ----------------------------------------------------------------------------
# Detect where to install
# ----------------------------------------------------------------------------

determine_completions_dir() {
  # Priority order:
  # 1. Oh-My-Zsh custom completions
  # 2. Oh-My-Zsh completions
  # 3. User's own completions directory
  # 4. System-wide (requires sudo)

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    # Oh-My-Zsh detected
    COMPLETIONS_DIR="$HOME/.oh-my-zsh/completions"
    SETUP_TYPE="oh-my-zsh"
  elif [[ -d "$HOME/.zsh/completions" ]]; then
    COMPLETIONS_DIR="$HOME/.zsh/completions"
    SETUP_TYPE="custom"
  else
    # Create user-local completions dir
    COMPLETIONS_DIR="$HOME/.zsh/completions"
    SETUP_TYPE="custom-new"
  fi
}

# ----------------------------------------------------------------------------
# Install completions via symlink
# ----------------------------------------------------------------------------

install_completions() {
  local source_dir="$1"

  # Create target directory if needed
  if [[ ! -d "$COMPLETIONS_DIR" ]]; then
    print_info "Creating directory: $COMPLETIONS_DIR"
    mkdir -p "$COMPLETIONS_DIR"
  fi

  # Install _claude-cli
  local target_cli="$COMPLETIONS_DIR/_claude-cli"
  if [[ -e "$target_cli" ]] || [[ -L "$target_cli" ]]; then
    rm -f "$target_cli"
  fi
  ln -s "$source_dir/_claude-cli" "$target_cli"
  print_success "Installed: $target_cli"

  # Install _claude-app
  local target_app="$COMPLETIONS_DIR/_claude-app"
  if [[ -e "$target_app" ]] || [[ -L "$target_app" ]]; then
    rm -f "$target_app"
  fi
  ln -s "$source_dir/_claude-app" "$target_app"
  print_success "Installed: $target_app"
}

# ----------------------------------------------------------------------------
# Configure .zshrc if needed (for non-Oh-My-Zsh setups)
# ----------------------------------------------------------------------------

update_zshrc_if_needed() {
  # Oh-My-Zsh already scans ~/.oh-my-zsh/completions automatically → no action needed
  if [[ "$SETUP_TYPE" == "oh-my-zsh" ]]; then
    return 0
  fi

  # For custom setups, we need fpath entry in .zshrc
  local zshrc="$HOME/.zshrc"
  local fpath_line="fpath=($COMPLETIONS_DIR \$fpath)"

  if grep -Fq "$COMPLETIONS_DIR" "$zshrc" 2>/dev/null; then
    print_info ".zshrc already configured for $COMPLETIONS_DIR"
    return 0
  fi

  print_info "Adding fpath entry to $zshrc"
  {
    echo ""
    echo "# Custom zsh completions (added by claude-profile-manager)"
    echo "$fpath_line"
    echo "autoload -U compinit && compinit"
  } >> "$zshrc"

  print_success "Updated $zshrc"
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

main() {
  print_info "Installing zsh completions for claude-cli and claude-app"
  echo ""

  # Find source files
  local source_dir
  if ! source_dir=$(find_completions_dir); then
    print_error "Completion files not found!"
    echo ""
    echo "Expected to find:"
    echo "  ./completions/_claude-cli"
    echo "  ./completions/_claude-app"
    echo ""
    echo "Make sure you're running from the repository root:"
    echo "  cd /path/to/claude-profile-manager"
    echo "  ./scripts/install-completions.sh"
    return 1
  fi
  print_info "Source directory: $source_dir"

  # Detect target
  determine_completions_dir
  print_info "Setup type:       $SETUP_TYPE"
  print_info "Target directory: $COMPLETIONS_DIR"
  echo ""

  # Install
  install_completions "$source_dir"
  echo ""

  # Configure .zshrc if needed
  update_zshrc_if_needed
  echo ""

  # Final instructions
  print_success "Installation complete!"
  echo ""
  print_info "To activate completions, reload your shell:"
  echo "    exec zsh"
  echo ""
  print_info "Then test with:"
  echo "    claude-cli <TAB>"
  echo "    claude-app <TAB>"
  echo ""

  # Oh-My-Zsh users may need to rebuild the completion cache
  if [[ "$SETUP_TYPE" == "oh-my-zsh" ]]; then
    print_warning "If completion doesn't work after 'exec zsh', try clearing the cache:"
    echo "    rm -f ~/.zcompdump* && exec zsh"
  fi
}

main "$@"
