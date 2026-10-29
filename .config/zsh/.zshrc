# /etc/zsh/zshrc — system-wide zshrc (all users including root)
# ~/.config/zsh/.zshrc — for Arch Linux (via ZDOTDIR in ~/.zshenv)
# Merged: custom .zshrc + Debian/Ubuntu system defaults

# --- Distro Detection --------------------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO="unknown"
fi

# --- Completion System -------------------------------------------------------
if [[ "$DISTRO" == "arch" ]]; then
    zstyle :compinstall filename "$ZDOTDIR/.zshrc"
elif [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    zstyle :compinstall filename "/etc/zsh/zshrc"
    export EDITOR=nano
    export VISUAL=nano
else # OPNsense if it's different? Fix later!
    zstyle :compinstall filename "/etc/zsh/zshrc"
    export EDITOR=nano
    export VISUAL=nano
fi

autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                                           /usr/sbin /usr/bin /sbin /bin

# --- History -----------------------------------------------------------------
if [[ "$DISTRO" != "arch" ]]; then
    HISTFILE=~/.histfile
fi
# On Arch, HISTFILE is defined in ~/.zshenv

HISTSIZE=10000
SAVEHIST=10000

# --- General History Options -------------------------------------------------
setopt SHARE_HISTORY          # Share history between different terminal sessions
setopt APPEND_HISTORY         # Append to history file instead of overwriting
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate commands from history
setopt HIST_SAVE_NO_DUPS      # Do not write duplicate commands to history file
setopt HIST_IGNORE_SPACE      # Don't record commands starting with a space
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history commands
setopt HIST_FIND_NO_DUPS      # Do not display a line previously found during search
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when history is full

# --- General Behavior --------------------------------------------------------
setopt autocd                # cd into directory by typing its name
setopt extendedglob          # Advanced pattern matching
setopt INTERACTIVE_COMMENTS  # Console doesn't reject commands when # is present
setopt nomatch               # Error if no matches found for a pattern
setopt notify                # Instant background job status
unsetopt correct             # Spellcheck for commands (e.g., sl -> ls)
setopt prompt_subst          # Allow functions/variables in prompt
unsetopt beep                # Disable system beep
bindkey -e                   # Emacs-style keybindings

stty -ixon   # Disable Ctrl+S terminal freeze

READNULLCMD=${PAGER:-/usr/bin/pager}

# --- Keyboard Bindings -------------------------------------------------------
# bind2maps: apply a keybinding across multiple keymaps at once.
# Handles Home/End/Delete/Arrows correctly for emacs, viins and vicmd.
if [[ -z "${DEBIAN_PREVENT_KEYBOARD_CHANGES-}" ]] && [[ "$TERM" != 'emacs' ]]; then

    typeset -A key
    key=(
        BackSpace  "${terminfo[kbs]}"
        Home       "${terminfo[khome]}"
        End        "${terminfo[kend]}"
        Insert     "${terminfo[kich1]}"
        Delete     "${terminfo[kdch1]}"
        Up         "${terminfo[kcuu1]}"
        Down       "${terminfo[kcud1]}"
        Left       "${terminfo[kcub1]}"
        Right      "${terminfo[kcuf1]}"
        PageUp     "${terminfo[kpp]}"
        PageDown   "${terminfo[knp]}"
    )

    function bind2maps () {
        local i sequence widget
        local -a maps
        while [[ "$1" != "--" ]]; do
            maps+=( "$1" )
            shift
        done
        shift
        sequence="${key[$1]}"
        widget="$2"
        [[ -z "$sequence" ]] && return 1
        for i in "${maps[@]}"; do
            bindkey -M "$i" "$sequence" "$widget"
        done
    }

    bind2maps emacs             -- BackSpace   backward-delete-char
    bind2maps       viins       -- BackSpace   vi-backward-delete-char
    bind2maps             vicmd -- BackSpace   vi-backward-char
    bind2maps emacs             -- Home        beginning-of-line
    bind2maps       viins vicmd -- Home        vi-beginning-of-line
    bind2maps emacs             -- End         end-of-line
    bind2maps       viins vicmd -- End         vi-end-of-line
    bind2maps emacs viins       -- Insert      overwrite-mode
    bind2maps             vicmd -- Insert      vi-insert
    bind2maps emacs             -- Delete      delete-char
    bind2maps       viins vicmd -- Delete      vi-delete-char
    bind2maps emacs viins vicmd -- Up          up-line-or-history
    bind2maps emacs viins vicmd -- Down        down-line-or-history
    bind2maps emacs             -- Left        backward-char
    bind2maps       viins vicmd -- Left        vi-backward-char
    bind2maps emacs             -- Right       forward-char
    bind2maps       viins vicmd -- Right       vi-forward-char

    if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
        function zle-line-init () { emulate -L zsh; printf '%s' ${terminfo[smkx]}; }
        function zle-line-finish () { emulate -L zsh; printf '%s' ${terminfo[rmkx]}; }
        zle -N zle-line-init
        zle -N zle-line-finish
    fi

    unfunction bind2maps

fi

# --- Keyboard Bindings -------------------------------------------------------
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

# --- PROMPT ------------------------------------------------------------------
autoload -U colors && colors

if [[ $EUID -eq 0 ]]; then
    HOSTCOLOR="red"
    USER_SYMBOL="#"
elif [[ -n "$SSH_CONNECTION" ]]; then
    HOSTCOLOR="yellow"
    USER_SYMBOL="$"
else
    HOSTCOLOR="blue"
    USER_SYMBOL="$"
fi

PROMPT='%B%F{magenta}@%F{$HOSTCOLOR}%m %F{white}%~ %F{$HOSTCOLOR}${USER_SYMBOL}%b%f '

# --- Aliases -----------------------------------------------------------------
alias sudo='sudo '


# Package Management
if [[ "$DISTRO" == "arch" ]]; then
    alias pacin="sudo pacman -S"
    alias pacsy="sudo pacman -Sy"
    alias pacsyy="sudo pacman -Syy"
    alias pacup="sudo pacman -Syu"
    alias pacupi='sudo pacman -Sy && echo "" && printf "\e[1;37m%-20s   %s\e[0m\n" "Package" "Description" && pacman -Qu | cut -d" " -f1 | xargs -r pacman -Si | awk -F": " "/^Name/ {name=\$2} /^Description/ {printf \"%-20s   %s\n\", name, \$2}" && echo "" && sudo pacman -Su'
    alias pacrm="sudo pacman -Rns"
    alias paccl="sudo pacman -Scc"
    alias pacco="pacman -Qtdq"
    # NOTE: this used to be `alias pacro="sudo pacman -Rns $(pacman -Qtdq)"` — the
    # $(...) ran IMMEDIATELY when this line executed (i.e. at shell startup), so
    # pacro always removed the same "frozen" orphan list from when the terminal
    # was opened, not the actual orphans at the time you ran the command. Replaced
    # with a function that re-runs `pacman -Qtdq` fresh every time pacro is called.
    pacro() {
        local -a orphans
        orphans=(${(f)"$(pacman -Qtdq 2>/dev/null)"})
        if (( ${#orphans} == 0 )); then
            echo "No orphaned packages to remove."
            return 0
        fi
        sudo pacman -Rns "${orphans[@]}"
    }
    alias pacs="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
    alias pinst="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -r sudo pacman -S"
    alias pfile="pacman -Ql | fzf"

    # --- Git aliases (plain git, no wrapper — every repo behaves normally) ----
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

elif [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    alias aptup="sudo apt update && sudo apt dist-upgrade"
    alias aptin="sudo apt install"
    alias aptrm="sudo apt autoremove --purge"
    alias apts="apt search"
fi

# System
alias jourerr="sudo journalctl -p 3 -b"
alias failed="systemctl --failed"
alias rmc="rm -rf .cache/*"
alias h="history | grep "
alias p="ps aux | grep "
alias cls='clear'
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias bd='cd "$OLDPWD"'

# Listing
alias ls='ls -F --color=always'
alias lsa='ls -A'
alias lsl='ls -lh'
alias lsla='ls -Alh'
alias lst='ls -ltrh'
alias lss='ls -lSrh'
alias lsdir="ls -l | grep -E '^d'"
alias lsf="ls -l | grep -E -v '^d'"
alias lsfa="ls -Al | grep -E -v '^d'"

# Tools & Search
alias mx='chmod a+x'
alias f="find . | grep "
alias -g C="| wl-copy "
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -a"
alias openports='netstat -nape --inet'
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# Docker Compose
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcp='docker compose pull'
alias dcl='docker compose logs -f'
alias dcps='docker compose ps'
alias dps='docker ps'
alias dst='dodocker stats --no-streams'
alias dcr='docker compose restart'
alias dipr='docker image prune'
alias dipra='docker image prune -a'
alias dcpr='docker container prune'
alias dcpra='docker container prune -a'
alias dnpr='docker network prune'
alias dnpra='docker network prune -a'
alias dbpr='docker builder prune'
alias dbpra='docker builder prune -a'
alias dspr='docker system prune'
alias dspra='docker system prune -a'
alias dsprv='docker system prune --volumes'
alias dsprva='docker system prune --volumes -a'

# --- FZF ---------------------------------------------------------------------
(( $+commands[fzf] )) && eval "$(fzf --zsh)"

export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --marker='*' --pointer='▶' --color='fg:-1,bg:-1,hl:#ff5555,fg+:#ffffff,bg+:#44475a,hl+:#ff5555'"
export FZF_CTRL_T_COMMAND="find . -type f -not -path '*/.*' | sort"
export FZF_CTRL_T_OPTS="--preview 'cat {} | head -n 50' --bind 'ctrl-h:change-prompt(All Files> )+reload(find . -type f | sort)'"
export FZF_ALT_C_COMMAND="find . -type d -not -path '*/.*' -not -path '.' | sort"
export FZF_ALT_C_OPTS="--preview 'ls -F {} | head -n 50' --bind 'ctrl-h:change-prompt(All Folders> )+reload(find . -type d -not -path \".\" | sort)'"

bindkey '^R' fzf-history-widget

# --- Plugins -----------------------------------------------------------------
# Sequential check for plugin paths based on system
plugin_paths=(
    "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
)
for plugin in $plugin_paths; do
    [ -f "$plugin" ] && source "$plugin"
done

# --- Welcome Message ---------------------------------------------------------
if [[ -o interactive ]]; then

    # Prints `text` centered to the terminal width, with one blank line above it.
    # $2 (optional) is a "R;G;B" truecolor foreground to print it in; omitted = plain/default color.
    _print_centered() {
        local text="$1"
        local color="$2"
        local width=$(tput cols)
        local pad=$(( (width - ${#text}) / 2 ))
        (( pad < 0 )) && pad=0
        echo
        if [[ -n "$color" ]]; then
            printf "%${pad}s\e[1;38;2;${color}m%s\e[0m\n" "" "$text"
        else
            printf "%${pad}s\e[1m%s\e[0m\n" "" "$text"
        fi
    }

    case "$DISTRO" in
        arch)
            padding=$(( ($(tput cols) - 15) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;46;52;64;48;2;94;129;172m A \e[0m \e[38;2;46;52;64;48;2;129;161;193m R \e[0m \e[38;2;46;52;64;48;2;136;192;208m C \e[0m \e[38;2;46;52;64;48;2;143;188;187m H \e[0m\n"
            ;;
        ubuntu)
            padding=$(( ($(tput cols) - 23) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;255;255;255;48;2;233;84;32m U \e[0m \e[38;2;255;255;255;48;2;225;59;24m B \e[0m \e[38;2;255;255;255;48;2;173;33;72m U \e[0m \e[38;2;255;255;255;48;2;119;33;111m N \e[0m \e[38;2;255;255;255;48;2;94;39;80m T \e[0m \e[38;2;255;255;255;48;2;76;34;70m U \e[0m\n"
            # $VERSION comes from the sourced /etc/os-release and on Ubuntu already
            # contains the point version + codename, e.g. "26.04.1 LTS (Resolute Raccoon)"
            # Color 233;84;32 is the first Ubuntu square's background (the orange tile).
            _print_centered "$VERSION" "233;84;32"
            echo
            echo
            ;;
        debian)
            padding=$(( ($(tput cols) - 23) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;255;255;255;48;2;168;0;45m D \e[0m \e[38;2;255;255;255;48;2;215;7;81m E \e[0m \e[38;2;255;255;255;48;2;230;0;88m B \e[0m \e[38;2;255;255;255;48;2;168;0;45m I \e[0m \e[38;2;255;255;255;48;2;215;7;81m A \e[0m \e[38;2;255;255;255;48;2;230;0;88m N \e[0m\n"
            # /etc/os-release on Debian does NOT have the full point version (VERSION is
            # e.g. just "13 (trixie)"), so we read it from /etc/debian_version (e.g. "13.7")
            # and append VERSION_CODENAME from os-release.
            debian_version_full="$(</etc/debian_version)"
            # Color 168;0;45 is the first Debian square's background (the red tile).
            _print_centered "${debian_version_full} (${VERSION_CODENAME})" "168;0;45"
            unset debian_version_full
            echo
            echo
            ;;
        *)
            padding=$(( ($(tput cols) - 19) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;46;52;64;48;2;163;190;140m N \e[0m \e[38;2;46;52;64;48;2;235;203;139m E \e[0m \e[38;2;46;52;64;48;2;136;192;208m W \e[0m \e[38;2;46;52;64;48;2;129;161;193m O \e[0m \e[38;2;46;52;64;48;2;191;97;106m S \e[0m\n"
            ;;
    esac

    unfunction _print_centered

fi

if [[ -n "$SSH_CONNECTION" && -d /srv/docker-compose ]]; then
    cd /srv/docker-compose/
    lsa
fi
