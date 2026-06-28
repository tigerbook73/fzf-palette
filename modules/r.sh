_fzf_r() {
  local args="$1"
  local cmd
  # shellcheck disable=SC2086
  cmd=$(r --print-command $args 2>/dev/null)

  if [[ -n "${cmd//[[:space:]]/}" ]]; then
    READLINE_LINE="$cmd "
    READLINE_POINT=${#READLINE_LINE}
  fi
}
