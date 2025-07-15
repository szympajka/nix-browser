{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.defaultBrowser;
  
  # Validate that browser name is safe (alphanumeric, dash, underscore only)
  validBrowserName = browser: 
    builtins.match "^[a-zA-Z0-9_-]+$" browser != null;
    
  # Escape shell arguments safely
  escapeShellArg = arg: "'${builtins.replaceStrings ["'"] ["'\"'\"'"] arg}'";
in
{
  options.services.defaultBrowser = {
    enable = mkEnableOption "Set the default browser using defaultbrowser";
    browser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The browser identifier to set as default (e.g. "firefox", "chrome", "safari", "librewolf").
        Run `defaultbrowser` in the terminal to see available options.
        If unset, no browser will be set, but a hint will be shown.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Validation
    assertions = [
      {
        assertion = cfg.browser == null || validBrowserName cfg.browser;
        message = "services.defaultBrowser.browser must contain only alphanumeric characters, dashes, and underscores. Got: ${toString cfg.browser}";
      }
    ];

    environment.systemPackages = [ pkgs.defaultbrowser ];

    launchd.user.agents.defaultBrowser = mkIf (cfg.browser != null) {
      serviceConfig = {
        Label = "org.nixos.default-browser";
        ProgramArguments = [ 
          "/bin/sh" "-c" 
          ''
            set -euo pipefail
            
            # Check if defaultbrowser is available
            if ! command -v ${escapeShellArg "${pkgs.defaultbrowser}/bin/defaultbrowser"} >/dev/null 2>&1; then
              echo "Error: defaultbrowser command not found" >&2
              exit 1
            fi
            
            # Get current default browser safely
            current=$(${escapeShellArg "${pkgs.defaultbrowser}/bin/defaultbrowser"} | grep '^[[:space:]]*\*' | sed 's/^[[:space:]]*\*[[:space:]]*//' | head -n1 || echo "unknown")
            target=${escapeShellArg cfg.browser}
            
            # Only change if different
            if [ "$current" != "$target" ]; then
              echo "Setting default browser from '$current' to '$target'"
              ${escapeShellArg "${pkgs.defaultbrowser}/bin/defaultbrowser"} "$target"
            else
              echo "Default browser is already set to '$target'"
            fi
          ''
        ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/org.nixos.default-browser.stderr";
        StandardOutPath = "/tmp/org.nixos.default-browser.stdout";
      };
    };

    system.activationScripts.defaultBrowser = {
      text = 
        if cfg.browser != null then ''
          echo "🌐 Default Browser: Setting default browser to '${cfg.browser}'"
          echo "   The browser will be set automatically on next login via launchd service"
          echo "   Logs available at: /tmp/org.nixos.default-browser.stdout"
        '' else ''
          echo "🌐 Default Browser: Module enabled but no browser configured"
          echo "   Add 'services.defaultBrowser.browser = \"firefox\";' to set a default browser"
          echo "   Run 'defaultbrowser' to see available browsers"
        '';
    };
  };
}
