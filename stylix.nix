{input, config, pkgs, stylix, ...}:
let
  font = pkgs.nerdfonts.override { fonts = ["FiraCode"]; };
in {
  stylix.image = ./colorful-sky.jpg;
  # stylix.polarity = "dark";
  stylix.base16Scheme = ./tokyonight-night.yaml;

  stylix.opacity.terminal = 0.9;

  stylix.cursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 26;
  };

  stylix.fonts = {
    serif = {
      package = font;
      name = "Firacode Nerd Font Mono:style=Bold";
    };

    sansSerif = {
      package = font;
      name = "Firacode Nerd Font Mono:style=Bold";
    };

    monospace = {
      package = font;
      name = "Firacode Nerd Font Mono:style=Bold";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
}
