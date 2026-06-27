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
  # Keep fzf anchored below the prompt instead of taking over the whole screen.
  fzf --height 30 --layout=reverse --preview-window=hidden --bind 'ctrl-/:toggle-preview' "$@"
}

_fzf_global() {
  local file
  file=$(_fzf_palette_fzf --preview 'batcat --color=always {} 2>/dev/null || cat {}')

  [[ -n "$file" ]] && {
    # Append the selected file to whatever command the user already typed.
    _fzf_palette_append_arg "$file"
    READLINE_POINT=${#READLINE_LINE}
  }
}

_fzf_cd() {
  local dir
  # Search from the current directory and skip high-noise directories.
  dir=$(fdfind . . --type d \
    --exclude .git --exclude node_modules --exclude .cache \
    --exclude __pycache__ --exclude target --exclude dist \
    2>/dev/null \
    | _fzf_palette_fzf --preview 'ls -1 --color=always {}')

  [[ -n "$dir" ]] && {
    READLINE_LINE="cd $(_fzf_palette_shell_quote "$dir")"
    READLINE_POINT=${#READLINE_LINE}
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
        | _fzf_palette_fzf --preview 'git log --oneline --color=always -15 {}')

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
        | _fzf_palette_fzf --multi --preview 'git log --oneline --color=always -15 {}' \
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
        | _fzf_palette_fzf --ansi --preview 'file=$(printf "%s" {} | sed -E "s/^.{3}//; s/^.* -> //"); git diff --color=always -- "$file"' \
        | sed -E 's/^.{3}//; s/^.* -> //')

      [[ -n "$file" ]] && {
        READLINE_LINE="git add $(_fzf_palette_shell_quote "$file")"
        READLINE_POINT=${#READLINE_LINE}
      }
      ;;
  esac
}
