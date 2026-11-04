# claude-profile-manager

Standalone zsh commands for running [Claude Code](https://claude.ai) under isolated, per-profile configuration — no `.zshrc` functions to source, just a command in your `PATH`.

## Why

If you use Claude Code for multiple contexts (personal, different clients, different employers...), each one needs its own config, credentials and session state. This project keeps each profile in its own `~/.claude-<name>/` directory and gives you a `claude-cli` command to switch between them instantly, without touching your shell startup files.

## Features

- Standalone executable — no `.zshrc` loading, fast shell startup
- Auto-discovers profiles from `~/.claude-*` directories
- Project-local default profile via a `.claude-profile-manager.conf` file
- Zsh tab completion for profile names
- iTerm2 tab badge showing the active profile

## Installation

```bash
git clone <this-repo-url>
cd claude-profile-manager
./scripts/install-commands.sh
```

This symlinks `claude-cli` into `~/.local/bin` (or `/usr/local/bin` if run with `sudo`) and offers to set up tab completion. No sudo is required for a per-user install.

To remove it: `./scripts/uninstall-commands.sh`.

## Usage

Create a profile by making a directory for it:

```bash
mkdir -p ~/.claude-perso
mkdir -p ~/.claude-work
```

Then launch Claude with a given profile:

```bash
claude-cli perso
claude-cli work --help   # extra args are passed through to `claude`
```

Each profile gets its own `CLAUDE_CONFIG_DIR` at `~/.claude-<profile>/cli`, so sessions, credentials and settings never leak between profiles.

With no arguments, `claude-cli` lists the profiles it found under `~/.claude-*`.

### Project-local default profile

Drop a `.claude-profile-manager.conf` file in a project (or any parent directory, up to `$HOME`) to pick its profile automatically:

```
# .claude-profile-manager.conf
profile=work
```

Running `claude-cli` with no arguments from inside that project (or a subdirectory of it) will use that profile without having to type it.

### Tab completion

`./scripts/install-commands.sh` offers to install it, or run `./scripts/install-completions.sh` directly. Once installed, reload your shell and press TAB after `claude-cli `.

## Repository layout

```
commands/    claude-cli (and any local-only extras — see below)
lib/         shared shell helpers (profile discovery, config parsing, colors, completion logic)
completions/ zsh completion scripts
scripts/     install/uninstall scripts for commands and completions
```

## Note on `claude-app`

A `claude-app` command (same idea, but for the Claude.app macOS GUI) is still in development and is intentionally **not** tracked in this repository yet — see `.gitignore`. It swaps Claude.app's macOS `Library` data per profile, which is more invasive and more machine-specific than the CLI case, and isn't stable enough to publish. It's kept locally for now and may be added to the repo later once it's solid.
