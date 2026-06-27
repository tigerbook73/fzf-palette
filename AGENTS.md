# Repository Guidelines

## Project Structure & Module Organization

This repository contains a small Bash extension for contextual `fzf` pickers.
The main entrypoint is `core/dispatcher.sh`, which defines the `Alt-G`
readline binding and dispatch logic. Shared helpers live in `modules/common.sh`;
command handlers live in `modules/`, such as
`modules/cd.sh` and `modules/git.sh`. `installer.sh` installs the tool by
symlinking the repository directory to `~/.fzf-palette` and adding a source line
to `~/.fzf.bash`.

`README.md` is the user guide. Keep internal structure and maintenance guidance
in this file.

## Build, Test, and Development Commands

There is no build step; this is sourced Bash code.

- `./test.sh`: run syntax checks for all Bash files in the runtime path.
- `bash -n core/dispatcher.sh`: check the main dispatcher for syntax errors.
- `bash -n modules/git.sh`: check git command helpers for syntax errors.
- `bash -n installer.sh`: check the installer for syntax errors.
- `./installer.sh install`: install persistently, then restart the shell or run
  `source ~/.bashrc`.

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
bash -n core/dispatcher.sh
bash -n modules/common.sh
bash -n modules/cd.sh
bash -n modules/git.sh
bash -n installer.sh
```

For behavior changes, manually verify the relevant picker from an interactive
shell. Examples: type `cd` then press `Alt-G`, type `git switch` then press
`Alt-G`, and confirm the selected value updates the readline buffer.

## Commit & Pull Request Guidelines

The current history uses concise, imperative commit messages, for example
`Initial fzf-palette implementation`. Continue using short subject lines that
describe the user-visible change.

Pull requests should include a brief summary, manual test notes, and any
terminal-specific caveats. Mention changes to default bindings, `fzf` layout,
installer behavior, or required external commands.
