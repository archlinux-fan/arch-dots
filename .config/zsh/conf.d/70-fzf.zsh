# --- FZF ---------------------------------------------------------------------
# Ctrl+R history, Ctrl+T files, Alt+C folders, each in a searchable list.
(( $+commands[fzf] )) && eval "$(fzf --zsh)"

# Nord colours: frost for matches, polar night for the selected line
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --marker='*' --pointer='▶' --color='fg:-1,bg:-1,hl:#88c0d0,fg+:#eceff4,bg+:#434c5e,hl+:#8fbcbb,info:#4c566a,prompt:#81a1c1,pointer:#81a1c1,marker:#a3be8c,border:#4c566a'"
export FZF_CTRL_T_COMMAND="find . -type f -not -path '*/.*' | sort"
export FZF_CTRL_T_OPTS="--preview 'cat {} | head -n 50' --bind 'ctrl-h:change-prompt(All Files> )+reload(find . -type f | sort)'"
export FZF_ALT_C_COMMAND="find . -type d -not -path '*/.*' -not -path '.' | sort"
export FZF_ALT_C_OPTS="--preview 'ls -F {} | head -n 50' --bind 'ctrl-h:change-prompt(All Folders> )+reload(find . -type d -not -path \".\" | sort)'"
