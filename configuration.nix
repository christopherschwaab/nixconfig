# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  #boot.loader.grub.enable = true;
  #boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  #boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 0;
  boot.resumeDevice = "";
  boot.tmpOnTmpfs = true;

  networking.hostName = "dang"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  #networking.networkmanager.packages = [ pkgs.networkmanagerapplet ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
  #   consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  system.activationScripts.ldso = lib.stringAfter [ "usrbinenv" ] ''                       
    mkdir -m 0755 -p /lib64                                                                
    ln -sfn ${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2.tmp   
    mv -f /lib64/ld-linux-x86-64.so.2.tmp /lib64/ld-linux-x86-64.so.2 # atomically replace 
  '';          

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.ld-linux = true;
  environment.systemPackages =
    let py3 = pkgs.python3.override {
                packageOverrides = self: super: {
                  patch-ng = self.buildPythonPackage rec {
                    pname = "patch-ng";
                    version = "1.17.2";

                    src = self.fetchPypi {
                      inherit pname version;
                      sha256 = "5150c9e624e45be5d51f0288d20393cdfd8cfa44682b0c76a4a14c0dce6cca0a";
                    };
                    meta = {
                      description = "dang";
                      homepage = "https://github.com/conan-io/python-patch-ng";
                    };
                  };
                };
              };
        freerdpgit = pkgs.freerdp.overrideAttrs (attrs: rec {
          #version = "master";
          version = "stable-1.1";
          src = pkgs.fetchFromGitHub {
             owner  = "FreeRDP";
             repo   = "FreeRDP";
             #rev    = "cf2f674283e17c06e1bda8183186603885066527";
             rev    = "${version}";
             sha256 = "01cm9g4xqihnnc5d2w1zs8gabkv59p7fyjwi1cwpzv6s198xwbfs";
           };
        });
    in with (pkgs // { python3 = py3; }); 
         let conan1222 = conan.overridePythonAttrs (attrs: rec {
               version = "1.22.2";
               propagatedBuildInputs = attrs.propagatedBuildInputs ++ [
                                         python3.pkgs.patch-ng
                                         python3.pkgs.dateutil
                                         python3.pkgs.jinja2
                                       ];
               src = attrs.src.override {
                 inherit version;
                 sha256 = "e2bd415776df79ab56f42b60ecb1dbf2b489e7d80774967f1a7478d658de2586";
               };
             });
             remmina141 = remmina.overrideAttrs (attrs: rec {
               # version = "v1.4.1";
               version = "3f0ef8fc96d0ea51a750db0a853483f339726e6f";
               src = fetchFromGitLab {
                   owner  = "Remmina";
                   repo   = "Remmina";
                   rev    = "${version}";
                   sha256 = "084yw0fd3qmzzd6xinhf4plv5bg8gfj4jnfac7zi1nif8zilf456";
               };
               buildInputs = [
                 gsettings-desktop-schemas
                 glib gtk3 gettext xorg.libxkbfile xorg.libX11
                 freerdpgit libssh libgcrypt gnutls
                 pcre libdbusmenu-gtk3 libappindicator-gtk3
                 libvncserver xorg.libpthreadstubs xorg.libXdmcp libxkbcommon
                 libsecret libsoup spice-protocol spice-gtk epoxy at-spi2-core
                 openssl gnome3.adwaita-icon-theme json-glib
                 libsodium webkitgtk harfbuzz
               ];
             });
         in [
           multipath-tools
           ntfs3g
           xorg.xhost
           zstd
           edk2
           OVMF-CSM
           OVMF
           spice_gtk
           qemu_kvm
           unetbootin
           gparted
           flatpak
           freerdpgit
           wget
           vim
           firefox
           xwayland
           wayland
           xterm
           sway
           mesa
           gcc
           gdb
           cgdb
           binutils
           gnumake
           dmenu
           ghc
           git
           lynx
           chromium
           emacs
           libinput
           libevdev
           pciutils
           file
           py3
           nox 
           acpilight
           i3
           patchelf
           cmake
           pkg-config
           freetype
           expat
           gptfdisk
           mako
           networkmanagerapplet
           libappindicator
           tmux
           xorg.xrdb
           cabal2nix
           carnix
           rustup
           wl-clipboard
           neovim
           exa
           fd
           ripgrep
           bat
           alacritty
           haskellPackages.Agda
           fzf
           gitAndTools.diff-so-fancy
           bash-completion
           nix-bash-completions
           android-studio
           android-udev-rules
           xvfb_run
           xorg.xorgserver
           xorg.xinit
           grpc
           protobuf3_9
           nodejs-12_x
           conan1222
           dive
           gradle
           docker-compose
           nixops
           tree
           python37Packages.pip
           cabal-install
           ansible
           mupdf
           radare2
           sbt
           scala
           adoptopenjdk-bin
           unzip
           shfmt
           gitAndTools.tig
           coq
           ocaml
           bear
           rtags
           pavucontrol
           (steam.override { extraPkgs = pkgs: [
                               electron_6
                               gnome3.libsecret
                             ];
                             nativeOnly = true;
                           }).run
       ];

  fonts = {
    enableDefaultFonts = true;
    fonts = [ 
      pkgs.ubuntu_font_family
      pkgs.source-code-pro
      pkgs.source-sans-pro
      pkgs.source-serif-pro
      pkgs.fira-code
    ];
  
    fontconfig = {
      penultimate.enable = false;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu" ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable Flatpak
  xdg.portal.enable = true;
  services.flatpak.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser pkgs.brgenml1lpr ];

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  nixpkgs.config.allowUnfree = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;
    layout = "gb";
    libinput.enable = true;
  };
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the Gnome
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome3.enable = true;

  # Brightness
  hardware.brightnessctl.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "networkmanager"
      "docker"
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  # OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  powerManagement.enable = true;
  programs.zsh.enable = true;

  # Without any `nix.nixPath` entry:
  #nix.nixPath =
  #  # Prepend default nixPath values.
  #  options.nix.nixPath.default ++ 
  #  # Append our nixpkgs-overlays.
  #  [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];
  virtualisation.docker.enable = true;
}

