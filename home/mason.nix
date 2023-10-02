{ inputs, config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mason";
  home.homeDirectory = "/home/mason";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Apps
    qutebrowser
    python311Packages.adblock

    firefox
    ungoogled-chromium
    luakit
    librewolf
    wezterm
    pavucontrol
    dbeaver
    obs-studio
    freetube
    slack
    discord
    lapce
    helix

    gnome.gnome-calculator
    gnome.nautilus

    blender
    godot_4
    krita
    gimp

    # Nix
    nix-your-shell

    # Langs
    rustc
    go
    zig
    lua
    typescript
    python311

    # LSPs
    rust-analyzer
    gopls
    zls
    lua-language-server
    nodePackages.typescript-language-server
    haskell-language-server
    rnix-lsp
    nil
    python311Packages.python-lsp-server

    # Formatters
    rustfmt
    gofumpt
    golines
    nixpkgs-fmt

    # Tools
    cargo
    gcc
    ghc
    ripgrep
    fd
    fzf
    cliphist
    wtype
  ] ++ [
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  xdg.configFile."sway".source = ../sway;
  xdg.configFile."waybar".source = ../waybar;
  xdg.configFile."starship.toml".source = ../starship.toml;

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mason/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 32;

    gtk.enable = false;
    x11.enable = true;
  };

  gtk = {
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;

    theme = "Tokyo Night";

    font = {
      name = "FiraCode Nerd Font Bold";
      size = 12;
    };

    extraConfig = ''
      shell fish
      background_opacity 0.9
      cursor_blink_interval 0
      touch_scroll_multiplier 10.0
      window_padding_width 0 6
    '';
  };

  programs.firefox = {
    enable = true;

    profiles.mason = {
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
       ublock-origin 
       darkreader
       bitwarden
       libredirect
       vimium
       sidebery
      ];

      userChrome = builtins.readFile ../userChrome.css;

      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "dom.security.https_only_mode" = true;
      };

      search = {
        default = "DuckDuckGo";

        force = true;

        order = [
          "DuckDuckGo"
          "Nix Packages"
          "NixOs Wiki"
        ];

        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Wiki" = {
            urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
        };
      };
    };
  };

  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      # Dep
      plenary-nvim
      nvim-web-devicons # https://github.com/intel/intel-one-mono/issues/9

      # Langs
      nvim-lspconfig
      fidget-nvim
      neodev-nvim
      nvim-treesitter.withAllGrammars
      nvim-lint
      comment-nvim
      kmonad-vim

      # Autocompletion
      #--------------------
      nvim-cmp
      # Snippet Engine & its associated nvim-cmp source
      luasnip
      cmp_luasnip

      # Adds LSP completion capabilities
      cmp-nvim-lsp
      cmp-nvim-lua

      # Adds a number of user-friendly snippets
      friendly-snippets

      # cmdline
      cmp-cmdline
      cmp-buffer

      cmp-path
      #--------------------

      # Neotest
      neotest
      FixCursorHold-nvim
      neotest-jest

      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim

      # Theme
      tokyonight-nvim

      # Git related plugins
      vim-fugitive
      vim-rhubarb
      gitsigns-nvim

      # Detect tabstop and shiftwidth automatically
      vim-sleuth

      # Extras
      nvim-tree-lua
      which-key-nvim
      lualine-nvim
      harpoon
      refactoring-nvim
      undotree
      dashboard-nvim
      neorg
      vim-be-good
      nvim-colorizer-lua

      (pkgs.vimUtils.buildVimPlugin {
        name = "transparent-nvim";
        src = inputs.transparent-nvim;
      })

      # configuration
      (pkgs.vimUtils.buildVimPlugin {
        name = "mason";
        src = ../nvim;
      })
    ];

    extraConfig = ''
      lua << EOF
        require 'mason'.init()
      EOF
    '';

    # extraPackages = with pkgs; [
    # ];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nv = "nvim";
    };

    initExtra = ''
      if command -v nix-your-shell > /dev/null; then
        nix-your-shell zsh | source /dev/stdin
      fi
    '';
  };

  programs.fish = {
    enable = true;
    # shellAbbrs = { nv = "nvim"; };
    shellInit = ''
      set fish_greeting

      alias nv="nvim"

      set -x DIRENV_LOG_FORMAT ""

      if command -q nix-your-shell
        nix-your-shell fish | source
      end

      # TokyoNight Color Palette
      set -l foreground c0caf5
      set -l selection 283457
      set -l comment 565f89
      set -l red f7768e
      set -l orange ff9e64
      set -l yellow e0af68
      set -l green 9ece6a
      set -l purple 9d7cd8
      set -l cyan 7dcfff
      set -l pink bb9af7

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
    goPath = "~/.go";
  };
}
