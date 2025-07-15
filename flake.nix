{
  description = "A nix-darwin module to declaratively set the default web browser on macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    {
      # The main darwin module
      darwinModules.default-browser = import ./modules/default-browser.nix;
      
      # Alias for convenience
      darwinModules.default = self.darwinModules.default-browser;
    };
}