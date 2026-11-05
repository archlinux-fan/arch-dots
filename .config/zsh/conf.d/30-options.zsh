# --- General Behavior --------------------------------------------------------
# Editor for programs that open one (git commit, sudoedit); ~/.zshenv sets it on the desktop
export EDITOR=${EDITOR:-nano} VISUAL=${VISUAL:-nano}

setopt autocd                # cd into directory by typing its name
setopt extendedglob          # Advanced pattern matching
setopt INTERACTIVE_COMMENTS  # Console doesn't reject commands when # is present
setopt nomatch               # Error if no matches found for a pattern
setopt notify                # Instant background job status
unsetopt correct             # No spelling correction of commands (e.g., sl -> ls)
setopt prompt_subst          # Allow functions/variables in prompt
unsetopt beep                # Disable system beep

stty -ixon   # Disable Ctrl+S terminal freeze

# `< file` alone shows the file in the pager
READNULLCMD=${PAGER:-less}
