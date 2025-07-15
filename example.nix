# Example nix-darwin configuration using the default-browser module

{
  services.defaultBrowser = {
    enable = true;
    browser = "firefox";
  };

  # Other nix-darwin configuration...
  system.stateVersion = 4;
}
