# --- Git aliases (plain git, no wrapper: every repo behaves normally) --------
alias gst='git status'
alias gau='git add -u' # add only changed files, but this will not recognise or add new files.
alias ga.='git add .'  # add all files, new ones too.
alias gc='git commit -m '
alias gpsh='git push origin main'
alias gpll='git pull origin main'
alias gl='git log --oneline'

bindkey -s '^Xgs' 'git status\n'
bindkey -s '^Xga' 'git add -u\n' # the trailing \n runs it right away, no need to press enter. Only works with bindkey, not with alias
bindkey -s '^Xg.' 'git add .\n'
bindkey -s '^Xgc' 'git commit -m ""\C-b'
bindkey -s '^Xgp' 'git push origin main'
bindkey -s '^Xgl' 'git log --oneline -n 10\n'
