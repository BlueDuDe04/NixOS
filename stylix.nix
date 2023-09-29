{input, config, pkgs, stylix, ...}:
let
  font = pkgs.nerdfonts.override { fonts = ["FiraCode"]; };
in {
  stylix.image = ./colorful-sky.jpg;
  # stylix.polarity = "dark";
  stylix.base16Scheme = ./tokyonight-night.yaml;

  stylix.fonts = {
    serif = {
      package = font;
      name = "Firacode Nerd Font";
    };

    sansSerif = {
      package = font;
      name = "Firacode Nerd Font";
    };

    monospace = {
      package = font;
      name = "Firacode Nerd Font";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
}
