{
  description = "Deshun's MacOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    user = "deshuncai";
    hostname = "Deshuns-MacBook-Pro";
    system = "aarch64-darwin"; 
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        # 1. Main System Configuration
        ({ pkgs, ... }: {
          
          # --- FIXED: The Missing Link ---
          # This tells nix-darwin who owns the Dock/Finder settings
          system.primaryUser = user;
          # -----------------------------

          nix.settings.experimental-features = "nix-command flakes";
          nixpkgs.config.allowUnfree = true;

          # Basic Users Setup
          users.users.${user} = {
            name = user;
            home = "/Users/${user}";
          };

          environment.systemPackages = with pkgs; [ vim git curl zellij aerospace ghostty-bin vscode ];

          # macOS Settings
          system.defaults = {
            dock = {
              autohide = true;
              show-recents = false;
              orientation = "left";
              persistent-apps = [
                "/System/Applications/Messages.app"
                "/Applications/Google Chrome.app"
                "/Applications/Nix Apps/Ghostty.app"
              ];
            };
            finder = { AppleShowAllExtensions = true; _FXShowPosixPathInTitle = true; };
            NSGlobalDomain = {
              AppleInterfaceStyle = "Dark";
              KeyRepeat = 2;
              "com.apple.trackpad.scaling" = 3.0;
            };
          };

          # TouchID for Sudo
          security.pam.services.sudo_local.touchIdAuth = true;

          # Homebrew
          homebrew = {
            enable = true;
            brews = [
              "neovim"
            ];
            casks = [
              "docker"
              "google-chrome"
              "karabiner-elements"
              "raycast"
              "zoom"
              "obs"
            ];
          };

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 5; 
        })

        # 2. Home Manager Configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = { pkgs, ... }: {
            home.homeDirectory = "/Users/${user}";
            home.stateVersion = "24.05";
            
            home.packages = with pkgs; [
              ripgrep fd jq eza bat fzf zoxide
              direnv lazygit gh

              # Language runtimes (Mason will handle LSPs/formatters/debuggers)
              nodejs
              bun
              python313

              # Rust: Full toolchain (compiler, package manager, tools)
              cargo          # Rust package manager
              rustc          # Rust compiler
              rust-analyzer  # Rust LSP (could let Mason handle, but Nix version is often better)
              rustfmt        # Rust formatter
              clippy         # Rust linter

              # Mason will auto-install: Python/TS LSPs, formatters, linters, DAP adapters
            ];

            programs.claude-code = {
              enable = true;
              settings = {
                permissions = {
                  allow = [ "WebSearch" ];
                  defaultMode = "default";
                };
                enabledPlugins = {
                  "typescript-lsp@claude-plugins-official" = true;
                  "lua-lsp@claude-plugins-official" = true;
                  "pyright-lsp@claude-plugins-official" = true;
                };
                promptSuggestionEnabled = false;
                attribution = {
                  commit = "";
                  pr = "";
                };
              };
            };

            programs.zsh = {
              enable = true;
              enableCompletion = true;
              oh-my-zsh = {
                enable = true;
                plugins = [ "git" "sudo" "docker" "kubectl" "vi-mode" ];
                theme = "robbyrussell";
              };
              shellAliases = {
                ls = "eza --icons";
                ll = "eza -l --icons --git -a";
                v = "nvim";
              };
              initContent = ''
                # Enable vi mode
                bindkey -v

                # Homebrew
                eval "$(/opt/homebrew/bin/brew shellenv zsh)"

                # Zoxide
                eval "$(zoxide init zsh)"

                # Direnv
                eval "$(direnv hook zsh)"
              '';
            };

            programs.neovim = {
              enable = true;
              defaultEditor = true;
              viAlias = true;
              vimAlias = true;
            };

            programs.aerospace = {
              enable = true;
              launchd.enable = true;
              settings = {
                start-at-login = true;
                enable-normalization-flatten-containers = true;
                enable-normalization-opposite-orientation-for-nested-containers = true;
                accordion-padding = 30;
                default-root-container-layout = "tiles";
                default-root-container-orientation = "auto";
                on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

                on-window-detected = [
                  {
                    "if".app-id = "com.mitchellh.ghostty";
                    run = "move-node-to-workspace T";
                  }
                  {
                    "if".app-id = "com.google.Chrome";
                    run = "move-node-to-workspace B";
                  }
                  {
                    "if".app-id = "com.apple.MobileSMS";
                    run = "move-node-to-workspace M";
                  }
                  {
                    "if".app-id = "us.zoom.xos";
                    run = "move-node-to-workspace Z";
                  }
                  {
                    "if".app-id = "com.obsproject.obs-studio";
                    run = "move-node-to-workspace O";
                  }
                ];

                mode.main.binding = {
                  alt-slash = "layout tiles horizontal vertical";
                  alt-comma = "layout accordion horizontal vertical";

                  alt-h = "focus left";
                  alt-j = "focus down";
                  alt-k = "focus up";
                  alt-l = "focus right";

                  alt-shift-h = "move left";
                  alt-shift-j = "move down";
                  alt-shift-k = "move up";
                  alt-shift-l = "move right";

                  alt-minus = "resize smart -50";
                  alt-equal = "resize smart +50";

                  alt-1 = "workspace 1";
                  alt-2 = "workspace 2";
                  alt-3 = "workspace 3";
                  alt-4 = "workspace 4";
                  alt-5 = "workspace 5";
                  alt-6 = "workspace 6";
                  alt-7 = "workspace 7";
                  alt-8 = "workspace 8";
                  alt-9 = "workspace 9";

                  alt-a = "workspace A";
                  alt-b = "workspace B";
                  alt-c = "workspace C";
                  alt-d = "workspace D";
                  alt-e = "workspace E";
                  alt-f = "workspace F";
                  alt-g = "workspace G";
                  alt-i = "workspace I";
                  alt-m = "workspace M";
                  alt-n = "workspace N";
                  alt-o = "workspace O";
                  alt-p = "workspace P";
                  alt-q = "workspace Q";
                  alt-r = "workspace R";
                  alt-s = "workspace S";
                  alt-t = "workspace T";
                  alt-u = "workspace U";
                  alt-v = "workspace V";
                  alt-w = "workspace W";
                  alt-x = "workspace X";
                  alt-y = "workspace Y";
                  alt-z = "workspace Z";

                  alt-shift-1 = "move-node-to-workspace 1";
                  alt-shift-2 = "move-node-to-workspace 2";
                  alt-shift-3 = "move-node-to-workspace 3";
                  alt-shift-4 = "move-node-to-workspace 4";
                  alt-shift-5 = "move-node-to-workspace 5";
                  alt-shift-6 = "move-node-to-workspace 6";
                  alt-shift-7 = "move-node-to-workspace 7";
                  alt-shift-8 = "move-node-to-workspace 8";
                  alt-shift-9 = "move-node-to-workspace 9";

                  alt-shift-a = "move-node-to-workspace A";
                  alt-shift-b = "move-node-to-workspace B";
                  alt-shift-c = "move-node-to-workspace C";
                  alt-shift-d = "move-node-to-workspace D";
                  alt-shift-e = "move-node-to-workspace E";
                  alt-shift-f = "move-node-to-workspace F";
                  alt-shift-g = "move-node-to-workspace G";
                  alt-shift-i = "move-node-to-workspace I";
                  alt-shift-m = "move-node-to-workspace M";
                  alt-shift-n = "move-node-to-workspace N";
                  alt-shift-o = "move-node-to-workspace O";
                  alt-shift-p = "move-node-to-workspace P";
                  alt-shift-q = "move-node-to-workspace Q";
                  alt-shift-r = "move-node-to-workspace R";
                  alt-shift-s = "move-node-to-workspace S";
                  alt-shift-t = "move-node-to-workspace T";
                  alt-shift-u = "move-node-to-workspace U";
                  alt-shift-v = "move-node-to-workspace V";
                  alt-shift-w = "move-node-to-workspace W";
                  alt-shift-x = "move-node-to-workspace X";
                  alt-shift-y = "move-node-to-workspace Y";
                  alt-shift-z = "move-node-to-workspace Z";

                  alt-tab = "workspace-back-and-forth";
                  alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

                  alt-shift-semicolon = "mode service";
                };

                mode.service.binding = {
                  esc = ["reload-config" "mode main"];
                  r = ["flatten-workspace-tree" "mode main"];
                  f = ["layout floating tiling" "mode main"];
                  backspace = ["close-all-windows-but-current" "mode main"];
                };
              };
            };

            programs.zellij = {
              enable = true;
              enableZshIntegration = true;
            };

            # Zellij configuration
            home.file.".config/zellij/config.kdl" = {
              force = true;
              text = ''
                //
                // THIS FILE WAS AUTOGENERATED BY ZELLIJ, THE PREVIOUS FILE AT THIS LOCATION WAS COPIED TO: /Users/deshuncai/.config/zellij/config.kdl.bak
                //

                keybinds clear-defaults=true {
                    locked {
                        bind "Ctrl g" { SwitchToMode "normal"; }
                    }
                    pane {
                        bind "left" { MoveFocus "left"; }
                        bind "down" { MoveFocus "down"; }
                        bind "up" { MoveFocus "up"; }
                        bind "right" { MoveFocus "right"; }
                        bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
                        bind "d" { NewPane "down"; SwitchToMode "locked"; }
                        bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }
                        bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
                        bind "h" { MoveFocus "left"; }
                        bind "i" { TogglePanePinned; SwitchToMode "locked"; }
                        bind "j" { MoveFocus "down"; }
                        bind "k" { MoveFocus "up"; }
                        bind "l" { MoveFocus "right"; }
                        bind "n" { NewPane; SwitchToMode "locked"; }
                        bind "p" { SwitchToMode "normal"; }
                        bind "r" { NewPane "right"; SwitchToMode "locked"; }
                        bind "s" { NewPane "stacked"; SwitchToMode "locked"; }
                        bind "w" { ToggleFloatingPanes; SwitchToMode "locked"; }
                        bind "x" { CloseFocus; SwitchToMode "locked"; }
                        bind "z" { TogglePaneFrames; SwitchToMode "locked"; }
                        bind "tab" { SwitchFocus; }
                    }
                    tab {
                        bind "left" { GoToPreviousTab; }
                        bind "down" { GoToNextTab; }
                        bind "up" { GoToPreviousTab; }
                        bind "right" { GoToNextTab; }
                        bind "1" { GoToTab 1; SwitchToMode "locked"; }
                        bind "2" { GoToTab 2; SwitchToMode "locked"; }
                        bind "3" { GoToTab 3; SwitchToMode "locked"; }
                        bind "4" { GoToTab 4; SwitchToMode "locked"; }
                        bind "5" { GoToTab 5; SwitchToMode "locked"; }
                        bind "6" { GoToTab 6; SwitchToMode "locked"; }
                        bind "7" { GoToTab 7; SwitchToMode "locked"; }
                        bind "8" { GoToTab 8; SwitchToMode "locked"; }
                        bind "9" { GoToTab 9; SwitchToMode "locked"; }
                        bind "[" { BreakPaneLeft; SwitchToMode "locked"; }
                        bind "]" { BreakPaneRight; SwitchToMode "locked"; }
                        bind "b" { BreakPane; SwitchToMode "locked"; }
                        bind "h" { GoToPreviousTab; }
                        bind "j" { GoToNextTab; }
                        bind "k" { GoToPreviousTab; }
                        bind "l" { GoToNextTab; }
                        bind "n" { NewTab; SwitchToMode "locked"; }
                        bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
                        bind "s" { ToggleActiveSyncTab; SwitchToMode "locked"; }
                        bind "t" { SwitchToMode "normal"; }
                        bind "x" { CloseTab; SwitchToMode "locked"; }
                        bind "tab" { ToggleTab; }
                    }
                    resize {
                        bind "left" { Resize "Increase left"; }
                        bind "down" { Resize "Increase down"; }
                        bind "up" { Resize "Increase up"; }
                        bind "right" { Resize "Increase right"; }
                        bind "+" { Resize "Increase"; }
                        bind "-" { Resize "Decrease"; }
                        bind "=" { Resize "Increase"; }
                        bind "H" { Resize "Decrease left"; }
                        bind "J" { Resize "Decrease down"; }
                        bind "K" { Resize "Decrease up"; }
                        bind "L" { Resize "Decrease right"; }
                        bind "h" { Resize "Increase left"; }
                        bind "j" { Resize "Increase down"; }
                        bind "k" { Resize "Increase up"; }
                        bind "l" { Resize "Increase right"; }
                        bind "r" { SwitchToMode "normal"; }
                    }
                    move {
                        bind "left" { MovePane "left"; }
                        bind "down" { MovePane "down"; }
                        bind "up" { MovePane "up"; }
                        bind "right" { MovePane "right"; }
                        bind "h" { MovePane "left"; }
                        bind "j" { MovePane "down"; }
                        bind "k" { MovePane "up"; }
                        bind "l" { MovePane "right"; }
                        bind "m" { SwitchToMode "normal"; }
                        bind "n" { MovePane; }
                        bind "p" { MovePaneBackwards; }
                        bind "tab" { MovePane; }
                    }
                    scroll {
                        bind "Alt left" { MoveFocusOrTab "left"; SwitchToMode "locked"; }
                        bind "Alt down" { MoveFocus "down"; SwitchToMode "locked"; }
                        bind "Alt up" { MoveFocus "up"; SwitchToMode "locked"; }
                        bind "Alt right" { MoveFocusOrTab "right"; SwitchToMode "locked"; }
                        bind "e" { EditScrollback; SwitchToMode "locked"; }
                        bind "f" { SwitchToMode "entersearch"; SearchInput 0; }
                        bind "Alt h" { MoveFocusOrTab "left"; SwitchToMode "locked"; }
                        bind "Alt j" { MoveFocus "down"; SwitchToMode "locked"; }
                        bind "Alt k" { MoveFocus "up"; SwitchToMode "locked"; }
                        bind "Alt l" { MoveFocusOrTab "right"; SwitchToMode "locked"; }
                        bind "s" { SwitchToMode "normal"; }
                    }
                    search {
                        bind "c" { SearchToggleOption "CaseSensitivity"; }
                        bind "n" { Search "down"; }
                        bind "o" { SearchToggleOption "WholeWord"; }
                        bind "p" { Search "up"; }
                        bind "w" { SearchToggleOption "Wrap"; }
                    }
                    session {
                        bind "a" {
                            LaunchOrFocusPlugin "zellij:about" {
                                floating true
                                move_to_focused_tab true
                            }
                            SwitchToMode "locked"
                        }
                        bind "c" {
                            LaunchOrFocusPlugin "configuration" {
                                floating true
                                move_to_focused_tab true
                            }
                            SwitchToMode "locked"
                        }
                        bind "d" { Detach; }
                        bind "o" { SwitchToMode "normal"; }
                        bind "p" {
                            LaunchOrFocusPlugin "plugin-manager" {
                                floating true
                                move_to_focused_tab true
                            }
                            SwitchToMode "locked"
                        }
                        bind "s" {
                            LaunchOrFocusPlugin "zellij:share" {
                                floating true
                                move_to_focused_tab true
                            }
                            SwitchToMode "locked"
                        }
                        bind "w" {
                            LaunchOrFocusPlugin "session-manager" {
                                floating true
                                move_to_focused_tab true
                            }
                            SwitchToMode "locked"
                        }
                    }
                    shared_among "normal" "locked" {
                        bind "Alt left" { MoveFocusOrTab "left"; }
                        bind "Alt down" { MoveFocus "down"; }
                        bind "Alt up" { MoveFocus "up"; }
                        bind "Alt right" { MoveFocusOrTab "right"; }
                        bind "Alt +" { Resize "Increase"; }
                        bind "Alt -" { Resize "Decrease"; }
                        bind "Alt =" { Resize "Increase"; }
                        bind "Alt [" { PreviousSwapLayout; }
                        bind "Alt ]" { NextSwapLayout; }
                        bind "Alt f" { ToggleFloatingPanes; }
                        bind "Alt h" { MoveFocusOrTab "left"; }
                        bind "Alt i" { MoveTab "left"; }
                        bind "Alt j" { MoveFocus "down"; }
                        bind "Alt k" { MoveFocus "up"; }
                        bind "Alt l" { MoveFocusOrTab "right"; }
                        bind "Alt n" { NewPane; }
                        bind "Alt o" { MoveTab "right"; }
                        bind "Alt p" { TogglePaneInGroup; }
                        bind "Alt Shift p" { ToggleGroupMarking; }
                    }
                    shared_except "locked" "renametab" "renamepane" {
                        bind "Ctrl g" { SwitchToMode "locked"; }
                        bind "Ctrl q" { Quit; }
                    }
                    shared_except "locked" "entersearch" {
                        bind "enter" { SwitchToMode "locked"; }
                    }
                    shared_except "locked" "entersearch" "renametab" "renamepane" {
                        bind "esc" { SwitchToMode "locked"; }
                    }
                    shared_except "locked" "entersearch" "renametab" "renamepane" "move" {
                        bind "m" { SwitchToMode "move"; }
                    }
                    shared_except "locked" "entersearch" "search" "renametab" "renamepane" "session" {
                        bind "o" { SwitchToMode "session"; }
                    }
                    shared_except "locked" "tab" "entersearch" "renametab" "renamepane" {
                        bind "t" { SwitchToMode "tab"; }
                    }
                    shared_among "normal" "resize" "tab" "scroll" "prompt" "tmux" {
                        bind "p" { SwitchToMode "pane"; }
                    }
                    shared_among "normal" "resize" "search" "move" "prompt" "tmux" {
                        bind "s" { SwitchToMode "scroll"; }
                    }
                    shared_except "locked" "resize" "pane" "tab" "entersearch" "renametab" "renamepane" {
                        bind "r" { SwitchToMode "resize"; }
                    }
                    shared_among "scroll" "search" {
                        bind "PageDown" { PageScrollDown; }
                        bind "PageUp" { PageScrollUp; }
                        bind "left" { PageScrollUp; }
                        bind "down" { ScrollDown; }
                        bind "up" { ScrollUp; }
                        bind "right" { PageScrollDown; }
                        bind "Ctrl b" { PageScrollUp; }
                        bind "Ctrl c" { ScrollToBottom; SwitchToMode "locked"; }
                        bind "d" { HalfPageScrollDown; }
                        bind "Ctrl f" { PageScrollDown; }
                        bind "h" { PageScrollUp; }
                        bind "j" { ScrollDown; }
                        bind "k" { ScrollUp; }
                        bind "l" { PageScrollDown; }
                        bind "u" { HalfPageScrollUp; }
                    }
                    entersearch {
                        bind "Ctrl c" { SwitchToMode "scroll"; }
                        bind "esc" { SwitchToMode "scroll"; }
                        bind "enter" { SwitchToMode "search"; }
                    }
                    renametab {
                        bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
                    }
                    shared_among "renametab" "renamepane" {
                        bind "Ctrl c" { SwitchToMode "locked"; }
                    }
                    renamepane {
                        bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
                    }
                }

                // Plugin aliases - can be used to change the implementation of Zellij
                // changing these requires a restart to take effect
                plugins {
                    about location="zellij:about"
                    compact-bar location="zellij:compact-bar"
                    configuration location="zellij:configuration"
                    filepicker location="zellij:strider" {
                        cwd "/"
                    }
                    plugin-manager location="zellij:plugin-manager"
                    session-manager location="zellij:session-manager"
                    status-bar location="zellij:status-bar"
                    strider location="zellij:strider"
                    tab-bar location="zellij:tab-bar"
                    welcome-screen location="zellij:session-manager" {
                        welcome_screen true
                    }
                }

                // Plugins to load in the background when a new session starts
                // eg. "file:/path/to/my-plugin.wasm"
                // eg. "https://example.com/my-plugin.wasm"
                load_plugins {
                }
                web_client {
                    font "monospace"
                }

                // Use a simplified UI without special fonts (arrow glyphs)
                // Options:
                //   - true
                //   - false (Default)
                //
                // simplified_ui true

                // Choose the theme that is specified in the themes section.
                // Default: default
                //
                // theme "dracula"

                // Choose the base input mode of zellij.
                // Default: normal
                //
                default_mode "locked"

                // Choose the path to the default shell that zellij will use for opening new panes
                // Default: $SHELL
                //
                // default_shell "fish"

                // Choose the path to override cwd that zellij will use for opening new panes
                //
                // default_cwd "/tmp"

                // The name of the default layout to load on startup
                // Default: "default"
                //
                // default_layout "compact"

                // The folder in which Zellij will look for layouts
                // (Requires restart)
                //
                // layout_dir "/tmp"

                // The folder in which Zellij will look for themes
                // (Requires restart)
                //
                // theme_dir "/tmp"

                // Toggle enabling the mouse mode.
                // On certain configurations, or terminals this could
                // potentially interfere with copying text.
                // Options:
                //   - true (default)
                //   - false
                //
                // mouse_mode false

                // Toggle having pane frames around the panes
                // Options:
                //   - true (default, enabled)
                //   - false
                //
                // pane_frames false

                // When attaching to an existing session with other users,
                // should the session be mirrored (true)
                // or should each user have their own cursor (false)
                // (Requires restart)
                // Default: false
                //
                // mirror_session true

                // Choose what to do when zellij receives SIGTERM, SIGINT, SIGQUIT or SIGHUP
                // eg. when terminal window with an active zellij session is closed
                // (Requires restart)
                // Options:
                //   - detach (Default)
                //   - quit
                //
                // on_force_close "quit"

                // Configure the scroll back buffer size
                // This is the number of lines zellij stores for each pane in the scroll back
                // buffer. Excess number of lines are discarded in a FIFO fashion.
                // (Requires restart)
                // Valid values: positive integers
                // Default value: 10000
                //
                // scroll_buffer_size 10000

                // Provide a command to execute when copying text. The text will be piped to
                // the stdin of the program to perform the copy. This can be used with
                // terminal emulators which do not support the OSC 52 ANSI control sequence
                // that will be used by default if this option is not set.
                // Examples:
                //
                // copy_command "xclip -selection clipboard" // x11
                // copy_command "wl-copy"                    // wayland
                // copy_command "pbcopy"                     // osx
                //
                // copy_command "pbcopy"

                // Choose the destination for copied text
                // Allows using the primary selection buffer (on x11/wayland) instead of the system clipboard.
                // Does not apply when using copy_command.
                // Options:
                //   - system (default)
                //   - primary
                //
                // copy_clipboard "primary"

                // Enable automatic copying (and clearing) of selection when releasing mouse
                // Default: true
                //
                // copy_on_select true

                // Path to the default editor to use to edit pane scrollbuffer
                // Default: $EDITOR or $VISUAL
                // scrollback_editor "/usr/bin/vim"

                // A fixed name to always give the Zellij session.
                // Consider also setting `attach_to_session true,`
                // otherwise this will error if such a session exists.
                // Default: <RANDOM>
                //
                // session_name "My singleton session"

                // When `session_name` is provided, attaches to that session
                // if it is already running or creates it otherwise.
                // Default: false
                //
                // attach_to_session true

                // Toggle between having Zellij lay out panes according to a predefined set of layouts whenever possible
                // Options:
                //   - true (default)
                //   - false
                //
                // auto_layout false

                // Whether sessions should be serialized to the cache folder (including their tabs/panes, cwds and running commands) so that they can later be resurrected
                // Options:
                //   - true (default)
                //   - false
                //
                // session_serialization false

                // Whether pane viewports are serialized along with the session, default is false
                // Options:
                //   - true
                //   - false (default)
                //
                // serialize_pane_viewport false

                // Scrollback lines to serialize along with the pane viewport when serializing sessions, 0
                // defaults to the scrollback size. If this number is higher than the scrollback size, it will
                // also default to the scrollback size. This does nothing if `serialize_pane_viewport` is not true.
                //
                // scrollback_lines_to_serialize 10000

                // Enable or disable the rendering of styled and colored underlines (undercurl).
                // May need to be disabled for certain unsupported terminals
                // (Requires restart)
                // Default: true
                //
                // styled_underlines false

                // How often in seconds sessions are serialized
                //
                // serialization_interval 10000

                // Enable or disable writing of session metadata to disk (if disabled, other sessions might not know
                // metadata info on this session)
                // (Requires restart)
                // Default: false
                //
                // disable_session_metadata false

                // Enable or disable support for the enhanced Kitty Keyboard Protocol (the host terminal must also support it)
                // (Requires restart)
                // Default: true (if the host terminal supports it)
                //
                // support_kitty_keyboard_protocol false
                // Whether to make sure a local web server is running when a new Zellij session starts.
                // This web server will allow creating new sessions and attaching to existing ones that have
                // opted in to being shared in the browser.
                // When enabled, navigate to http://127.0.0.1:8082
                // (Requires restart)
                //
                // Note: a local web server can still be manually started from within a Zellij session or from the CLI.
                // If this is not desired, one can use a version of Zellij compiled without
                // `web_server_capability`
                //
                // Possible values:
                // - true
                // - false
                // Default: false
                //
                // web_server false
                // Whether to allow sessions started in the terminal to be shared through a local web server, assuming one is
                // running (see the `web_server` option for more details).
                // (Requires restart)
                //
                // Note: This is an administrative separation and not intended as a security measure.
                //
                // Possible values:
                // - "on" (allow web sharing through the local web server if it
                // is online)
                // - "off" (do not allow web sharing unless sessions explicitly opt-in to it)
                // - "disabled" (do not allow web sharing and do not permit sessions started in the terminal to opt-in to it)
                // Default: "off"
                //
                // web_sharing "off"
                // A path to a certificate file to be used when setting up the web client to serve the
                // connection over HTTPs
                //
                // web_server_cert "/path/to/cert.pem"
                // A path to a key file to be used when setting up the web client to serve the
                // connection over HTTPs
                //
                // web_server_key "/path/to/key.pem"
                /// Whether to enforce https connections to the web server when it is bound to localhost
                /// (127.0.0.0/8)
                ///
                /// Note: https is ALWAYS enforced when bound to non-local interfaces
                ///
                /// Default: false
                //
                // enforce_https_for_localhost false

                // Whether to stack panes when resizing beyond a certain size
                // Default: true
                //
                // stacked_resize false

                // Whether to show tips on startup
                // Default: true
                //
                // show_startup_tips false

                // Whether to show release notes on first version run
                // Default: true
                //
                // show_release_notes false

                // Whether to enable mouse hover effects and pane grouping functionality
                // default is true
                // advanced_mouse_actions false

                // The ip address the web server should listen on when it starts
                // Default: "127.0.0.1"
                // (Requires restart)
                // web_server_ip "127.0.0.1"

                // The port the web server should listen on when it starts
                // Default: 8082
                // (Requires restart)
                // web_server_port 8082

                // A command to run (will be wrapped with sh -c and provided the RESURRECT_COMMAND env variable)
                // after Zellij attempts to discover a command inside a pane when resurrecting sessions, the STDOUT
                // of this command will be used instead of the discovered RESURRECT_COMMAND
                // can be useful for removing wrappers around commands
                // Note: be sure to escape backslashes and similar characters properly
                // post_command_discovery_hook "echo $RESURRECT_COMMAND | sed <your_regex_here>"
              '';
            };

            # Ghostty configuration file
            home.file.".config/ghostty/config" = {
              force = true;
              text = ''
                font-family = JetBrains Mono
                font-size = 18
              '';
            };

            # Karabiner-Elements configuration file
            home.file.".config/karabiner/karabiner.json" = {
              force = true;
              text = builtins.toJSON {
                global = {
                  check_for_updates_on_startup = true;
                  show_in_menu_bar = true;
                  show_profile_name_in_menu_bar = false;
                };
                profiles = [
                  {
                    complex_modifications = {
                      parameters = {
                        "basic.to_if_alone_timeout_milliseconds" = 200;
                        "basic.to_if_held_down_threshold_milliseconds" = 200;
                      };
                      rules = [
                        {
                          description = "Change caps_lock to delete_or_backspace (with all modifiers)";
                          manipulators = [
                            # Caps Lock alone
                            {
                              from = {
                                key_code = "caps_lock";
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Shift
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["shift"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["shift"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Command
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["command"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["command"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Control
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["control"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["control"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Option
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["option"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["option"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Command + Shift
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["command" "shift"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["command" "shift"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Control + Shift
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["control" "shift"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["control" "shift"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Option + Shift
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["option" "shift"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["option" "shift"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Command + Option
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["command" "option"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["command" "option"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Control + Option
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["control" "option"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["control" "option"];
                                }
                              ];
                              type = "basic";
                            }
                            # Caps Lock + Command + Control
                            {
                              from = {
                                key_code = "caps_lock";
                                modifiers = {
                                  mandatory = ["command" "control"];
                                };
                              };
                              to = [
                                {
                                  key_code = "delete_or_backspace";
                                  modifiers = ["command" "control"];
                                }
                              ];
                              type = "basic";
                            }
                          ];
                        }
                      ];
                    };
                    devices = [];
                    fn_function_keys = [];
                    name = "Default profile";
                    selected = true;
                    simple_modifications = [];
                    virtual_hid_keyboard = {
                      country_code = 0;
                      keyboard_type_v2 = "ansi";
                    };
                  }
                ];
              };
              onChange = ''
                /bin/launchctl kickstart -k gui/`id -u`/org.pqrs.service.agent.karabiner_console_user_server
              '';
            };
          };
        }
      ];
    };
  };
}
