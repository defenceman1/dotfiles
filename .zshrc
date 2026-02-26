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

# --- Key correction ---
# Fix delete key
bindkey "^[[3~" delete-char

# Fix Ctrl+P / Ctrl+N for history navigation
bindkey "^P" up-history
bindkey "^N" down-history

# Fix Home/End keys
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

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
export PATH=$PATH:/home/dm/.cargo/bin:/home/dm/go/bin

# --- Starship prompt ---
eval "$(starship init zsh)"

#--- Alias ---
alias vi="nvim"

# --- startup ---
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach-session -t default || tmux new-session -s default
fi
