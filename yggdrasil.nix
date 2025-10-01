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
      *)
        log_error "Unknown home configuration: $config"
        echo "Available: wyatt@linux, wyatt@darwin"
        exit 1
        ;;
   esac
  }

  detect_platform() {
    local hostname="$1"
    if [[ -d "./host/$hostname" ]]; then
      # Check if it's a Darwin or NixOS config by looking at the configuration
      if grep -q "nix-darwin\|darwin" "./host/$hostname/configuration.nix" 2>/dev/null; then
        echo "darwin"
      else
        echo "nixos"
      fi
    else
      case "$hostname" in
        fenrir|jormungandr) echo "nixos" ;;
        hel) echo "darwin" ;;
        *) echo "unknown" ;;
      esac
    fi
  }

  build_config() {
    local hostname="$1"
    shift
    log_header "Building configuration for: $hostname"

    local platform=$(detect_platform "$hostname")
    case "$platform" in
      nixos)
        validate_nixos_host "$hostname"
        if nixos-rebuild build --flake ".#$hostname" "$@"; then
          log_success "Built NixOS configuration: $hostname"
        else
          log_error "Failed to build NixOS configuration: $hostname"
          exit 1
        fi
        ;;
      darwin)
        validate_darwin_host "$hostname"
        if darwin-rebuild build --flake ".#$hostname" "$@"; then
          log_success "Built Darwin configuration: $hostname"
        else
          log_error "Failed to build Darwin configuration: $hostname"
          exit 1
        fi
        ;;
      *)
        log_error "Unknown platform for host: $hostname"
        exit 1
        ;;
    esac
  }

  switch_config() {
    local hostname="$1"
    shift
    log_header "Switching to configuration: $hostname"

    local platform=$(detect_platform "$hostname")
    case "$platform" in
      nixos)
        validate_nixos_host "$hostname"
        if sudo nixos-rebuild switch --flake ".#$hostname" "$@"; then
          log_success "Switched to NixOS configuration: $hostname"
        else
          log_error "Failed to switch NixOS configuration: $hostname"
          exit 1
        fi
        ;;
      darwin)
        validate_darwin_host "$hostname"
        if darwin-rebuild switch --flake ".#$hostname" "$@"; then
          log_success "Switched to Darwin configuration: $hostname"
        else
          log_error "Failed to switch Darwin configuration: $hostname"
          exit 1
        fi
        ;;
      *)
        log_error "Unknown platform for host: $hostname"
        exit 1
        ;;
    esac
  }

  boot_config() {
    local hostname="$1"
    shift
    log_header "Setting boot configuration: $hostname"
    validate_nixos_host "$hostname"

    if sudo nixos-rebuild boot --flake ".#$hostname" "$@"; then
      log_success "Set boot configuration: $hostname"
    else
      log_error "Failed to set boot configuration: $hostname"
      exit 1
    fi
  }

  install_system() {
    local hostname="$1"
    shift
    log_header "Installing NixOS for: $hostname"
    validate_nixos_host "$hostname"

    if sudo nixos-install --flake ".#$hostname" "$@"; then
      log_success "Installed NixOS: $hostname"
    else
      log_error "Failed to install NixOS: $hostname"
      exit 1
    fi
  }

  switch_home() {
    local config="$1"
    shift
    log_header "Switching home configuration: $config"
    validate_home_config "$config"

    if home-manager switch --flake ".#$config" "$@"; then
      log_success "Switched to home configuration: $config"
    else
      log_error "Failed to switch home configuration: $config"
      exit 1
    fi
  }

  update_flake() {
    log_header "Updating flake inputs..."
    if nix flake update; then
      log_success "Flake inputs updated"
    else
      log_error "Failed to update flake inputs"
      exit 1
    fi
  }

  check_flake() {
    log_header "Checking flake configuration..."
    if nix flake check; then
      log_success "Flake configuration is valid"
    else
      log_error "Flake configuration has errors"
      exit 1
    fi
  }

  format_code() {
    log_header "Formatting Nix files..."
    if command -v alejandra &> /dev/null; then
      find . -name "*.nix" -exec alejandra {} \;
      log_success "Code formatted with alejandra"
    elif command -v nixpkgs-fmt &> /dev/null; then
      find . -name "*.nix" -exec nixpkgs-fmt {} \;
      log_success "Code formatted with nixpkgs-fmt"
    else
      log_warn "No Nix formatter found (alejandra or nixpkgs-fmt)"
      log_info "Install a formatter: nix profile install nixpkgs#alejandra"
    fi
  }

  cleanup_generations() {
    local days=${1:-7}

    # Validate input
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
      log_error "Days must be a positive number"
      exit 1
    fi

    log_header "Cleaning up generations older than $days days..."

    # Detect platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      if nix-collect-garbage -d --delete-older-than "${days}d"; then
        log_success "Cleaned up Nix store"
      else
        log_error "Failed to clean up Nix store"
        exit 1
      fi
    elif [[ -f /etc/NIXOS ]] || [[ -f /run/current-system/nixos-version ]]; then
      # NixOS
      if sudo nix-collect-garbage -d --delete-older-than "${days}d"; then
        log_success "Cleaned up Nix store"
      else
        log_error "Failed to clean up Nix store"
        exit 1
      fi
    else
      # Standalone
      if nix-collect-garbage -d --delete-older-than "${days}d"; then
        log_success "Cleaned up Nix store"
      else
        log_error "Failed to clean up Nix store"
        exit 1
      fi
    fi

    # Clean up home-manager generations if available
    if command -v home-manager &> /dev/null; then
      if home-manager expire-generations "$days days" 2>/dev/null; then
        log_success "Cleaned up home-manager generations"
      else
        log_warn "Could not clean up home-manager generations"
      fi
    fi
  }

  optimize_store() {
    log_header "Optimizing Nix store..."
    if nix-store --optimise; then
      log_success "Nix store optimized"
    else
      log_error "Failed to optimize Nix store"
      exit 1
    fi
  }

  create_nixos_config() {
    local hostname="$1"

    log_header "Creating NixOS configuration: $hostname"

    if [[ -d "./host/$hostname" ]]; then
      log_error "Configuration $hostname already exists"
      exit 1
    fi

    if [[ ! -f "./templates/nixos-host/configuration.nix" ]]; then
      log_error "Template file ./templates/nixos-host/configuration.nix not found"
      log_info "Please create the templates directory structure first"
      exit 1
    fi

    mkdir -p "./host/$hostname"

    # Copy template and replace hostname placeholder
    cp "./templates/nixos-host/configuration.nix" "./host/$hostname/"
    sed -i "s/your-hostname/$hostname/g" "./host/$hostname/configuration.nix"

    # Copy any additional template files if they exist
    if [[ -f "./templates/nixos-host/hardware-configuration.nix" ]]; then
      cp "./templates/nixos-host/hardware-configuration.nix" "./host/$hostname/"
    fi

    log_success "Created NixOS configuration for $hostname"
    log_info "Don't forget to:"
    echo "  1. Generate hardware-configuration.nix: nixos-generate-config --dir ./host/$hostname"
    echo "  2. Add $hostname to flake.nix nixosConfigurations:"
    echo "     $hostname = mkNixosSystem { system = \"x86_64-linux\"; hostname = \"$hostname\"; };"
  }

  create_darwin_config() {
    local hostname="$1"

    log_header "Creating Darwin configuration: $hostname"

    if [[ -d "./host/$hostname" ]]; then
      log_error "Configuration $hostname already exists"
      exit 1
    fi

    if [[ ! -f "./templates/darwin-host/configuration.nix" ]]; then
      log_error "Template file ./templates/darwin-host/configuration.nix not found"
      log_info "Please create the templates directory structure first"
      exit 1
    fi

    mkdir -p "./host/$hostname"

    # Copy template and replace hostname placeholder
    cp "./templates/darwin-host/configuration.nix" "./host/$hostname/"
    sed -i "s/your-hostname/$hostname/g" "./host/$hostname/configuration.nix"

    log_success "Created Darwin configuration for $hostname"
    log_info "Don't forget to:"
    echo "  1. Add $hostname to flake.nix darwinConfigurations:"
    echo "     $hostname = mkDarwinSystem { system = \"aarch64-darwin\"; hostname = \"$hostname\"; };"
  }

  clone_config() {
    local source="$1"
    local target="$2"

    log_header "Cloning configuration: $source → $target"

    if [[ ! -d "./host/$source" ]]; then
      log_error "Source configuration $source does not exist"
      exit 1
    fi

    if [[ -d "./host/$target" ]]; then
      log_error "Target configuration $target already exists"
      exit 1
    fi

    # Copy the entire directory
    cp -r "./host/$source" "./host/$target"

    # Update hostname in configuration.nix if it exists
    if [[ -f "./host/$target/configuration.nix" ]]; then
      # Replace old hostname with new one
      sed -i "s/hostName = \"$source\"/hostName = \"$target\"/g" "./host/$target/configuration.nix"
      # Also handle any other references to the old hostname
      sed -i "s/$source/$target/g" "./host/$target/configuration.nix"
    fi

    log_success "Cloned $source to $target"
    log_info "Don't forget to:"
    echo "  1. Update any host-specific settings in ./host/$target/configuration.nix"
    echo "  2. Generate new hardware-configuration.nix if needed"
    echo "  3. Add $target to flake.nix configurations"
  }
  check_flake_dir() {
    if [[ ! -f flake.nix ]]; then
      log_error "No flake.nix found in current directory"
      log_info "Please run this script from your Yggdrasil configuration directory"
      exit 1
    fi
  }

  # Main command parsing
  main() {
    # Check if in correct directory first
    check_flake_dir

    case "''${1:-help}" in
      build)
        shift
        [[ $# -eq 0 ]] && { log_error "Please specify a hostname"; show_help; exit 1; }
        build_config "$@"
        ;;
      switch)
        shift
        [[ $# -eq 0 ]] && { log_error "Please specify a hostname"; show_help; exit 1; }
        switch_config "$@"
        ;;
      boot)
        shift
        [[ $# -eq 0 ]] && { log_error "Please specify a hostname"; show_help; exit 1; }
        boot_config "$@"
        ;;
      install)
        shift
        [[ $# -eq 0 ]] && { log_error "Please specify a hostname"; show_help; exit 1; }
        install_system "$@"
        ;;
      home)
        shift
        [[ $# -eq 0 ]] && { log_error "Please specify a home configuration"; show_help; exit 1; }
        switch_home "$@"
        ;;
      update)
        update_flake
        ;;
      list|ls)
        list_configs
        ;;
      create)
        shift
        [[ $# -lt 2 ]] && { log_error "Please specify type and name: create <type> <name>"; show_help; exit 1; }
        local config_type="$1"
        local config_name="$2"
        case "$config_type" in
          nixos)
            create_nixos_config "$config_name"
            ;;
          darwin)
            create_darwin_config "$config_name"
            ;;
          *)
            log_error "Unknown configuration type: $config_type"
            echo "Available types: nixos, darwin"
            exit 1
            ;;
        esac
        ;;
      clone)
        shift
        [[ $# -lt 2 ]] && { log_error "Please specify source and target: clone <source> <target>"; show_help; exit 1; }
        clone_config "$1" "$2"
        ;;
      help|--help|-h)
        show_help
        ;;
      *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
    esac
  }

  # Run main with all arguments
  main "$@"
''
