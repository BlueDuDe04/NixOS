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

  moveWorkspace = pkgs.writeShellScriptBin "run" ''
    swaymsg move workspace number $1 && swaymsg workspace number $1
  '';

  yankSearch = pkgs.writeShellScriptBin "run" ''
    cliphist list | wofi -d | cliphist decode | wl-copy
  '';

  yankScreen = pkgs.writeShellScriptBin "run" ''
    grim -g "$(slurp)" - | wl-copy
  '';

  copyTo = pkgs.writeShellScriptBin "run" ''wl-paste -n | cb cp$1'';

  paste = pkgs.writeShellScriptBin "run" ''wl-paste -n | wtype -'';

  pasteLast = pkgs.writeShellScriptBin "run" ''
    cliphist list | sed -n 2p | cliphist decode | wtype -
  '';

  pasteSearch = pkgs.writeShellScriptBin "run" ''
    cliphist list | wofi -d | cliphist decode | wtype -
  '';

  pasteFrom = pkgs.writeShellScriptBin "run" ''cb p$1 | wtype -'';

  bitwardenSearch = pkgs.writeShellScriptBin "run" ''
    rbw get "$(rbw unlock; rbw list | wofi -d)" | tr -d '\n' | wtype -
  '';
in ''
keymap:
- name: Bindings
  remap:
    super-l:
      remap:
        l:
          launch: ["wofi", "--show", "drun"]
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
${numRowBinds (x: let tabs = 4; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["swaymsg", "workspace", "number", "${toString x.num}"]''
)}

    super-g:
      remap:
${numRowBinds (x: let tabs = 4; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["swaymsg", "move", "workspace", "number", "${toString x.num}"]''
)}

    super-m:
      remap:
${numRowBinds (x: let tabs = 4; in ''
  ${tab tabs}${x.key}: # ${toString x.num}
    ${tab tabs}launch: ["${bashExec}", "${moveWorkspace}/bin/run ${toString x.num}"]''
)}

    super-y:
      remap:
        y:
          launch: ["${bashExec}", "${yankSearch}/bin/run"]
        c:
          launch: ["${bashExec}", "${yankScreen}/bin/run"]
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
''
