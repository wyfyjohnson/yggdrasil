{
  lib,
  stdenv,
  writeShellScriptBin,
  makeWrapper,
  # Dependencies
  jq,
  nix,
  nh,
}:
writeShellScriptBin "yggdrasil" ''
#!${stdenv.shell}
# yggdrasil - Utility script for managing Yggdrasil
# wrapper around 'nh' (yet another nix helper) with additional functionality                    
  set -euo pipefail

  export PATH="${lib.makeBinPath [jq nix nh]}:$PATH"

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
# Detect platform
  detect_platform() {
      if [[ "$OSTYPE" == "darwin"* ]]; then
          echo "darwin"
      elif [[ -f /etc/NIXOS ]] || [[ -f /run/current-system/nixos-version ]] || [[ -f /etc/nixos/configuration.nix ]]; then
          echo "nixos"
      else
          echo "standalone"
      fi
  }

  # Get available configurations
  get_nixos_configs() {
      if [[ -f flake.nix ]]; then
          local output
          if output=$(nix flake show --json 2>/dev/null); then
              echo "$output" | jq -r '.nixosConfigurations | keys[]?' 2>/dev/null || true
          fi
      fi
  }

  get_darwin_configs() {
      if [[ -f flake.nix ]]; then
          local output
          if output=$(nix flake show --json 2>/dev/null); then
              echo "$output" | jq -r '.darwinConfigurations | keys[]?' 2>/dev/null || true
          fi
      fi
  }

  get_home_configs() {
      if [[ -f flake.nix ]]; then
          local output
          if output=$(nix flake show --json 2>/dev/null); then
              echo "$output" | jq -r '.homeConfigurations | keys[]?' 2>/dev/null || true
          fi
      fi
  }

  # Build and switch functions using nh
  rebuild_nixos() {
      local config=''${1:-}
      local action=''${2:-switch}
      
      if [[ -z "$config" ]]; then
          log_error "No configuration specified"
          log_info "Available NixOS configurations:"
          get_nixos_configs | sed 's/^/  - /'
          exit 1
      fi
      
      log_info "Building NixOS configuration: $config (action: $action)"
      
      if nh os "$action" ".#$config"; then
          log_success "NixOS configuration applied successfully"
      else
          log_error "Failed to rebuild NixOS configuration"
          exit 1
      fi
  }

  rebuild_darwin() {
      local config=''${1:-}
      local action=''${2:-switch}
      
      if [[ -z "$config" ]]; then
          log_error "No configuration specified"
          log_info "Available Darwin configurations:"
          get_darwin_configs | sed 's/^/  - /'
          exit 1
      fi
      
      log_info "Building Darwin configuration: $config (action: $action)"
      
      if nh darwin "$action" ".#$config"; then
          log_success "Darwin configuration applied successfully"
      else
          log_error "Failed to rebuild Darwin configuration"
          exit 1
      fi
  }

  rebuild_home() {
      local config=''${1:-}
      local action=''${2:-switch}
      
      if [[ -z "$config" ]]; then
          log_error "No configuration specified"
          log_info "Available Home Manager configurations:"
          get_home_configs | sed 's/^/  - /'
          exit 1
      fi
      
      log_info "Building Home Manager configuration: $config (action: $action)"
      
      if nh home "$action" ".#$config"; then
          log_success "Home Manager configuration applied successfully"
      else
          log_error "Failed to rebuild Home Manager configuration"
          exit 1
      fi
  }

  # Utility functions
  update_flake() {
      log_info "Updating flake inputs using nh..."
      local platform=$(detect_platform)
      case $platform in
          nixos)
              nh os switch --update .
              ;;
          darwin)
              nh darwin switch --update .
              ;;
          standalone)
              log_info "Updating flake inputs..."
              nix flake update
              ;;
      esac
  }

  check_flake() {
      log_info "Checking flake configuration..."
      if nix flake check; then
          log_success "Flake configuration is valid"
      else
          log_error "Flake configuration has errors"
          exit 1
      fi
  }

  format_code() {
      log_info "Formatting Nix files..."
      if command -v nixpkgs-fmt &> /dev/null; then
          find . -name "*.nix" -exec nixpkgs-fmt {} \;
          log_success "Code formatted"
      elif command -v alejandra &> /dev/null; then
          find . -name "*.nix" -exec alejandra {} \;
          log_success "Code formatted with alejandra"
      else
          log_warn "No formatter found (nixpkgs-fmt or alejandra)"
      fi
  }

  cleanup_generations() {
      local days=''${1:-7}
      
      if ! [[ "$days" =~ ^[0-9]+$ ]]; then
          log_error "Days must be a positive number"
          exit 1
      fi
      
      log_info "Cleaning up using nh (keeping last $days days)..."
      local platform=$(detect_platform)
      case $platform in
          nixos|darwin)
              nh clean all --keep $days
              ;;
          standalone)
              nh clean user --keep $days
              ;;
      esac
      log_success "Cleanup completed"
  }

  optimize_store() {
      log_info "Optimizing Nix store..."
      if nix-store --optimise; then
          log_success "Store optimized"
      else
          log_error "Failed to optimize store"
          exit 1
      fi
  }

  list_generations() {
      local platform=$(detect_platform)
      
      log_info "Listing system generations..."
      case $platform in
          nixos)
              nix-env --list-generations --profile /nix/var/nix/profiles/system
              ;;
          darwin)
              nix-env --list-generations --profile /nix/var/nix/profiles/system
              ;;
          standalone)
              nix-env --list-generations
              ;;
      esac
  }

  rollback_generation() {
      local generation=''${1:-}
      local platform=$(detect_platform)
      
      log_info "Rolling back to previous generation..."
      
      case $platform in
          nixos)
              if [[ -n "$generation" ]]; then
                  sudo nixos-rebuild switch --rollback --flake ".#$generation"
              else
                  sudo nixos-rebuild switch --rollback
              fi
              ;;
          darwin)
              if [[ -n "$generation" ]]; then
                  darwin-rebuild switch --rollback --flake ".#$generation"
              else
                  darwin-rebuild switch --rollback
              fi
              ;;
          standalone)
              log_error "Rollback not directly supported for standalone home-manager"
              exit 1
              ;;
      esac
      log_success "Rolled back successfully"
  }

  # Portable sed function
  portable_sed() {
      local pattern="$1"
      local file="$2"
      
      if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i ' ' "$pattern" "$file"
      else
          sed -i "$pattern" "$file"
      fi
  }

  create_host() {
      local hostname=''${1:-}
      local platform=''${2:-nixos}
      
      if [[ -z "$hostname" ]]; then
          log_error "Hostname required"
          echo "Usage: yggdrasil create-host <hostname> [nixos|darwin]"
          exit 1
      fi
      
      if [[ -d "host/$hostname" ]]; then
          log_error "Host $hostname already exists"
          exit 1
      fi
      
      log_info "Creating new host: $hostname ($platform)"
      
      mkdir -p "host/$hostname"
      
      case $platform in
          nixos)
              cat > "host/$hostname/configuration.nix" << 'HOSTEOF'
  { config, pkgs, lib, ... }:

  {
    imports = [
      ./hardware-configuration.nix
      ../../modules/common/users.nix
      ../../modules/nixos/desktop.nix
      ../../modules/nixos/fonts.nix
      ../../modules/nixos/locale.nix
    ];

    networking.hostName = "HOSTNAME";
    
    system.stateVersion = "25.05";
    nixpkgs.config.allowUnfree = true;
    
    nix.settings.experimental-features = ["nix-command" "flakes"];
  }
  HOSTEOF
              portable_sed "s/HOSTNAME/$hostname/g" "host/$hostname/configuration.nix"
              log_info "Don't forget to:"
              log_info "  1. Generate hardware-configuration.nix"
              log_info "  2. Add $hostname to flake.nix"
              ;;
          darwin)
              cat > "host/$hostname/configuration.nix" << 'HOSTEOF'
  { config, pkgs, lib, ... }:

  {
    imports = [
      ../../modules/darwin/system.nix
      ../../modules/darwin/fonts.nix
      ../../modules/darwin/locale.nix
    ];

    networking.hostName = "HOSTNAME";
    
    system.stateVersion = 5;
    nix.settings.experimental-features = ["nix-command" "flakes"];
  }
  HOSTEOF
              portable_sed "s/HOSTNAME/$hostname/g" "host/$hostname/configuration.nix"
              log_info "Don't forget to add $hostname to flake.nix"
              ;;
          *)
              log_error "Unknown platform: $platform"
              exit 1
              ;;
      esac
      
      log_success "Host $hostname created successfully"
  }

  search_packages() {
      local query=''${1:-}
      
      if [[ -z "$query" ]]; then
          log_error "Search query required"
          exit 1
      fi
      
      log_info "Searching packages with nh..."
      nh search "$query"
  }

  show_status() {
      local platform=$(detect_platform)
      
      log_header "Yggdrasil Configuration Status"
      echo
      
      log_info "Platform: $platform"
      log_info "Flake location: $(pwd)"
      
      if [[ -f flake.lock ]]; then
          log_info "Last flake update: $(stat -c %y flake.lock 2>/dev/null || stat -f %Sm -t %Y-%m-%d flake.lock 2>/dev/null || echo 'Unknown')"
      fi
      
      echo
      log_info "Available configurations:"
      
      local nixos_configs=$(get_nixos_configs)
      if [[ -n "$nixos_configs" ]]; then
          echo "  NixOS:"
          echo "$nixos_configs" | sed 's/^/    - /'
      fi
      
      local darwin_configs=$(get_darwin_configs)
      if [[ -n "$darwin_configs" ]]; then
          echo "  Darwin:"
          echo "$darwin_configs" | sed 's/^/    - /'
      fi
      
      local home_configs=$(get_home_configs)
      if [[ -n "$home_configs" ]]; then
          echo "  Home Manager:"
          echo "$home_configs" | sed 's/^/    - /'
      fi
  }

  show_help() {
      cat << 'HELPEOF'
  🌳 Yggdrasil - Universal Nix Configuration Manager
     Powered by nh (yet another nix helper)

  Usage: yggdrasil [command] [options]

  Build Commands:
    build <config> [test|switch|boot]  Build and switch configuration
    update                             Update flake and rebuild
    rollback [generation]              Rollback to previous generation
    
  Maintenance Commands:
    cleanup [days]                     Remove old generations (default: 7 days)
    optimize                           Optimize Nix store
    list                               List system generations
    
  Utility Commands:
    search <query>                     Search for packages
    check                              Check flake configuration
    format                             Format Nix code
    status                             Show configuration status
    
  Yggdrasil-Specific Commands:
    create-host <name> [platform]      Create new host configuration
    help                               Show this help message

  Examples:
    yggdrasil build fenrir             Build and switch to fenrir
    yggdrasil build hel test           Build hel configuration for testing
    yggdrasil update                   Update flake inputs and rebuild
    yggdrasil cleanup 14               Remove generations older than 14 days
    yggdrasil rollback                 Rollback to previous generation
    yggdrasil search firefox           Search for firefox package
    yggdrasil create-host server nixos Create new NixOS host

  HELPEOF
  }

  # Main command dispatcher
  main() {
      local command=''${1:-help}
      
      case $command in
          build)
              local config=''${2:-}
              local action=''${3:-switch}
              local platform=$(detect_platform)
              
              case $platform in
                  nixos)
                      rebuild_nixos "$config" "$action"
                      ;;
                  darwin)
                      rebuild_darwin "$config" "$action"
                      ;;
                  standalone)
                      rebuild_home "$config" "$action"
                      ;;
              esac
              ;;
          update)
              update_flake
              ;;
          check)
              check_flake
              ;;
          format)
              format_code
              ;;
          cleanup)
              cleanup_generations ''${2:-7}
              ;;
          optimize)
              optimize_store
              ;;
          list|generations)
              list_generations
              ;;
          rollback)
              rollback_generation "$2"
              ;;
          search)
              search_packages "$2"
              ;;
          create-host)
              create_host "$2" "''${3:-nixos}"
              ;;
          status)
              show_status
              ;;
          help|--help|-h)
              show_help
              ;;
          *)
              log_error "Unknown command: $command"
              show_help
              exit 1
              ;;
      esac
  }

  # Check if we're in the right directory
  if [[ ! -f flake.nix ]]; then
      log_error "No flake.nix found in current directory"
      log_info "Please run this script from your Yggdrasil configuration directory"
      exit 1
  fi

  # Run main function with all arguments
  main "$@"
''
