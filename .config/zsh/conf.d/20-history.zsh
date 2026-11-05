# --- History -----------------------------------------------------------------
# ~/.zshenv sets HISTFILE on the desktop; elsewhere (servers, root) it's ~/.histfile.
HISTFILE=${HISTFILE:-$HOME/.histfile}
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY          # Share history between different terminal sessions
setopt APPEND_HISTORY         # Append to history file instead of overwriting
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate commands from history
setopt HIST_SAVE_NO_DUPS      # Do not write duplicate commands to history file
setopt HIST_IGNORE_SPACE      # Don't record commands starting with a space
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history commands
setopt HIST_FIND_NO_DUPS      # Do not display a line previously found during search
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when history is full
