{
  config,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    bat
    bash
    bottom
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
    lunarvim
    mosh
    mlocate
    neovim
    procs
    ripgrep
    sd
    tmux
    tree
    unzip
    wget
    zip
  ];

  stable-packages = with pkgs; [
    # daemons
    openvscode-server
    
    # key tools
    gh
    awscli2
    ssm-session-manager-plugin
    go-2fa
    pipx
    pwgen
    terraform-docs
    packer
    rclone
    drone-cli
    nomad
    pre-commit
    tfswitch
    gnumake
    xclip

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
    pkgs.nodePackages.vscode-langservers-extracted # html, css, json, eslint
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
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nano";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/bash";
  };

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      # pkgs.some-package
      # pkgs.unstable.some-other-package
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
  };
}