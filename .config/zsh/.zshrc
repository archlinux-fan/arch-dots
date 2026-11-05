# ~/.config/zsh/.zshrc (ZDOTDIR is set in ~/.zshenv)
# The settings are in parts in conf.d, read in name order: completion, history,
# options, keys, prompt, aliases (git, pacman, apt, docker), fzf, welcome, server, plugins.
# Each part works on its own, so a server can get one zshrc made of the parts it needs.

# Parts left out, by name without number and .zsh. Change it for one computer in
# ~/.config/zsh/local.zsh (e.g. from a private repo), e.g. zsh_off=(apt docker server welcome)
zsh_off=(apt docker server)
[[ -f $ZDOTDIR/local.zsh ]] && source $ZDOTDIR/local.zsh

for part in $ZDOTDIR/conf.d/*.zsh(N); do
    (( ${zsh_off[(Ie)${${part:t:r}#<->-}]} )) || source $part
done
unset part
