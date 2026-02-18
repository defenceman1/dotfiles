# --- History ---
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- Vim mode ---
bindkey -v
export KEYTIMEOUT=1

# --- Completion ---
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# --- Useful aliases ---
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -a'
alias ..='cd ..'
alias ...='cd ../..'
alias v='nvim'
alias t='tmux'
alias ta='tmux attach'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias dot='git --git-dir=/home/dm/.dotfiles --work-tree=/home/dm'

# --- Path ---
export EDITOR='nvim'
export VISUAL='nvim'
export PATH=$PATH:/home/dm/.cargo/bin

# --- Starship prompt ---
eval "$(starship init zsh)"

#--- Alias ---
alias vi="nvim"
