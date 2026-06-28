#!/usr/bin/env bash
# fzf-palette is meant to be sourced by an interactive Bash session.
FZF_PALETTE_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$FZF_PALETTE_HOME/modules/common.sh"
source "$FZF_PALETTE_HOME/modules/cd.sh"
source "$FZF_PALETTE_HOME/modules/git.sh"
source "$FZF_PALETTE_HOME/modules/r.sh"

# The bind guard keeps syntax checks and non-interactive shells quiet.
if [[ $- == *i* ]]; then
  bind -x '"\eg": fzf_palette'
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
      if [[ -z "${rest//[[:space:]]/}" ]]; then
        _fzf_cd
      fi
      ;;
    git)
      _fzf_git "$rest"
      ;;
    r)
      _fzf_r "$rest"
      ;;
    *)
      return
      ;;
  esac
}
