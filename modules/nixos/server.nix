# modules/nixos/server.nix
{ config
, pkgs
, lib
, ...
}:
{
  # Server-specific configuration

  # Disable GUI completely
  services.xserver.enable = false;

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };

    # Restrict SSH to specific users
    allowSFTP = true;
    extraConfig = ''
      AllowUsers wyatt
    '';
  };

  # Firewall configuration for server
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
      # Add other ports as needed
    ];
    allowedUDPPorts = [ ];

    # Log dropped packets
    logRefusedConnections = false; # Set to true for debugging
  };

  # Fail2ban for intrusion prevention
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "10m";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # 1 week
      overalljails = true;
    };

    jails = {
      ssh = ''
        enabled = true
        filter = sshd
        maxretry = 3
        bantime = 600
      '';
    };
  };

  # Nginx web server (uncomment if needed)
  # services.nginx = {
  #   enable = true;
  #   recommendedGzipSettings = true;
  #   recommendedOptimisation = true;
  #   recommendedProxySettings = true;
  #   recommendedTlsSettings = true;
  # };

  # Docker (uncomment if needed)
  # virtualisation.docker = {
  #   enable = true;
  #   autoPrune.enable = true;
  # };

  # Server monitoring
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };
    };
  };

  # Automatic updates (use carefully)
  system.autoUpgrade = {
    enable = false; # Set to true to enable automatic updates
    dates = "04:00";
    allowReboot = false;
  };

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    iotop
    nethogs
    ncdu

    # Network tools
    nmap
    tcpdump
    iperf3

    # Text processing
    jq
    yq

    # Backup tools
    rsync
    rclone

    # Process management
    screen
    tmux
  ];

  # Increase systemd service limits
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  # Kernel parameters for servers
  boot.kernel.sysctl = {
    # Network optimizations
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # Security
    "net.ipv4.conf.all.send_redirects" = false;
    "net.ipv4.conf.default.send_redirects" = false;
    "net.ipv4.conf.all.accept_redirects" = false;
    "net.ipv4.conf.default.accept_redirects" = false;
  };
}
