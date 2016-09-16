CURRENT_BG='NONE'

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
  PL_BRANCH_CHAR=$'\ue0a0' # 
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    #prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@%m"
    prompt_segment black default "%(!.%{%F{yellow}%}.)\uf21b"
  fi
}

git_status() {
  # Outputs a series of indicators based on the status of the
  # working directory:
  # + changes are staged and ready to commit
  # ! unstaged changes are present
  # ? untracked files are present
  # S changes have been stashed
  # P local commits need to be pushed to the remote
  local status output
  status="$(git status --porcelain 2>/dev/null)"
  [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="$output+"
  [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="$output!"
  [[ -n $(egrep '^\?\?' <<<"$status") ]] && output="$output?"
  [[ -n $(git stash list) ]] && output="${output}S"
  [[ -n $(git log --branches --not --remotes) ]] && output="${output}P"
  [[ -n $output ]] && output="|$output"  # separate from branch name
  echo $output
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  #if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
  if [[ -n $repo_path ]]; then
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst

    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${mode}"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue black '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}\uf00d"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}\uf13d"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}\uf16c"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
#PROMPT='%~%<< $(git_prompt_info)${PR_BOLD_WHITE}>%{${reset_color}%} '
