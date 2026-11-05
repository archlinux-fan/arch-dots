# --- Plugins -----------------------------------------------------------------
# Suggestions from history and syntax colors. Last, because syntax highlighting
# must see every widget defined before it. Arch and Debian/Ubuntu paths.
for plugin in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    [ -f "$plugin" ] && source "$plugin"
done
unset plugin
