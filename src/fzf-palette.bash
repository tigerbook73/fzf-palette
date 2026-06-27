# fzf-palette is meant to be sourced by an interactive Bash session.
FZF_PALETTE_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The bind guard keeps syntax checks and non-interactive shells quiet.
if [[ $- == *i* ]]; then
  bind -x '"\C-g": fzf_palette'
fi

fzf_palette() {
  local line="$READLINE_LINE"
  local cmd="${line%% *}"
  local rest=""

  # Keep the dispatcher simple: the first word chooses a contextual picker,
  # and the remaining buffer is passed to that command family.
  if [[ "$line" == *" "* ]]; then
    rest="${line#* }"
  fi

  case "$cmd" in
    cd)
      _fzf_cd
      ;;
    git)
      _fzf_git "$rest"
      ;;
    *)
      _fzf_global
      ;;
  esac
}

_fzf_palette_shell_quote() {
  printf '%q' "$1"
}

_fzf_palette_append_arg() {
  local arg
  arg=$(_fzf_palette_shell_quote "$1")

  if [[ -n "$READLINE_LINE" ]]; then
    READLINE_LINE="$READLINE_LINE $arg"
  else
    READLINE_LINE="$arg"
  fi
}

_fzf_palette_fzf() {
  # Match fzf's Bash integration defaults for a compact, non-fullscreen picker.
  fzf --height 40% --min-height 20+ --layout=reverse --bind=ctrl-z:ignore "$@"
}

_fzf_global() {
  local action
  action=$(printf '%s\n' \
    'cd' \
    'git' \
    'file' \
    | _fzf_palette_fzf --prompt='fzf-palette> ')

  case "$action" in
    cd)
      _fzf_cd
      ;;
    git)
      _fzf_git ""
      ;;
    file)
      _fzf_file
      ;;
  esac
}

_fzf_file() {
  local file
  file=$(_fzf_palette_fzf)

  [[ -n "$file" ]] && {
    # Append the selected file to whatever command the user already typed.
    _fzf_palette_append_arg "$file"
    READLINE_POINT=${#READLINE_LINE}
  }
}

_fzf_cd() {
  local dir
  # Search from the current directory and rely on fdfind's default ignore rules.
  dir=$(fdfind . . --type d 2>/dev/null | _fzf_palette_fzf)

  [[ -n "$dir" ]] && {
    READLINE_LINE="cd $(_fzf_palette_shell_quote "$dir")"
    READLINE_POINT=${#READLINE_LINE}
    # Ask the terminal for status so readline receives ESC[0n and accepts line.
    bind '"\e[0n": accept-line'
    printf '\e[5n'
  }
}

source "$FZF_PALETTE_HOME/git.bash"
