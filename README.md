# nix-darwin Default Browser Module

A [nix-darwin](https://github.com/LnL7/nix-darwin) module that allows you to declaratively set the default web browser on macOS.

## Features

- 🌐 Set default browser declaratively in your nix-darwin configuration
- 🔄 Automatically checks if browser is already set to avoid unnecessary popups
- 📦 Includes the `defaultbrowser` CLI tool
- ⚡ Runs efficiently via launchd user agents

## Usage

### As a Flake Input

Add this flake as an input to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    default-browser.url = "github:szympajka/nix-browser";
  };

  outputs = { self, nixpkgs, nix-darwin, default-browser, ... }: {
    darwinConfigurations."your-hostname" = nix-darwin.lib.darwinSystem {
      modules = [
        default-browser.darwinModules.default-browser
        ./configuration.nix
      ];
    };
  };
}
```

### Configuration

Add the following to your nix-darwin configuration:

```nix
{
  services.defaultBrowser = {
    enable = true;
    browser = "firefox";  # or "chrome", "safari", "dia", etc.
  };
}
```

### Available Browsers

To see available browsers on your system, run:

```bash
defaultbrowser
```

Common browser identifiers:
- `firefox`
- `chrome` 
- `safari`
- `dia`
- `edge`
- `opera`
- `brave`

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.defaultBrowser.enable` | boolean | `false` | Whether to enable the default browser module |
| `services.defaultBrowser.browser` | string or null | `null` | Browser identifier to set as default |

## How It Works

1. **Installation**: The module installs the `defaultbrowser` CLI tool
2. **Configuration**: A launchd user agent is created when a browser is specified
3. **Execution**: On login, the agent checks if the current default browser matches your configuration
4. **Setting**: Only changes the default browser if it's different, preventing unnecessary popups

## Requirements

- nix-darwin

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
