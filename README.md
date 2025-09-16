# 🌳 Yggdrasil - Universal Nix Configuration

A comprehensive, cross-platform Nix configuration supporting NixOS, macOS (nix-darwin), and standalone Home Manager setups. Built for stability, modularity, and ease of maintenance.

## ✨ Features

- **🔀 Cross-platform**: Works on NixOS, macOS, and any system with Nix
- **📦 Modular design**: Easily reusable components and configurations
- **🔒 Stable channels**: Uses stable branches for reliability
- **🏠 Home Manager integration**: Consistent user environment across all platforms
- **🎯 Host-specific overrides**: Customize per-machine while sharing common configs
- **🛠️ Development ready**: Includes dev shells and formatting tools
- **📝 Templates**: Quick setup for new hosts
- **🎨 Dotfiles management**: Centralized configuration files

## 🚀 Quick Start

### Prerequisites

- Nix package manager installed with flakes enabled
- For NixOS: A working NixOS installation
- For macOS: nix-darwin installed
- Git for cloning the repository

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://codeberg.org/wyfy/yggdrasil.git
   cd yggdrasil
   ```

2. **Choose your installation method**:

   **For NixOS systems**:
   ```bash
   # Build and switch to the configuration
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

   **For macOS systems**:
   ```bash
   # First time setup (if nix-darwin not installed)
   nix run nix-darwin -- switch --flake .#your-hostname
   
   # Subsequent updates
   darwin-rebuild switch --flake .#your-hostname
   ```

   **For standalone Home Manager**:
   ```bash
   # Linux
   nix run home-manager/release-25.05 -- switch --flake .#wyatt@linux
   
   # macOS
   nix run home-manager/release-25.05 -- switch --flake .#wyatt@darwin
   ```

## 📁 Configuration Structure

### Host Configurations

Current configured hosts:
- **fenrir**: NixOS desktop system
- **jormungandr**: NixOS server system  
- **hel**: macOS system (Apple Silicon)

### Adding a New Host

1. **Create host directory**:
   ```bash
   mkdir -p host/new-hostname
   ```

2. **Copy template**:
   ```bash
   # For NixOS
   cp templates/nixos-host/configuration.nix host/new-hostname/
   
   # For macOS
   cp templates/darwin-host/configuration.nix host/new-hostname/
   ```

3. **Update flake.nix**:
   ```nix
   # Add to nixosConfigurations or darwinConfigurations
   new-hostname = mkNixosSystem {
     system = "x86_64-linux";  # or appropriate architecture
     hostname = "new-hostname";
     username = "wyatt";
   };
   ```

4. **Customize the configuration**:
   - Edit `host/new-hostname/configuration.nix`
   - Add hardware-configuration.nix for NixOS
   - Create optional host-specific home.nix for overrides

## 🏠 Home Manager Configuration

### User Configuration Structure

```
home/wyatt/
├── default.nix    # Main configuration, imports others
├── programs.nix   # Application configurations
├── shell.nix      # Shell setup (bash/zsh)
├── git.nix        # Git configuration
├── linux.nix      # Linux-specific settings
└── darwin.nix     # macOS-specific settings
```

### Adding Programs

Edit the appropriate file:
- **Terminal programs**: Add to `programs.nix`
- **Shell aliases**: Add to `shell.nix` 
- **Platform-specific**: Add to `linux.nix` or `darwin.nix`
- **Packages**: Add to `default.nix` in the packages list

### Host-Specific Home Overrides

Create `host/hostname/home.nix`:
```nix
{ config, pkgs, lib, ... }:
{
  # Host-specific home-manager overrides
  programs.git.userName = "different-name";
  
  home.packages = with pkgs; [
    # Additional packages for this host
    some-host-specific-package
  ];
}
```

## 🔧 Development

### Development Shell

Enter the development environment:
```bash
nix develop
# or
nix-shell
```

This provides tools for working with the configuration:
- `nixpkgs-fmt` for formatting
- `nil` for Nix language server
- Host-specific rebuild commands

### Formatting Code

Format all Nix files:
```bash
nixpkgs-fmt **/*.nix
```

### Testing Changes

