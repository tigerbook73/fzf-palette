#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/src"
LINK="$HOME/.fzf-palette"
FZF_BASH="$HOME/.fzf.bash"
SOURCE_LINE="[ -f \"$LINK/fzf-palette.bash\" ] && source \"$LINK/fzf-palette.bash\""

# 创建 symlink
if [ -L "$LINK" ] && [ "$(readlink "$LINK")" = "$SRC" ]; then
  echo "symlink already up-to-date: $LINK"
else
  ln -sf "$SRC" "$LINK"
  echo "created symlink: $LINK -> $SRC"
fi

# 在 ~/.fzf.bash 中追加 source 语句（幂等）
if [ ! -f "$FZF_BASH" ]; then
  touch "$FZF_BASH"
fi

if grep -qF "$LINK" "$FZF_BASH"; then
  echo "source line already present in $FZF_BASH"
else
  echo "" >> "$FZF_BASH"
  echo "# fzf-palette" >> "$FZF_BASH"
  echo "$SOURCE_LINE" >> "$FZF_BASH"
  echo "added source line to $FZF_BASH"
fi

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  # When this installer is sourced, load the binding into the current shell too.
  source "$LINK/fzf-palette.bash"
  echo "loaded fzf-palette in current shell"
else
  echo "done. restart your shell or run: source $FZF_BASH"
  echo "to install and load immediately, run: source ./install.sh"
fi
