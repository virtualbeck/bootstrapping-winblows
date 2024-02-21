# Windows Bootstrapping
Forked from justmiles/bootstrapping-winblows, if not already apparent.
Bootstrap your Windows desktop like a boss.

## Quick Steps

1. Launch Powershell as an admin to run the `admin_*.ps1` files in the `powershell_scripts` directory. These scripts:

    - install the majority of end-user desktop software
    - remove some bloatware
    - install WSL

2. Launch Powershell as a normal user to run the remaining `uininstall_bloatware.ps1` script. This script:

    - Removes the majority of anti-features Windows provides

3. Let's start on the NixOS install. Download this pre-built NixOS installation and import it into a WSL distirbution called "NixOS"
    
    ```powershell
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/nix-community/NixOS-WSL/releases/download/2311.5.3/nixos-wsl.tar.gz", "$HOME\Downloads\nixos-wsl.tar.gz")

    # Import NixOS
    wsl --import NixOS "$HOME\NixOS" "$HOME\Downloads\nixos-wsl.tar.gz" --version 2

    # Create a "workspaces" folder to persist your working documents outside of WSL
    wsl -d NixOS /run/current-system/sw/bin/mkdir -p "/mnt/c/Users/$env:USERNAME/Documents/workspaces"
    wsl -d NixOS /run/current-system/sw/bin/ln -s "/mnt/c/Users/$env:USERNAME/Documents/workspaces" "/home/nixos/workspaces"
    
    # Launch NixOS
    wsl --distribution NixOS
    ```

5. From inside of WSL, update channels

    ```bash
    sudo nix-channel --update
    ```

6. Clone this repo
    
    ```bash
    cd ~/workspaces
    nix-shell -p git
    git clone https://github.com/justmiles/bootstrapping-winblows.git
    cd bootstrapping-winblows
    ```

7. Update `wsl/flake.nix` to set your username 

    ```bash
    grep "username =" wsl/flake.nix
    vi wsl/flake.nix
    ```

8. Rebuild using the latest

    ```bash
    sudo nixos-rebuild switch --flake ./wsl
    ```

9. Use the `wsl -d NixOS` to launch the shell or open http://localhost:3000 for an integrated development environment

10. Fork this repo and start making changes to build out your own environment.

    - check out https://search.nixos.org for packages and flakes
