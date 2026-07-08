# ============================================================================
# Shared print helpers for install-commands.sh / uninstall-commands.sh
# ============================================================================
# Requires lib/colors.sh to be sourced first. Not meant to be executed
# directly.
# ============================================================================

print_header() {
  echo ""
  echo -e "${BLUE}════════════════════════════════════════${NC}"
  echo -e "$1"
  echo -e "${BLUE}════════════════════════════════════════${NC}"
  echo ""
}

print_step() {
  echo -e "${BLUE}▶▶▶${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️ $1${NC}"
}

print_info() {
  echo -e "ℹ️  $*"
}
