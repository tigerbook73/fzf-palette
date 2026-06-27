# fzf-palette

`fzf-palette` is a small Bash extension that uses `fzf` and `bind -x` to turn
the current readline buffer into contextual pickers.

## Install

```bash
./install.sh
source ~/.fzf.bash
```

The installer symlinks `src/fzf-palette.bash` to `~/.fzf-palette` and adds a
source line to `~/.fzf.bash`.

To install and load the binding into the current shell immediately:

```bash
source ./install.sh
```

## Usage

Press `Ctrl-G` in an interactive Bash shell.

- Empty or unknown commands open an action picker first.
- `cd` opens a directory picker and replaces the line with `cd <dir>`.
- `git checkout` opens a branch picker.
- `git branch -d` and `git branch -D` open a multi-select branch picker.
- Other `git` buffers open a changed-file picker and generate `git add <file>`.

## Dependencies

- Bash with readline support
- `fzf`
- `fdfind`
- `git`
- `batcat`
