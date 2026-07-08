# ============================================================================
# Shared print helpers for install-completions.sh / uninstall-completions.sh
# ============================================================================
# Requires lib/colors.sh to be sourced first. Not meant to be executed
# directly.
# ============================================================================

print_info()    { printf "${BLUE}ℹ️  %s${NC}\n" "$*"; }
print_success() { printf "${GREEN}✅ %s${NC}\n" "$*"; }
print_warning() { printf "${YELLOW}⚠️  %s${NC}\n" "$*"; }
print_error()   { printf "${RED}❌ %s${NC}\n" "$*" >&2; }
