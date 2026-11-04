#!/bin/zsh

# ============================================================================
# Uninstall Claude Scripts - Remove claude-cli and claude-app from PATH
# ============================================================================
#
# Usage:
#   ./scripts/uninstall-commands.sh
#   or
#   sudo ./scripts/uninstall-commands.sh  (for /usr/local/bin)
#
# This script removes:
#   - claude-cli    symlink (Launch Claude CLI with profile)
#   - claude-app    symlink (Launch Claude.app with profile)
#   - tab completion files (_claude-cli, _claude-app), optional
#
# It only removes the symlinks/completions created by install-commands.sh.
# The source scripts in ./commands/ are left untouched.
#
# ============================================================================

set -e

readonly SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/messages.sh"

# ============================================================================
# Candidate Installation Directories
# ============================================================================
#
# Mirror the locations that install-commands.sh may have used, so the
# uninstall works regardless of how the install was run.

candidate_install_dirs() {
  local -a dirs
  dirs=("/usr/local/bin" "$HOME/.local/bin" "$HOME/bin")
  printf '%s\n' "${dirs[@]}"
}

# ============================================================================
# Remove Command Symlinks
# ============================================================================

remove_symlinks() {
  print_header "Removing Claude Command Symlinks"

  local removed=0
  local cmd dir target

  for cmd in claude-cli claude-app; do
    for dir in $(candidate_install_dirs); do
      target="$dir/$cmd"

      # Only touch symlinks or regular files that exist
      if [[ -L "$target" ]] || [[ -e "$target" ]]; then
        # Guard against removing files we don't have permission for
        if rm -f "$target" 2>/dev/null; then
          print_success "Removed: $target"
          removed=$((removed + 1))
        else
          print_error "Could not remove: $target (try running with sudo)"
        fi
      fi
    done
  done

  if [[ $removed -eq 0 ]]; then
    print_warning "No claude-cli / claude-app symlinks found in known locations."
    echo "  Searched:"
    for dir in $(candidate_install_dirs); do
      echo "    - $dir"
    done
  fi
}

# ============================================================================
# Remove Tab Completion (Optional)
# ============================================================================

remove_completion() {
  print_header "Removing Tab Completion (Optional)"

  local -a completion_dirs
  completion_dirs=("${fpath[1]}" "$HOME/.zsh/completions")

  local removed=0
  local dir file

  for dir in "${completion_dirs[@]}"; do
    [[ -z "$dir" ]] && continue
    for file in _claude-cli _claude-app; do
      if [[ -e "$dir/$file" ]]; then
        if rm -f "$dir/$file" 2>/dev/null; then
          print_success "Removed: $dir/$file"
          removed=$((removed + 1))
        else
          print_error "Could not remove: $dir/$file (try running with sudo)"
        fi
      fi
    done
  done

  if [[ $removed -eq 0 ]]; then
    print_warning "No completion files found."
  else
    print_step "Reload your shell or run: exec zsh"
  fi
}

# ============================================================================
# Verification
# ============================================================================

verify_uninstall() {
  print_header "Verifying Uninstall"

  local still_present=0

  if command -v claude-cli &> /dev/null; then
    print_warning "claude-cli is still available at: $(which claude-cli)"
    still_present=1
  else
    print_success "claude-cli is no longer in PATH"
  fi

  if command -v claude-app &> /dev/null; then
    print_warning "claude-app is still available at: $(which claude-app)"
    still_present=1
  else
    print_success "claude-app is no longer in PATH"
  fi

  echo ""
  if [[ $still_present -eq 1 ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Some commands are still available ⚠️"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "They may have been installed elsewhere, or your shell has"
    echo "cached the command location. Try:"
    echo "  hash -r        # clear command cache"
    echo "  exec zsh       # reload shell"
    echo "  which -a claude-cli claude-app"
    echo ""
  else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Uninstall Complete! ✅"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "The source scripts in ./commands/ were left untouched."
    echo "To reinstall: ./scripts/install-commands.sh"
    echo ""
  fi
}

# ============================================================================
# Main
# ============================================================================

main() {
  print_header "Claude CLI/APP Uninstallation"

  echo "This script will remove:"
  echo "  • claude-cli    symlink"
  echo "  • claude-app    symlink"
  echo "  • tab completion files (optional)"
  echo ""
  echo "The source scripts in ./commands/ will NOT be deleted."
  echo ""

  read -q "?Continue? (y/n) " || return 0
  echo ""
  echo ""

  # Remove symlinks
  remove_symlinks

  # Optional: remove completion files
  echo ""
  read -q "?Remove tab completion files? (y/n) " && { echo ""; remove_completion; } || echo ""

  # Verify
  echo ""
  verify_uninstall
}

main "$@"
