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

_fzf_git_branch_command_candidates() {
  printf '%s\n' '-d'
}

_fzf_git_complete_command() {
  local prefix="$1"
  local matches
  local count
  local selected

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

_fzf_git_complete_branch_command() {
  local prefix="$1"
  local matches
  local count
  local selected

  matches=$(_fzf_git_branch_command_candidates | while IFS= read -r command; do
    [[ "$command" == "$prefix"* ]] && printf '%s\n' "$command"
  done)
  count=$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')

  if [[ "$count" -eq 1 ]]; then
    selected="$matches"
  else
    if [[ "$count" -eq 0 ]]; then
      matches=$(_fzf_git_branch_command_candidates)
    fi
    selected=$(printf '%s\n' "$matches" | _fzf_palette_fzf --prompt='git branch> ' --query "$prefix")
  fi

  [[ -n "$selected" ]] && {
    READLINE_LINE="git branch $selected "
    READLINE_POINT=${#READLINE_LINE}
  }
}

_fzf_git() {
  local subcmd="$1"

  case "$subcmd" in
    "" | " "*)
      _fzf_git_complete_command ""
      ;;

    checkout | checkout\ *)
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

    branch | branch\ )
      _fzf_git_complete_branch_command ""
      ;;

    branch\ -*)
      local branch_subcmd="${subcmd#branch }"

      if [[ "$branch_subcmd" == "-d" || "$branch_subcmd" == "-d "* ]]; then
        _fzf_git_delete_branch
      else
        _fzf_git_complete_branch_command "$branch_subcmd"
      fi
      ;;

    *)
      if ! _fzf_git_has_exact_command "$subcmd" && _fzf_git_has_command_prefix "$subcmd"; then
        _fzf_git_complete_command "$subcmd"
      fi
      ;;
  esac
}

_fzf_git_delete_branch() {
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
    READLINE_LINE="git branch -d $branches"
    READLINE_POINT=${#READLINE_LINE}
  }
}
