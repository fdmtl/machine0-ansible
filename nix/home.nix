{ pkgs, ... }: {
  home.username = "ubuntu";
  home.homeDirectory = "/home/ubuntu";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Build tools (replaces build-essential, cmake, pkg-config)
    gcc
    gnumake
    cmake
    pkg-config

    # CLI essentials (replaces apt packages from core.yml)
    git
    vim
    curl
    wget
    unzip
    jq
    p7zip
    inetutils
    htop
    btop
    fzf
    ripgrep

    # Runtimes (replaces mise)
    nodejs_22
    bun
    python313
    uv
    pipx
    rustc
    cargo
    go

    # Shell tools (replaces 02-shell apt packages)
    eza
    zoxide
    starship
    screen
    chafa
    powerline
    powerline-fonts
  ];

  # fastfetch intentionally NOT here — owned by 03-motd ansible role (apt PPA)

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = builtins.readFile ./files/init.zsh;
    envExtra = ''
      # Ensure nix is on PATH for all shell types (login, interactive, scripts)
      if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
  };

  home.file.".screenrc".source = ./files/screenrc;
  home.file.".config/starship/starship.toml".source = ./files/starship.toml;
}
