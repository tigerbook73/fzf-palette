# fzf-palette

`fzf-palette` is a small Bash extension that uses `fzf` and `bind -x` to turn
the current readline buffer into contextual pickers.

## Install

```bash
./installer.sh install
source ~/.bashrc
```

The installer symlinks this repository directory to `~/.fzf-palette` and adds a
source line for `core/dispatcher.sh` to `~/.fzf.bash`.

To uninstall:

```bash
./installer.sh uninstall
```

## Usage

Press `Alt-G` in an interactive Bash shell.

- Empty or unknown commands are left unchanged.
- `cd` opens a directory picker when there is no existing argument, then runs
  the generated `cd <dir>` command.
- `git` opens a common git command picker.
- `git <prefix>` completes directly when the prefix has one command match.
- `git switch` opens a branch picker.
- `git branch -d` and `git branch -D` open a multi-select branch picker.

The picker displays the current command line in its header. As you move through
items, the header updates to show the command that would be generated.

## Git Support

The `git` picker uses a curated list of common commands:

```text
add
branch
checkout
commit
diff
fetch
log
merge
pull
push
rebase
restore
status
stash
switch
```

Only selected commands have deeper picker support:

- `git switch <Alt-G>` selects from local branches first, then remote branches.
- `git branch -d <Alt-G>` selects one or more local branches to delete.
- `git branch -D <Alt-G>` selects one or more local branches to force-delete.

Generated git commands are inserted into the command line; they are not executed
automatically.

## Dependencies

- Bash with readline support
- `fzf`
- `fdfind`
- `git`
- `batcat`

## Development

```bash
./test.sh
```

Runs Bash syntax checks for the installer, core dispatcher, and modules.
