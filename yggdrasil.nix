{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellScriptBin "yggdrasil" ''
  set -euo pipefail

  # Catpuccin Mocha error colors
  RED='\033[38;2;243;139;168m'
  YELLOW='\033[38;2;249;226;175m'
  GREEN='\033[38;2;166;227;161m'
  BLUE='\033[38;2;137;180;250m'
  MAUVE='\033[38;2;203;166;247m'
  NC='\033[0m'

  # NF Icons
  TREE=""
  SUCCESS=""
  ERROR=""
  INFO="󰈙"
  WARNING=""
  BUILD="󱌢"
  UPDATE="󱍸"
  LIST="󱃔"
  HOME="󱅚"

  # Helper Functions
  log_info() {
    echo -e " ''${BLUE}''${INFO} ''${1}''${NC}"
  }
  log_success() {
    echo -e " ''${GREEN}''${SUCCESS} ''${1}''${NC}"
  }
  log_warn() {
    echo -e " ''${YELLOW}''${WARNING} ''${1}''${NC}"
  }
  log_error() {
    echo -e " ''${RED}''${ERROR} ''${1}''${NC}"
  }
  log_header(){
    echo -e " ''${MAUVE}''${TREE} ''${1}''${NC}"
  }

  check_flake_dir() {
   if [[ ! -f flake.nix ]]; then
     log_error "No flake.nix found in current directory"
     log_info "Please run this from the Yggdrasil configuration directory"
     exit 1
   fi
  }

  # Discover all host configurations from the host/ directory
  discover_hosts() {
    local host_dir="./host"
    if [[ ! -d "$host_dir" ]]; then
      echo ""
      return
    fi

    find "$host_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  }

  # Discover home configurations from flake.nix
  discover_home_configs() {
    if [[ ! -f flake.nix ]]; then
      echo ""
      return
    fi

    # Extract home configurations from flake.nix
    # look for homeConfigurations entries
    grep -oP 'homeConfigurations\.\K[^"=\s]+' flake.nix 2>/dev/null | sort -u || echo ""
  }

  # Detect platform type from configuration file
  detect_platform() {
    local hostname ="$1"
    local config_file="./host/$hostname/configuration.nix"

    if [[ ! -f "$config_file" ]]; then
      # Infer from flake.nix
      if grep -q "nixosConfigurations.*['\"]" flake.nix 2>/dev/null; then
        echo "nixos"
      elif grep -q "darwinConfigurations.*['\"]" flake.nix 2>/dev/null; then
        echo "darwin"
      else
        echo "unknown"
      fi
      return
    fi

    # Check configuration file for platform indicators
    if grep -qE 'darwin|nix-darwin' "$config_file" 2>/dev/null; then
      echo "darwin"
    elif grep -qE 'nixos|system\.stateVersion' "$config_file" 2>/dev/null; then
      echo "nixos"
    else
      echo "unknown"
    fi
  }

  # Validate that a host exists
  validate_host() {
    local hostname="$1"
    local available_hosts
    available_hosts=$(discover_hosts)

    if [[ -z "$available_hosts" ]]; then
      log_error "No host configurations found in ./host/"
      exit 1
    fi

    if ! echo "$available_hosts" | grep -qx "$hostname"; then
      log_error "Unknown host: $hostname"
      echo ""
      echo "Available hosts:"
      echo "$available_hosts" | sed 's/^/ -/'
      exit 1
    fi
  }

  # Validate home configuration
  validate_home_config() {
    local config="$1"
    local available_configs
    available_configs=$(discover_home_configs)

    if [[ -z "$available_configs" ]]; then
      log_error "No home configurations found in flake.nix"
      exit 1
    fi

    if
  }
''
