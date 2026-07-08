#!/bin/zsh

# ============================================================================
# Uninstall zsh completions for claude-cli and claude-app
# ============================================================================
#
# Removes the completion files installed by install-completions.sh and,
# optionally, the fpath block it added to your ~/.zshrc.
#
# Usage:
#   ./scripts/uninstall-completions.sh
#
# Only the completion symlinks/files and the block marked
# "added by claude-profile-manager" are touched. The source files in
# ./completions/ are left untouched.
#
# ============================================================================

set -e

readonly SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/completions-install-output.sh"

# ----------------------------------------------------------------------------
# Candidate completion directories
# ----------------------------------------------------------------------------
#
# Mirror the locations install-completions.sh may have used, so the uninstall
# works regardless of the detected setup type.

candidate_completion_dirs() {
  local -a dirs
  dirs=(
    "$HOME/.oh-my-zsh/completions"
    "$HOME/.zsh/completions"
  )
  # Include the current fpath front entry if set (custom setups)
  [[ -n "${fpath[1]}" ]] && dirs+=("${fpath[1]}")
  printf '%s\n' "${dirs[@]}"
}

# ----------------------------------------------------------------------------
# Remove completion files
# ----------------------------------------------------------------------------

remove_completions() {
  print_info "Removing completion files for claude-cli and claude-app"
  echo ""

  local removed=0
  local dir file target
  local -a seen

  for dir in $(candidate_completion_dirs); do
    [[ -z "$dir" ]] && continue

    # Skip duplicates
    if [[ " ${seen[*]} " == *" $dir "* ]]; then
      continue
    fi
    seen+=("$dir")

    for file in _claude-cli _claude-app; do
      target="$dir/$file"
      if [[ -L "$target" ]] || [[ -e "$target" ]]; then
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
    print_warning "No completion files found in known locations:"
    for dir in $(candidate_completion_dirs); do
      [[ -n "$dir" ]] && echo "    - $dir"
    done
  fi
}

# ----------------------------------------------------------------------------
# Remove the .zshrc block added by install-completions.sh (optional)
# ----------------------------------------------------------------------------

remove_zshrc_block() {
  local zshrc="$HOME/.zshrc"
  local marker="# Custom zsh completions (added by claude-profile-manager)"

  if [[ ! -f "$zshrc" ]]; then
    print_info "No ~/.zshrc found — nothing to clean."
    return 0
  fi

  if ! grep -Fq "$marker" "$zshrc"; then
    print_info "No claude-profile-manager block found in ~/.zshrc."
    return 0
  fi

  echo ""
  read -q "?Remove the claude-profile-manager block from ~/.zshrc? (y/n) " || { echo ""; return 0; }
  echo ""

  # Back up before editing
  local backup="$zshrc.bak.claude-profile-manager"
  cp "$zshrc" "$backup"
  print_info "Backup saved: $backup"

  # Remove the marker line plus the two lines the installer appended after it:
  #   fpath=(... $fpath)
  #   autoload -U compinit && compinit
  awk -v marker="$marker" '
    index($0, marker) { skip = 3 }   # marker + fpath line + autoload line
    skip > 0          { skip--; next }
                      { print }
  ' "$zshrc" > "$zshrc.tmp"

  mv "$zshrc.tmp" "$zshrc"
  print_success "Cleaned ~/.zshrc"
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

main() {
  print_info "Uninstalling zsh completions for claude-cli and claude-app"
  echo ""
  echo "This will remove:"
  echo "  • completion files (_claude-cli, _claude-app)"
  echo "  • the fpath block added to ~/.zshrc (optional)"
  echo ""
  echo "The source files in ./completions/ will NOT be deleted."
  echo ""

  read -q "?Continue? (y/n) " || return 0
  echo ""
  echo ""

  # Remove completion files
  remove_completions

  # Optionally clean up .zshrc
  remove_zshrc_block
  echo ""

  # Final instructions
  print_success "Uninstall complete!"
  echo ""
  print_info "Reload your shell to apply changes:"
  echo "    exec zsh"
  echo ""

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_warning "If completion is still offered after 'exec zsh', clear the cache:"
    echo "    rm -f ~/.zcompdump* && exec zsh"
  fi
}

main "$@"
