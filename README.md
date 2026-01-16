# Deshun's dotfiles

My macOS configuration using nix-darwin, Home Manager, and LazyVim.

## Quick Setup

### 1. Install Nix (if not already installed)
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Clone and apply the configuration
```bash
# Clone into a temporary location
git clone https://github.com/unusep/dotfiles.git ~/dotfiles-temp
cd ~/dotfiles-temp

# Apply nix-darwin configuration (requires sudo)
sudo nix run nix-darwin -- switch --flake .

# Copy this .config to your home directory
cp -r . ~/.config/
```

### 3. Install Neovim plugins
```bash
# LazyVim will auto-install on first launch, but you can trigger it manually:
nvim --headless "+Lazy! sync" +qa
```

## What's Included

- **nix/** - Nix Darwin configuration with Home Manager
  - System packages and Homebrew casks
  - Window manager (Aerospace)
  - Terminal multiplexer (Zellij)
  - Keyboard remapping (Karabiner)
  - Shell configuration (Zsh)

- **nvim/** - Neovim configuration
  - LazyVim starter with custom plugins
  - LSP setup with Mason
  - Language support: Rust, TypeScript, Python, Go

- **karabiner/** - Keyboard remapping config
- **zellij/** - Terminal multiplexer config

## Manual Setup Items (not in git)

These are excluded for security/privacy reasons:
- `.claude/settings.local.json` - Claude Code editor settings
- `raycast/` - Raycast AI scripts (may contain API keys)

Copy these manually if needed.

## Restore on a New Mac

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Clone this config into ~/.config
git clone https://github.com/unusep/dotfiles.git ~/.config

# 3. Apply the configuration (requires sudo)
cd ~/.config && sudo nix run nix-darwin -- switch --flake .

# 4. Reload shell
exec $SHELL
```

## Notes

- The `flake.lock` file pins exact dependency versions for reproducibility
- Some configs (Karabiner, Zellij, Aerospace) are defined in `nix/flake.nix` as Nix modules
- Neovim plugins are managed by LazyVim/lazy.nvim (not committed to git)
- See individual directories for specific configuration details
