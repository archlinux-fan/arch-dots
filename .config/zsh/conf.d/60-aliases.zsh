# --- Aliases -----------------------------------------------------------------
alias sudo='sudo '           # aliases work after sudo too

# System
alias jourerr="sudo journalctl -p 3 -b"
alias failed="systemctl --failed"
alias rmc="rm -rf .cache/*"
alias h="history | grep "
alias p='\ps aux | grep '    # \ps: plain ps, not the ps alias below
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
alias ls='ls -F --color=auto'
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
alias -g C="| wl-copy "      # desktop: ... C copies the output
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -a"
alias openports='ss -tulpn'
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
