pkgs:
let
  numRowList = [
    { key = "a"; num = 9; }
    { key = "r"; num = 5; }
    { key = "s"; num = 1; }
    { key = "t"; num = 3; }
    { key = "g"; num = 7; }

    { key = "m"; num = 6; }
    { key = "n"; num = 2; }
    { key = "e"; num = 0; }
    { key = "i"; num = 4; }
    { key = "o"; num = 8; }
  ];

  tab = num: builtins.concatStringsSep "" (builtins.genList (x: "  ") num);

  bashExec = "bash\", \"-c";

  numRowBinds = func: builtins.concatStringsSep "\n" (builtins.map func numRowList);

  # moveWorkspace = pkgs.writeShellScriptBin "run" ''
  #   swaymsg move workspace number $1 && swaymsg workspace number $1
  # '';

  yankSearch = pkgs.writeShellScriptBin "run" ''
    cliphist list | fuzzel -p '❯  ' -b 2A2B3DFF -s AD8EE6FF -t DDDDDDFF -S DDDDDDFF -d | cliphist decode | wl-copy
  '';

  yankDisplay = pkgs.writeShellScriptBin "run" ''
    grim -g "$(slurp)" - | wl-copy
  '';

  yankColor = pkgs.writeShellScriptBin "run" ''hyprpicker | wl-copy'';

  copyTo = pkgs.writeShellScriptBin "run" ''wl-paste -n | cb cp$1'';

  paste = pkgs.writeShellScriptBin "run" ''wl-paste -n | wtype -'';

  pasteLast = pkgs.writeShellScriptBin "run" ''
    cliphist list | sed -n 2p | cliphist decode | wtype -
  '';

  pasteSearch = pkgs.writeShellScriptBin "run" ''
    cliphist list | fuzzel -p '❯  ' -b 2A2B3DFF -s AD8EE6FF -t DDDDDDFF -S DDDDDDFF -d | cliphist decode | wtype -
  '';

  pasteFrom = pkgs.writeShellScriptBin "run" ''cb p$1 | wtype -'';

  bitwardenSearch = pkgs.writeShellScriptBin "run" ''
    rbw get "$(rbw unlock; rbw list | fuzzel -p '❯  ' -b 2A2B3DFF -s AD8EE6FF -t DDDDDDFF -S DDDDDDFF -d)" | tr -d '\n' | wtype -
  '';
in ''
keymap:
- name: default mode
  remap:
    volumeup:
      launch: ["pamixer", "-i", "10"]
    volumedown:
      launch: ["pamixer", "-d", "10"]
    mute:
      launch: ["pamixer", "--toggle-mute"]

    brightnessup:
      launch: ["brightnessctl", "s", "10%+"]
    brightnessdown:
      launch: ["brightnessctl", "s", "10%-"]

    super-l:
      remap:
        l:
          launch: ["fuzzel", "-p", "❯  ", "-b", "2A2B3DFF", "-s", "AD8EE6FF", "-t", "DDDDDDFF", "-S", "DDDDDDFF"]
        t:
          launch: ["kitty"]
        w:
          launch: ["firefox"]
        c:
          launch: ["gnome-calculator"]
        f:
          launch: ["nautilus"]
        d:
          launch: ["discord"]
        v:
          launch: ["pavucontrol"]
        y:
          launch: ["freetube"]

    super-w:
      remap:
        c:
          { set_mode: workspace }
${numRowBinds (x: let tabs = 4; n = if x.num != 0 then x.num else 10; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["hyprctl", "dispatch", "workspace", "${toString n}"]''
)}

    super-m:
      remap:
        c:
          { set_mode: move }
${numRowBinds (x: let tabs = 4; n = if x.num != 0 then x.num else 10; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["hyprctl", "dispatch", "movetoworkspace", "${toString n}"]''
)}

    super-g:
      remap:
${numRowBinds (x: let tabs = 4; n = if x.num != 0 then x.num else 10; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["hyprctl", "dispatch", "movetoworkspacesilent", "${toString n}"]''
)}

    super-y:
      remap:
        y:
          launch: ["${bashExec}", "${yankSearch}/bin/run"]
        d:
          launch: ["${bashExec}", "${yankDisplay}/bin/run"]
        c:
          launch: ["${bashExec}", "${yankColor}/bin/run"]
${numRowBinds (x: let tabs = 4; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["${bashExec}", "${copyTo}/bin/run ${toString x.num}"]''
)}

    super-p:
      remap:
        p:
          launch: ["${bashExec}", "${paste}/bin/run"]
        l:
          launch: ["${bashExec}", "${pasteLast}/bin/run"]
        f:
          launch: ["${bashExec}", "${pasteSearch}/bin/run"]
${numRowBinds (x: let tabs = 4; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["${bashExec}", "${pasteFrom}/bin/run ${toString x.num}"]''
)}

    super-s:
      remap:
        s:
          launch: ["${bashExec}", "${bitwardenSearch}/bin/run"]
  mode: default

- name: workspace mode
  remap:
    Enter:
      { set_mode: default }
    right:
      launch: ["hyprctl", "dispatch", "workspace", "r+1"]
    left:
      launch: ["hyprctl", "dispatch", "workspace", "r-1"]
  mode: workspace

- name: move mode
  remap:
    Enter:
      { set_mode: default }
    right:
      launch: ["hyprctl", "dispatch", "movetoworkspace", "r+1"]
    left:
      launch: ["hyprctl", "dispatch", "movetoworkspace", "r-1"]
  mode: move
''
