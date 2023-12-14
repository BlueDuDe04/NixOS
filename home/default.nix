{ pkgs, ... }: {

  xdg.configFile = {
    "starship.toml".source = ../starship.toml;
    "lf/icons".source = ../lf/icons;
    "fish/functions/lfcd.fish".source = ../lf/lfcd.fish;
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  home = {
    stateVersion = "22.11"; # Please read the comment before changing.

    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      userName = "BlueDuDe04";
      userEmail = "Bennettmason04@gmail.com";
    };

    lf = {
      enable = true;

      settings = {
        preview = true;
        hidden = true;
        drawbox = true;
        icons = true;
        ignorecase = true;
      };

      # commands = {
      # };

      keybindings = {
        "<esc>" = '':quit'';
      };

      extraConfig = 
      let 
        previewer = 
          pkgs.writeShellScriptBin "pv.sh" ''
          file=$1
          w=$2
          h=$3
          x=$4
          y=$5
          
          if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
              ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
              exit 1
          fi
          
          ${pkgs.pistol}/bin/pistol "$file"
        '';

        cleaner = pkgs.writeShellScriptBin "clean.sh" ''
          ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
        '';
      in ''
        set cleaner ${cleaner}/bin/clean.sh
        set previewer ${previewer}/bin/pv.sh
      '';
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        nv = "nvim";
      };

      initExtra = ''
        ${pkgs.nix-your-shell}/bin/nix-your-shell zsh | source /dev/stdin
      '';
    };

    fish = {
      enable = true;

      shellInit = ''
        set fish_greeting

        ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source

        bind \co 'set old_tty (stty -g); stty sane; lfcd; stty $old_tty; commandline -f repaint'

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

    starship = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true;
      enableZshIntegration = true;
    };

    go = {
      enable = true;
      goPath = ".go";
    };
  };
}
