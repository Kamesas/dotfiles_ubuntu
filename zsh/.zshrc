# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=( 
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
command -v fastfetch &>/dev/null && fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
if command -v lsd &>/dev/null; then
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
fi

# ============================================================================
# NEOVIM CONFIGURATIONS
# ============================================================================
# LazyVim is the default nvim config
alias v='nvim'
# Minimal/custom Neovim config (for experimentation)
alias n='NVIM_APPNAME="nvim-custom" command nvim'
# Fresh LazyVim instance (parallel to main nvim, for debugging freezes)
alias lv='NVIM_APPNAME="lazyvim" command nvim'
alias lgn='lazygains'

# Default editor (used by Claude Code Ctrl+G, git, etc.)
export EDITOR='nvim'
export VISUAL='nvim'

# ============================================================================
# UTILITY ALIASES
# ============================================================================
# Speed test - simple output
alias sts="speedtest-cli --simple"
# Speed test - full output
alias st="speedtest-cli"
# Ollama - run small gemma model
alias g3s="ollama run gemma3:270m"
# Typing practice
alias t="ttyper"

# Color support for grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ============================================================================
# DATABASE CONNECTIONS (pgcli)
# ============================================================================
alias pgcli-basic='pgcli postgresql://alex:secret@localhost:5432/basic'
alias pgcli-mydb='pgcli postgresql://alex:secret@localhost:5432/mydb'
alias pgcli-so='pgcli postgresql://alex:secret@localhost:5432/stackoverflow'
alias pgcli-p='pgcli postgresql://alex:secret@localhost:5432/postgres'

# ============================================================================
# NVM (Node Version Manager)
# ============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/nvm_completion" ] && \. "$NVM_DIR/nvm_completion"

# ============================================================================
# API KEYS & CLOUD CONFIGURATION
# ============================================================================
# export GOOGLE_CLOUD_PROJECT="gemini-cli-471506"
# Load secrets from ~/.secrets.zsh (not tracked in git)
[ -f ~/.secrets.zsh ] && source ~/.secrets.zsh


# ============================================================================
# PATH MODIFICATIONS
# ============================================================================
export PATH="$PATH:$HOME/.local/bin"
export PATH="/home/alex/.opencode/bin:$PATH"

# ============================================================================
# SHELL ENHANCEMENTS
# ============================================================================
# Starship prompt
eval "$(starship init zsh)"
# Zoxide (better cd command)
eval "$(zoxide init zsh)"
# Rust environment
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ============================================================================
# KEY BINDINGS
# ============================================================================
# Ctrl+Backspace to delete whole word backward
bindkey '^H' backward-kill-word
# Ctrl+Delete to delete whole word forward
bindkey '^[[3;5~' kill-word


# Added by Antigravity CLI installer
export PATH="/home/alex/.local/bin:$PATH"
