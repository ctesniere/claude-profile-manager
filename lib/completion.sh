# ============================================================================
# Shared zsh completion logic for claude-app / claude-cli
# ============================================================================
# Sourced by completions/_claude-app and completions/_claude-cli. Not meant
# to be executed directly.
#
# The completion auto-discovers profiles from ~/.claude-*/ directories.
# New profiles are picked up automatically on next completion (no reload
# needed).
# ============================================================================

# $1 = label shown next to each candidate, e.g. "Claude.app profile"
_claude_profile_candidates() {
  local label="$1"
  local -a profiles
  local profile_dir profile_name

  for profile_dir in "$HOME"/.claude-*/; do
    # Skip if no match (nullglob-style safety)
    [[ -d "$profile_dir" ]] || continue

    # Extract profile name from path (e.g., ~/.claude-perso -> perso)
    profile_name="${profile_dir##*/.claude-}"
    profile_name="${profile_name%/}"

    [[ "$profile_name" == "shared" ]] && continue

    profiles+=("$profile_name:$label")
  done

  if (( ${#profiles[@]} > 0 )); then
    _describe -t profiles "$label" profiles
  else
    _message 'no profiles found (create with: mkdir ~/.claude-<name>)'
  fi
}
