{
  config,
  pkgs,
  lib,
  ...
}: {
  fonts = {
    # Font packages for macOS
    packages = with pkgs; [
      # Programming fonts
      fira-code
      jetbrains-mono
      source-code-pro

      # System fonts (complement macOS built-ins)
      liberation_ttf

      # Unicode coverage
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans

      # Icon fonts
      font-awesome

      # Selective Nerd Fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  # macOS system preferences for fonts (optional)
  system.defaults = {
    # Global font smoothing (sub-pixel anti-aliasing)
    NSGlobalDomain = {
      AppleFontSmoothing = 1; # Enable font smoothing for external displays
    };
  };
}
