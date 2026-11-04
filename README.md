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

<details open>
<summary>Manual installation</summary>

```bash
ln -s "$(pwd)/commands/claude-cli" ~/.local/bin/
chmod +x ~/.local/bin/claude-cli

# Make sure ~/.local/bin is in your PATH, e.g. in ~/.zshrc:
export PATH="$HOME/.local/bin:$PATH"
exec zsh
```

</details>

### Verify installation

```bash
which claude-cli
# ~/.local/bin/claude-cli (or /usr/local/bin/claude-cli)

claude-cli
# with no profiles yet, prints "Missing profile name" and an empty
# "Available profiles:" list
```

## Usage

### Basic syntax

```bash
claude-cli <profile-name> [claude options...]
```

Everything after `<profile-name>` is forwarded as-is to the real `claude` command.

### Create a profile

Profiles are just directories — create one and it's picked up automatically:

```bash
mkdir -p ~/.claude-perso
mkdir -p ~/.claude-work
```

```bash
claude-cli perso
```

Each profile gets its own `CLAUDE_CONFIG_DIR` at `~/.claude-<profile>/cli`, so sessions, credentials and settings never leak between profiles.

### List available profiles

```bash
claude-cli
# with no argument (and no .claude-profile-manager.conf found), lists the
# profiles discovered under ~/.claude-*

# or manually:
ls -d ~/.claude-*/
```

### Pass arguments through to `claude`

Any flag that isn't the profile name goes straight to the real `claude` CLI:

```bash
claude-cli perso -p "hey"    # one-off prompt
claude-cli perso --help      # claude's own help
claude-cli perso --version
```

### Project-local default profile

Drop a `.claude-profile-manager.conf` file in a project (or any parent directory, up to `$HOME`) to pick its profile automatically:

```
# .claude-profile-manager.conf
profile=work
```

Running `claude-cli` with no arguments from inside that project (or a subdirectory of it) will use that profile without having to type it.

### Tab completion

`./scripts/install-commands.sh` offers to install it, or run `./scripts/install-completions.sh` directly. Once installed, reload your shell and press TAB after `claude-cli `.

### Tips

Want shorter commands? Add aliases in `~/.zshrc`:

```bash
alias cperso="claude-cli perso"
alias cwork="claude-cli work"
```

`claude-cli` can also be used in scripts, e.g. to pipe output or run in the background:

```bash
claude-cli perso | tee session.log
claude-cli work &
```

## Troubleshooting

**Command not found**

```bash
echo $PATH   # make sure the install dir (e.g. ~/.local/bin) is listed
export PATH="$HOME/.local/bin:$PATH"
exec zsh
```

**Profile not discovered**

```bash
ls -la ~/.claude-perso   # create it if missing
mkdir -p ~/.claude-perso
```

**`claude` CLI not found**

`claude-cli` requires the `claude` command itself to be installed and on your `PATH` — see https://claude.ai.

**Tab completion not working**

```bash
ls ~/.zsh/completions/_claude-cli   # or ~/.oh-my-zsh/completions/_claude-cli
exec zsh
# still nothing? rebuild the completion cache:
rm -f ~/.zcompdump* && exec zsh
```

## Repository layout

```
commands/    claude-cli (and any local-only extras — see below)
lib/         shared shell helpers (profile discovery, config parsing, colors, completion logic)
completions/ zsh completion scripts
scripts/     install/uninstall scripts for commands and completions
```

## Note on `claude-app`

A `claude-app` command (same idea, but for the Claude.app macOS GUI) is still in development and is intentionally **not** tracked in this repository yet — see `.gitignore`. It swaps Claude.app's macOS `Library` data per profile, which is more invasive and more machine-specific than the CLI case, and isn't stable enough to publish. It's kept locally for now and may be added to the repo later once it's solid.