Test configurations without switching:
```bash
# NixOS
sudo nixos-rebuild test --flake .#hostname

# macOS  
darwin-rebuild check --flake .#hostname

# Home Manager
home-manager build --flake .#wyatt@linux
```

## 🎛️ Customization

### System Modules

**Common modules** (shared across platforms):
- `modules/common/fonts.nix` - Font configuration
- `modules/common/locale.nix` - Localization settings
- `modules/common/users.nix` - User account setup

**NixOS modules**:
- `modules/nixos/desktop.nix` - Desktop environment setup
- `modules/nixos/gaming.nix` - Gaming-related configuration
- `modules/nixos/server.nix` - Server optimizations

**macOS modules**:
- `modules/darwin/homebrew.nix` - Homebrew package management
- `modules/darwin/system.nix` - macOS system preferences

### Dotfiles

Store configuration files in `dots/`:
```
dots/
├── hyfetch.json
├── starship.toml
├── wallpapers/
└── scripts/
```

Reference them in home configuration:
```nix
xdg.configFile."app/config.conf".source = ../../dots/app-config.conf;
```

## 📦 Package Management

### System Packages

Add to `environment.systemPackages` in host configurations or modules.

### User Packages  

Add to `home.packages` in `home/wyatt/default.nix` or platform-specific files.

### macOS Applications

Use Homebrew for GUI applications:
```nix
# In modules/darwin/homebrew.nix
homebrew.casks = [
  "new-application"
];
```

## 🔍 Troubleshooting

### Common Issues

**Build failures**:
```bash
# Check for syntax errors
nix flake check

# Update flake inputs
nix flake update

# Clear build cache
sudo rm -rf /nix/var/nix/profiles/system*
```

**Home Manager conflicts**:
```bash
# Backup conflicting files
home-manager switch --flake .#config -b backup

# Remove old generations
home-manager expire-generations -7d
```

**macOS permission issues**:
```bash
# Fix ownership
sudo chown -R $(whoami):staff /nix

# Reset nix-darwin
sudo rm /etc/nix/nix.conf
```

### Getting Help

1. Check the [NixOS manual](https://nixos.org/manual/nixos/stable/)
2. Consult [Home Manager options](https://nix-community.github.io/home-manager/options.html)
3. Browse [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)
4. Search [Nixpkgs](https://search.nixos.org/packages) for packages

## 🔐 Security Notes

### SSH Keys
- Add your public keys to `modules/common/users.nix`
- Use `ssh-keygen -t ed25519` for new keys

### Passwords
- Generate hashed passwords with `mkpasswd -m sha-512`
- Store in `modules/common/users.nix`

### macOS Security
- TouchID for sudo is enabled by default
- Gatekeeper settings in `modules/darwin/system.nix`

## 📈 Maintenance

### Regular Updates

```bash
# Update flake inputs
nix flake update

# Rebuild with new inputs
sudo nixos-rebuild switch --flake .#hostname
# or
darwin-rebuild switch --flake .#hostname
```

### Cleanup

```bash
# Remove old generations (NixOS)
sudo nix-collect-garbage -d

# Remove old generations (Home Manager)
home-manager expire-generations -7d

# Optimize nix store
nix-store --optimise
```

### Backup

Important files to backup:
- This entire repository
- `/etc/nixos/hardware-configuration.nix` (for NixOS hosts)
- SSH keys and other secrets
- Personal dotfiles in `dots/`

## 🐣 Yggdrasil Shell Script

### Basic Usage

```bash
# Check your configuration status
./yggdrasil status

# Build and switch to a configuration (auto-detects platform)
./yggdrasil build fenrir

# Test a configuration without switching
./yggdrasil build fenrir test

# Update flake inputs
./yggdrasil update

# Check flake validity
./yggdrasil check

# Clean up old generations
./yggdrasil cleanup 7

# Create a new host
./yggdrasil create-host server nixos
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Style
- Use `nixpkgs-fmt` for formatting
- Comment complex configurations
- Keep modules focused and reusable
- Follow the existing directory structure

## 📄 License

This configuration is released under the MIT License. Feel free to use, modify, and share.

---

**Happy Nixing!** 🎉
