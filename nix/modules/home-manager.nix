{ pkgs, user, ... }: {
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    eza
    bat
    fzf
    zoxide
    direnv
    lazygit

    nodejs
    bun
    python313

    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy

    cmake
  ];
}
