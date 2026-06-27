# fzf-palette is meant to be sourced by an interactive Bash session.
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
    'git checkout' \
    'git add' \
    'git branch -d' \
    'git branch -D' \
    'file' \
    | _fzf_palette_fzf --prompt='fzf-palette> ')

  case "$action" in
    cd)
      _fzf_cd
      ;;
    "git checkout")
      _fzf_git "checkout"
      ;;
    "git add")
      _fzf_git ""
      ;;
    "git branch -d")
      _fzf_git "branch -d"
      ;;
    "git branch -D")
      _fzf_git "branch -D"
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

_fzf_git() {
  local subcmd="$1"

  case "$subcmd" in
    checkout*)
      local branch
      # Include local and remote branch names, then normalize origin/foo to foo.
      branch=$(git branch --all --format='%(refname:short)' 2>/dev/null \
        | sed 's#^origin/##' \
        | sort -u \
        | _fzf_palette_fzf)

      [[ -n "$branch" ]] && {
        READLINE_LINE="git checkout $branch"
        READLINE_POINT=${#READLINE_LINE}
      }
      ;;

    "branch -d"* | "branch -D"*)
      local flag
      flag=$(echo "$subcmd" | grep -oE -- '-[dD]')

      local current
      current=$(git branch --show-current 2>/dev/null)

      local candidate
      candidate=$(git branch --format='%(refname:short)' 2>/dev/null)
      # Do not offer the checked-out branch for deletion.
      [[ -n "$current" ]] && candidate=$(echo "$candidate" | grep -vxF "$current")

      local branches
      branches=$(echo "$candidate" \
        | _fzf_palette_fzf --multi \
        | paste -s -d' ')

      [[ -n "$branches" ]] && {
        READLINE_LINE="git branch $flag $branches"
        READLINE_POINT=${#READLINE_LINE}
      }
      ;;

    *)
      local file
      # Default git action: select one changed path and prepare a git add.
      file=$(git -c color.status=always status --short 2>/dev/null \
        | _fzf_palette_fzf --ansi \
        | sed -E 's/^.{3}//; s/^.* -> //')

      [[ -n "$file" ]] && {
        READLINE_LINE="git add $(_fzf_palette_shell_quote "$file")"
        READLINE_POINT=${#READLINE_LINE}
      }
      ;;
  esac
}
