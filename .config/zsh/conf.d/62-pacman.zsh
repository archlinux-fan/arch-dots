# --- Pacman (Arch) -----------------------------------------------------------
# No pacman -Sy alone: syncing without upgrading, then installing, is a partial
# upgrade that can break the system.
alias pacin="sudo pacman -S"
alias pacup="sudo pacman -Syu"
alias pacupi='~/.config/waybar/scripts/updates.sh upgrade'   # the updates with descriptions, then pacman -Syu
alias pacrm="sudo pacman -Rns"
alias paccl="sudo pacman -Sc"     # old versions out of the cache; -Scc would also drop the current ones
alias pacco="pacman -Qtdq"
alias pacsr="pacman -Ss"          # search packages by name and description

# Removes the orphans found right now (an alias with $(...) would use the list
# from when the shell started).
pacro() {
    local -a orphans
    orphans=(${(f)"$(pacman -Qtdq 2>/dev/null)"})
    if (( ${#orphans} == 0 )); then
        echo "No orphaned packages to remove."
        return 0
    fi
    sudo pacman -Rns "${orphans[@]}"
}

# With fzf: search with a preview, install the picked ones, files of all packages
alias pacs="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
alias pinst="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -r sudo pacman -S"
alias pfile="pacman -Ql | fzf"
