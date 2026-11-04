# ============================================================================
# Profile config file discovery (KEY=VALUE format)
# ============================================================================
#
# Looks for a ".claude-profile-manager.conf" file, first in the current
# directory then in each parent directory up to (and including) $HOME, so a
# profile can be selected implicitly by placing this file in a project.
#
# File format is plain KEY=VALUE, one per line, comments (#) and blank lines
# ignored. No sourcing/eval of the file — parsed line by line so a config
# file coming from a cloned repo can't run arbitrary code.
#
#   profile=perso
#
# Expects HOME_DIR to be set. Not meant to be executed directly.
#
# ============================================================================

readonly CONFIG_FILENAME=".claude-profile-manager.conf"

# Searches $PWD and its parents up to $HOME_DIR (inclusive) for
# $CONFIG_FILENAME. Prints the found path on stdout.
find_profile_config() {
  local dir="$PWD"

  while true; do
    # echo "$dir/$CONFIG_FILENAME"
    if [[ -f "$dir/$CONFIG_FILENAME" ]]; then
      echo "$dir/$CONFIG_FILENAME"
      return 0
    fi

    [[ "$dir" == "$HOME_DIR" || "$dir" == "/" ]] && break
    dir="${dir:h}"
  done

  return 1
}

# Reads the value for key $2 out of the KEY=VALUE file $1.
get_config_value() {
  local config_file="$1" key="$2"
  local line k v

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    k="${line%%=*}"
    v="${line#*=}"
    if [[ "$k" == "$key" ]]; then
      v="${v#\"}"; v="${v%\"}"
      v="${v#\'}"; v="${v%\'}"
      echo "$v"
      return 0
    fi
  done < "$config_file"

  return 1
}
