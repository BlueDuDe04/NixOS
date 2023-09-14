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

    nix-your-shell
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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

    extraPackages = with pkgs; [
      # Langs
      rustc
      go
      zig
      lua
      typescript

      # LSPs
      rust-analyzer
      gopls
      zls
      lua-language-server
      nodePackages.typescript-language-server
      haskell-language-server
      rnix-lsp
      nil

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
    ];
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
    goPath = ".go";
  };
}
