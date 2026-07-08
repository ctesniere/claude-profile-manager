# ============================================================================
# Shared profile discovery/validation for the claude-cli / claude-app commands
# ============================================================================
# Requires lib/messages.sh to be sourced first (uses print_error/print_info).
# Expects HOME_DIR to be set. Not meant to be executed directly.
# ============================================================================

discover_profiles() {
  local profiles=()
  local profile_dir

  for profile_dir in "$HOME_DIR"/.claude-*/; do
    # Extract profile name from path (e.g., ~/.claude-perso -> perso)
    profiles+=("${profile_dir##*/\.claude-}")
  done

  if [[ ${#profiles[@]} -eq 0 ]]; then
    print_error "No profiles found. Create ~/.claude-{name} directories first."
    return 1
  fi

  printf '%s\n' "${profiles[@]}" | sort
  return 0
}

validate_profile() {
  local profile="$1"
  local profile_dir="$HOME_DIR/.claude-$profile"

  # Check if directory exists
  if [[ ! -d "$profile_dir" ]]; then
    print_error "Profile directory not found: $profile_dir"
    print_info "Available profiles:"
    discover_profiles | sed 's/^/  - /'
    return 1
  fi

  return 0
}
