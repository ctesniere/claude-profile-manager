# ============================================================================
# Profile Storage <-> macOS Library mapping
# ============================================================================
#
# Instead of deleting Claude.app's session/data folders on every switch, we
# swap symlinks. Each macOS Library location becomes a symlink pointing into
# the active profile's storage, e.g. for profile "kering":
#
#   ~/Library/Application Support/Claude          -> ~/.claude-kering/app/data
#   ~/Library/Caches/com.anthropic.claudefordesktop
#                                                 -> ~/.claude-kering/app/caches/com.anthropic.claudefordesktop
#   ~/Library/Caches/com.anthropic.claudefordesktop.ShipIt
#                                                 -> ~/.claude-kering/app/caches/com.anthropic.claudefordesktop.ShipIt
#   ~/Library/HTTPStorages/com.anthropic.claudefordesktop
#                                                 -> ~/.claude-kering/app/httpStorages/com.anthropic.claudefordesktop
#   ~/Library/Logs/Claude                         -> ~/.claude-kering/app/logs
#
# The map keys are profile-relative sub-paths (under ~/.claude-<profile>/app),
# the values are the absolute macOS Library paths that become symlinks.
#
# NOTE: "data" mirrors ~/Library/Application Support/Claude and is managed by
# the symlinks below. It must NOT be confused with CLAUDE_CONFIG_DIR, which
# gets its OWN separate folder ~/.claude-<profile>/app/config (created at
# launch, not part of this map).
#
# Shared by claude-app and claude-app-unlink — keep it in one place so the
# two commands can never drift out of sync.
#
# Expects HOME_DIR to be set. Not meant to be executed directly.
#
# ============================================================================

typeset -gA APP_STORAGE_MAP
APP_STORAGE_MAP=(
  "applicationsSupport/Claude"                    "$HOME_DIR/Library/Application Support/Claude"
  "applicationsSupport/Claude-3p"                 "$HOME_DIR/Library/Application Support/Claude-3p"
  "caches/com.anthropic.claudefordesktop"         "$HOME_DIR/Library/Caches/com.anthropic.claudefordesktop"
  "caches/com.anthropic.claudefordesktop.ShipIt"  "$HOME_DIR/Library/Caches/com.anthropic.claudefordesktop.ShipIt"
  "httpStorages/com.anthropic.claudefordesktop"   "$HOME_DIR/Library/HTTPStorages/com.anthropic.claudefordesktop"
  "logs/Claude"                                   "$HOME_DIR/Library/Logs/Claude"
  "logs/Claude-3p"                                "$HOME_DIR/Library/Logs/Claude-3p"
)
