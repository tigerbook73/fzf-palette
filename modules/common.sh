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
  local header="${READLINE_LINE:- }"
  local header_bind='focus:transform-header:printf "cmd> %s %s" "$FZF_PALETTE_HEADER" "$FZF_CURRENT_ITEM"'

  # Trim leading and trailing whitespace using Bash parameter expansion.
  # This avoids spawning sed on every interactive picker open.
  header="${header#"${header%%[![:space:]]*}"}"
  header="${header%"${header##*[![:space:]]}"}"

  if [[ "${FZF_PALETTE_STATIC_HEADER:-}" == "1" ]]; then
    header_bind='focus:transform-header:printf "cmd> %s ..." "$FZF_PALETTE_HEADER"'
  fi

  # Match fzf's Bash integration defaults for a compact, non-fullscreen picker.
  # FZF_PALETTE_HEADER is scoped to this fzf process so transform-header can
  # read the original readline buffer while fzf provides FZF_CURRENT_ITEM.
  FZF_PALETTE_HEADER="$header" fzf --height 40% --min-height 20+ --layout=reverse \
    --header="cmd> $header${FZF_PALETTE_STATIC_HEADER:+ ...}" \
    --bind=ctrl-z:ignore \
    --bind="$header_bind" \
    "$@"
}
