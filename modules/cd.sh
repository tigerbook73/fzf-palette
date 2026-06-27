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
