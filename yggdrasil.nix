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
  show_help() {
    cat << EOF
    ''${TREE} Yggdrasil - Cross-platform Nix Configuration Manager

    USAGE:
      yggdrasil <command> [arguments]

    COMMANDS:
      build <hostname>        ''${BUILD} Build configuration for hostname
      switch <hostname>       ''${SUCCESS} Switch to hostname configuration (NixOS/Darwin)
      install <hostname>      ''${INFO} Install NixOS with hostname config
      boot <hostname>         ''${INFO} Set hostname config for next boot (NixOS only)
      home <config>           ''${HOME} Switch home-manager configuration
      update                  ''${UPDATE} Update flake inputs
      list                    ''${LIST} List available configurations
      create <type> <name>    Crete new configuration from template
      clone <source> <target> Clone existing configuration to new name

    AVAILABLE HOSTS:
      NixOS:      fenrir, jormungandr
      Darwin:     hel
      Home:       wyatt@linux, wyatt@darwin

    EXAMPLES:
      yggdrasil build fenrir
      yggdrasil switch hel
      yggdrasil home wyatt@linux
      yggdrasil install jormungandr
      yggdrasil create nixos server1
      yggdrasil creat darwin macbook-pro

    REMOTE USAGE:
      nix run github:wyfyjohnson/yggdrasil -- build fenrir
    EOF
  }

  list_configs() {
    log_header "Available configurations:"
    echo " ''${INFO} NixOS systems:"
    echo "    - fenrir"
    echo "    - jormungandr"
    echo " ''${INFO} Darwin systems:"
    echo "    - hel"
    echo " ''${HOME} Home configurations:"
    echo "    - wyatt@linux"
    echo "    - wyatt@darwin"
  }

  validate_nixos_host() {
    local hostname="$1"
    case "$hostname" in
    fenrir|jormungandr)
      return 0
      ;;
      *)
        log_error "Unknown NixOS host: $hostname"
        echo "Available: fenrir, jormungandr"
        exit 1
        ;;
      esac
  }

  validate_darwin_host() {
    local hostname="$1"
    case "$hostname" in
    hel)
      return 0
      ;;
    *)
      log_error "Unknown Darwin host: $hostname"
      echo "Available: hel"
      exit 1
      ;;
    esac
  }

  validate_home_config() {
    local config="$1"
    case "$config" in
      wyatt@linux|wyatt@darwin)
        return 0
        ;;
  }
''
