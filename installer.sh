#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR"
LINK="$HOME/.fzf-palette"
FZF_BASH="$HOME/.fzf.bash"
SOURCE_LINE="[ -f \"$LINK/core/dispatcher.sh\" ] && source \"$LINK/core/dispatcher.sh\""
BEGIN_MARKER="# >>> fzf-palette >>>"
END_MARKER="# <<< fzf-palette <<<"

info() {
  printf '[fzf-palette] %s\n' "$*"
}

usage() {
  cat <<'EOF'
Usage:
  ./installer.sh install
  ./installer.sh uninstall
EOF
}

install_fzf_palette() {
  info "installing"

  if [ -L "$LINK" ] && [ "$(readlink "$LINK")" = "$SRC" ]; then
    info "link ok: $LINK -> $SRC"
  else
    ln -sf "$SRC" "$LINK"
    info "link created: $LINK -> $SRC"
  fi

  if [ ! -f "$FZF_BASH" ]; then
    touch "$FZF_BASH"
    info "created shell config: $FZF_BASH"
  fi

  if grep -qF "$SOURCE_LINE" "$FZF_BASH"; then
    info "shell config already contains source line: $FZF_BASH"
  else
    {
      echo ""
      echo "$BEGIN_MARKER"
      echo "$SOURCE_LINE"
      echo "$END_MARKER"
    } >> "$FZF_BASH"
    info "shell config updated: $FZF_BASH"
  fi

  info "done"
  info "reload shell: source ~/.bashrc"
}

uninstall_fzf_palette() {
  info "uninstalling"

  if [ -L "$LINK" ]; then
    rm "$LINK"
    info "link removed: $LINK"
  else
    info "link not found: $LINK"
  fi

  if [ -f "$FZF_BASH" ]; then
    # Remove both the current managed block and older standalone source lines.
    local tmp_file
    local old_source_line
    tmp_file="${FZF_BASH}.tmp.$$"
    old_source_line="[ -f \"$LINK/fzf-palette.bash\" ] && source \"$LINK/fzf-palette.bash\""

    awk \
      -v begin="$BEGIN_MARKER" \
      -v end="$END_MARKER" \
      -v current="$SOURCE_LINE" \
      -v old="$old_source_line" \
      '
        $0 == begin { skip = 1; next }
        $0 == end { skip = 0; next }
        skip { next }
        $0 == current || $0 == old { next }
        { print }
      ' "$FZF_BASH" > "$tmp_file"

    if cmp -s "$tmp_file" "$FZF_BASH"; then
      rm "$tmp_file"
      info "shell config unchanged: $FZF_BASH"
    else
      mv "$tmp_file" "$FZF_BASH"
      info "shell config cleaned: $FZF_BASH"
    fi
  else
    info "shell config not found: $FZF_BASH"
  fi

  info "done"
}

command="${1:-install}"

case "$command" in
  install)
    install_fzf_palette
    ;;
  uninstall)
    uninstall_fzf_palette
    ;;
  -h | --help | help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
