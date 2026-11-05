# --- Keyboard Bindings -------------------------------------------------------
bindkey -e                   # Emacs-style keybindings

# Home, End, Insert, Delete, Backspace and the arrows, from terminfo, so they work in
# every terminal. Terminals send these codes in "application mode": on while you edit.
typeset -gA key=(
    Home   "${terminfo[khome]}"  End  "${terminfo[kend]}"   Insert "${terminfo[kich1]}"
    Delete "${terminfo[kdch1]}"  BackSpace "${terminfo[kbs]}"
    Up     "${terminfo[kcuu1]}"  Down "${terminfo[kcud1]}"  Left "${terminfo[kcub1]}"  Right "${terminfo[kcuf1]}"
)
for k w in Home beginning-of-line End end-of-line Insert overwrite-mode Delete delete-char \
           BackSpace backward-delete-char Up up-line-or-history Down down-line-or-history \
           Left backward-char Right forward-char; do
    [[ -n ${key[$k]} ]] && bindkey -- "${key[$k]}" $w
done
unset k w
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    zle-line-init() { echoti smkx }
    zle-line-finish() { echoti rmkx }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# Learning notes:
# Ctrl + F (Forward) = Right Arrow
# Ctrl + B (Backward) = Left Arrow
# Ctrl + A (Ahead) = Home
# Ctrl + E (End) = End
# Ctrl + P (Previous) = Up Arrow
# Ctrl + N (Next) = Down Arrow
# Ctrl + W (Undo) = Deletes last string
# Ctrl + _ (Redo) = Shift + _

# Fallback / explicit bindings
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey "^[[3~" delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Edit command line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line
bindkey '^X^E' edit-command-line

# Ctrl+U: kill whole line
kill-whole-line-custom() { BUFFER=""; CURSOR=0; }
zle -N kill-whole-line-custom
bindkey '^U' kill-whole-line-custom

# Alt+H: show help for current command
(( ${+aliases[run-help]} )) && unalias run-help
autoload -Uz run-help
