#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------
__fzf_select__() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  eval "$cmd" | FZF_DEFAULT_OPTS="--reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read -r item; do
    printf '%q ' "$item"
  done
  echo
}

if [[ $- =~ i ]]; then

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  local selected="$(__fzf_select__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

__fzf_cd__() {
  local cmd dir
  cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="--reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m) && printf 'cd %q' "$dir"
}

__fzf_history__() {
  local output
  output=$(
    builtin fc -lnr -2147483648 |
      last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
      FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m --read0" $(__fzfcmd) --query "$READLINE_LINE"
  ) || return
  READLINE_LINE=${output#*$'\t'}
  if [ -z "$READLINE_POINT" ]; then
    echo "$READLINE_LINE"
  else
    READLINE_POINT=0x7fffffff
  fi
}

# Required to refresh the prompt after fzf
bind -m emacs-standard '"\er": redraw-current-line'

bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
bind -m emacs-standard '"\C-z": vi-editing-mode'

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  # CTRL-T - Paste the selected file path into the command line
  bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
  bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'

  # CTRL-R - Paste the selected command from history into the command line
  bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u"$(__fzf_history__)"\e\C-e\er"'
  bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
  bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
else
  # CTRL-T - Paste the selected file path into the command line
  bind -m emacs-standard -x '"\C-t": fzf-file-widget'
  bind -m vi-command -x '"\C-t": fzf-file-widget'
  bind -m vi-insert -x '"\C-t": fzf-file-widget'

  # CTRL-R - Paste the selected command from history into the command line
  bind -m emacs-standard -x '"\C-r": __fzf_history__'
  bind -m vi-command -x '"\C-r": __fzf_history__'
  bind -m vi-insert -x '"\C-r": __fzf_history__'
fi

# ALT-C - cd into the selected directory
bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\ec": "\C-z\ec\C-z"'
bind -m vi-insert '"\ec": "\C-z\ec\C-z"'



# GIT heart FZF
# -------------
# as seen on https://junegunn.kr/2016/07/fzf-git/
# https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf "$@" --border
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d && cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

bind '"\er": redraw-current-line'
bind -m vi-command '"\C-g\C-f": "$(gf)\e\C-e\er"'
bind -m vi-command '"\C-g\C-b": "$(gb)\e\C-e\er"'
bind -m vi-command '"\C-g\C-t": "$(gt)\e\C-e\er"'
bind -m vi-command '"\C-g\C-h": "$(gh)\e\C-e\er"'
bind -m vi-command '"\C-g\C-r": "$(gr)\e\C-e\er"'
bind -m vi-insert '"\C-g\C-f": "$(gf)\e\C-e\er"'
bind -m vi-insert '"\C-g\C-b": "$(gb)\e\C-e\er"'
bind -m vi-insert '"\C-g\C-t": "$(gt)\e\C-e\er"'
bind -m vi-insert '"\C-g\C-h": "$(gh)\e\C-e\er"'
bind -m vi-insert '"\C-g\C-r": "$(gr)\e\C-e\er"'

fi
