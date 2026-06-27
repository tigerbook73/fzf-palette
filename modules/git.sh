_fzf_git_command_candidates() {
  printf '%s\n' \
    'add' \
    'branch' \
    'checkout' \
    'commit' \
    'diff' \
    'fetch' \
    'log' \
    'merge' \
    'pull' \
    'push' \
    'rebase' \
    'restore' \
    'status' \
    'stash' \
    'switch'
}

_fzf_git_complete_command() {
  local prefix="$1"
  local matches
  local count
  local selected

  # Complete immediately only when the typed prefix maps to one curated command.
  matches=$(_fzf_git_command_candidates | while IFS= read -r command; do
    [[ "$command" == "$prefix"* ]] && printf '%s\n' "$command"
  done)
  count=$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')

  if [[ "$count" -eq 1 ]]; then
    selected="$matches"
  else
    if [[ "$count" -eq 0 ]]; then
      matches=$(_fzf_git_command_candidates)
    fi
    selected=$(printf '%s\n' "$matches" | _fzf_palette_fzf --prompt='git> ' --query "$prefix")
  fi

  [[ -n "$selected" ]] && {
    READLINE_LINE="git $selected "
    READLINE_POINT=${#READLINE_LINE}
  }
}

_fzf_git_has_command_prefix() {
  local prefix="$1"

  while IFS= read -r command; do
    [[ "$command" == "$prefix"* ]] && return 0
  done < <(_fzf_git_command_candidates)

  return 1
}

_fzf_git_has_exact_command() {
  local value="$1"

  while IFS= read -r command; do
    [[ "$command" == "$value" ]] && return 0
  done < <(_fzf_git_command_candidates)

  return 1
}

_fzf_git() {
  local subcmd="$1"

  case "$subcmd" in
    "" | " "*)
      _fzf_git_complete_command ""
      ;;

    switch | switch\ *)
      _fzf_git_switch_branch
      ;;

    branch | branch\ )
      # "git branch" has no picker by itself; the user must type -d or -D.
      return
      ;;

    branch\ -*)
      local branch_subcmd="${subcmd#branch }"

      if [[ "$branch_subcmd" == "-d" || "$branch_subcmd" == "-d "* || "$branch_subcmd" == "-D" || "$branch_subcmd" == "-D "* ]]; then
        _fzf_git_delete_branch "$branch_subcmd"
      else
        return
      fi
      ;;

    *)
      if ! _fzf_git_has_exact_command "$subcmd" && _fzf_git_has_command_prefix "$subcmd"; then
        _fzf_git_complete_command "$subcmd"
      fi
      ;;
  esac
}

_fzf_git_local_branch_candidates() {
  git branch --format='%(refname:short)' 2>/dev/null
}

_fzf_git_switch_branch_candidates() {
  # Switch can target local branches and remote-tracking branches.
  # Local branches are emitted first, then remotes, with duplicates removed.
  {
    _fzf_git_local_branch_candidates
    git branch --remotes --format='%(refname:short)' 2>/dev/null \
      | grep -vE '(^|/)HEAD$'
  } | awk '!seen[$0]++'
}

_fzf_git_switch_branch() {
  local branch
  branch=$(_fzf_git_switch_branch_candidates | _fzf_palette_fzf)

  [[ -n "$branch" ]] && {
    READLINE_LINE="git switch $branch"
    READLINE_POINT=${#READLINE_LINE}
  }
}

_fzf_git_delete_branch() {
  local branch_subcmd="$1"
  # Preserve whether the user typed -d or -D in the generated command.
  local flag="${branch_subcmd%% *}"
  local current
  current=$(git branch --show-current 2>/dev/null)

  local candidates
  candidates=$(_fzf_git_local_branch_candidates)
  # Do not offer the checked-out branch for deletion.
  [[ -n "$current" ]] && candidates=$(echo "$candidates" | grep -vxF "$current")

  local branches
  branches=$(echo "$candidates" \
    | _fzf_palette_fzf --multi \
    | paste -s -d' ')

  [[ -n "$branches" ]] && {
    READLINE_LINE="git branch $flag $branches"
    READLINE_POINT=${#READLINE_LINE}
  }
}
