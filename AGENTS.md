# Repository Guidelines

## Project Structure & Module Organization

This repository contains a small Bash extension for contextual `fzf` pickers.
The main source file is `src/fzf-palette.bash`, which defines the `Ctrl-G`
readline binding, dispatch logic, shared helpers, and common pickers. Git
command handling lives in `src/git.bash`. `install.sh` installs the tool by
symlinking `src/` to `~/.fzf-palette` and adding a source line to `~/.fzf.bash`.

Documentation lives in `README.md` and `docs/`. Use `docs/bindings.md` for
details about key bindings and interaction design. Put future maintenance
helpers in `scripts/` and tests or fixtures in `test/`.

## Build, Test, and Development Commands

There is no build step; this is sourced Bash code.

- `bash -n src/fzf-palette.bash`: check the main script for syntax errors.
- `bash -n src/git.bash`: check git command helpers for syntax errors.
- `bash -n install.sh`: check the installer for syntax errors.
- `source ./install.sh`: install and load the binding into the current shell.
- `./install.sh`: install persistently, then restart the shell or run
  `source ~/.fzf.bash`.

Manual testing should happen in an interactive Bash terminal with `fzf`,
`fdfind`, `git`, and `batcat` available.

## Coding Style & Naming Conventions

Use Bash with two-space indentation. Prefer `local` variables inside functions,
quoted expansions, and small helpers for repeated behavior. Internal functions
should use the `_fzf_palette_*` prefix unless they are command-specific
pickers such as `_fzf_cd` or `_fzf_git`.

Keep interactive behavior centralized in `_fzf_palette_fzf()` so layout and
key bindings stay consistent. Preserve shell quoting through
`_fzf_palette_shell_quote()` when inserting paths into `READLINE_LINE`.

## Testing Guidelines

At minimum, run both syntax checks before committing:

```bash
bash -n src/fzf-palette.bash
bash -n src/git.bash
bash -n install.sh
```

For behavior changes, manually verify the relevant picker from an interactive
shell. Examples: type `cd` then press `Ctrl-G`, type `git checkout` then press
`Ctrl-G`, and confirm the selected value updates the readline buffer.

## Commit & Pull Request Guidelines

The current history uses concise, imperative commit messages, for example
`Initial fzf-palette implementation`. Continue using short subject lines that
describe the user-visible change.

Pull requests should include a brief summary, manual test notes, and any
terminal-specific caveats. Mention changes to default bindings, `fzf` layout,
installer behavior, or required external commands.
