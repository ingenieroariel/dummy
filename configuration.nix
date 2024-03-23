{ config, lib, pkgs, ... }:
let
   pkgs = import ./nixpkgs {};
   lib = pkgs.lib;
in
{
  imports =
    [ 
      ./hardware-configuration.nix
      ./nixos-apple-silicon/apple-silicon-support
    ];
#  services.xserver.enable = true;
#  services.xserver.displayManager.sddm.enable = true;
#  services.xserver.desktopManager.plasma5.enable = true;

   networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.asahi.experimentalGPUInstallMode = "overlay";
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.withRust = true;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  sound.enable = true;
  networking.hostName = "nunez";
  networking.defaultGateway = "96.246.216.1";
  networking.interfaces.end0.ipv4.addresses  = [{ address="96.246.216.234"; prefixLength=24;}];
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 22 ];# 50 80 443 6680 ];
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"] ; 
  time.timeZone = "America/Eastern";
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" ];
    };
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
     neovim
     ripgrep
     arcan
     glmark2
     htop

   ];
 
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MESSAGES = "en_US.UTF-8";
    LANGUAGE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
  };  
  users.mutableUsers = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.binsh = "${pkgs.dash}/bin/dash";

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "yes";
  system.copySystemConfiguration = true;

  system.stateVersion = "24.05";

   users.users.root.openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPecl97dfX0SoGjx8juIVVmy09B7k9JZgFHw7BeBc6S0 root@nixos"
     ];

}

