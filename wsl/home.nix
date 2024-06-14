{ config
, pkgs
, username
, nix-index-database
, nix-vscode-extensions
, ...
}:
let
  stable-packages = with pkgs; [
    # key tools
    bat
    bashInteractive
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    killall
    ripgrep
    sd
    tree
    unzip
    wget
    zip
    gh
    awscli2
    ssm-session-manager-plugin
    go-2fa
    pipx
    pwgen
    packer
    rclone
    drone-cli
    nomad
    pre-commit
    tfswitch
    gnumake
    xclip
    nixpkgs-fmt
    nil
    meld
    fastfetch
    postgresql

    # core languages
    go
    python3

    # local dev stuf
    rsync
    unzip
    jq

    # language servers
    ccls # c / c++
    gopls
    gdlv
    nodePackages.typescript-language-server
    nodePackages.yaml-language-server
    sumneko-lua-language-server
    nil # nix
    nodePackages.pyright

    # formatters and linters
    alejandra # nix
    black # python
    ruff # python
    deadnix # nix
    golangci-lint
    lua52Packages.luacheck
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    sqlfluff
    tflint
    hclfmt

  ];

  extensionsList = with nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
    # Golang
    golang.go

    # Terrafom
    hashicorp.terraform
    hashicorp.hcl

    # Python
    ms-python.python

    # Java
    redhat.java
    vscjava.vscode-lombok

    # Nix
    jnoortheen.nix-ide

    # Generic language parsers / prettifiers
    esbenp.prettier-vscode
    redhat.vscode-yaml
    jkillian.custom-local-formatters

    # Generic tools
    eamodio.gitlens
    jebbs.plantuml

    # DB stuff
    mtxr.sqltools
    mtxr.sqltools-driver-pg

    # Eye candy
    pkief.material-icon-theme
    zhuangtongfa.material-theme

    # Misc
    jkillian.custom-local-formatters
  ];

in
{
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "22.11"; # no touching (https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion)

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nano";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/bash";
  };

  home.packages =
    stable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      (pkgs.callPackage ../github_binaries/codegpt.nix { })
      (pkgs.callPackage ../github_binaries/ecs.nix { })
    ];

  home.file = {
    Downloads.source = config.lib.file.mkOutOfStoreSymlink "/mnt/c/Users/${username}/Documents/workspaces";
    Downloads.target = "workspaces";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bashrc;
  };

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    vscode = {
      enable = true;
      extensions = extensionsList;
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;

      keybindings = [
        {
          key = "ctrl+q";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+d";
          command = "editor.action.copyLinesDownAction";
          when = "editorTextFocus && !editorReadonly";
        }
      ];

      userSettings = {
        "git.autorefresh" = true;
        "workbench.colorTheme" = "Visual Studio Dark";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "newUntitledFile";
        "editor.renderWhitespace" = "all";
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "extensions.ignoreRecommendations" = true;
        "extensions.autoCheckUpdates" = false;
        "explorer.confirmDelete" = false;
        "extensions.autoUpdate" = false;
        "files.watcherExclude" = {
          "**/vendor/**" = true;
          "**/.config/**" = true;
        };
        "gitlens.mode.statusBar.enabled" = false;
        "gitlens.hovers.currentLine.over" = "line";
        "explorer.confirmDragAndDrop" = false;
        "redhat.telemetry.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.scrollback" = 10000;
        "[terraform]" = {
          "editor.defaultFormatter" = "hashicorp.terraform";
        };
        "[hcl]" = {
          "editor.defaultFormatter" = "jkillian.custom-local-formatters";
        };
        "files.associations" = {
          "*.hcl" = "hcl";
          "*.nomad" = "hcl";
          "*.nomad.hcl" = "hcl";
          "*.pkr.hcl" = "hcl";
          "flake.lock" = "json";
        };
        "customLocalFormatters.formatters" = [
          {
            "command" = "${pkgs.hclfmt}/bin/hclfmt";
            "languages" = [ "hcl" ];
          }
        ];
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "nixpkgs-fmt";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = { "command" = [ "nixpkgs-fmt" ]; };
          };
        };
        "go.toolsManagement.autoUpdate" = false;
        "go.coverOnSave" = true;
        "go.coverageDecorator" = {
          "type" = "gutter";
          "coveredHighlightColor" = "rgba(64,128,128,0.5)";
          "uncoveredHighlightColor" = "rgba(128,64,64,0.25)";
          "coveredGutterStyle" = "blockgreen";
          "uncoveredGutterStyle" = "blockred";
        };
        "go.coverOnSingleTest" = true;
      };
    };
  };
}
