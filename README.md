# SpireNet Website

Service directory landing page for SpireNet infrastructure.

## Development

### Prerequisites
- Nix with flakes enabled

### Local Development

Enter the development shell:
```bash
nix develop
```

Test the website locally:
```bash
python -m http.server 8000 -d site
```

Then visit http://localhost:8000

## Building

Build the website package:
```bash
nix build
```

The built website will be in `./result/`

## Usage in NixOS Configuration

This flake is consumed as an input in the main nix-config:

```nix
inputs.spirenet-website.url = "github:yourusername/spirenet-website";
```

## Structure

- `site/` - Website source files
- `flake.nix` - Nix flake configuration
- `flake.lock` - Locked dependency versions

## License

MIT
