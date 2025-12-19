# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

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
fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# ============================================================================
# NEOVIM CONFIGURATIONS
# ============================================================================
# LazyVim distribution (default 'v' command)
alias v='NVIM_APPNAME="lvim" command nvim'
# Custom Neovim config
alias nv='NVIM_APPNAME="nvim-custom" command nvim'
# Default Neovim (lazy.nvim based)
alias lv='NVIM_APPNAME="nvim" command nvim'

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
export GOOGLE_CLOUD_PROJECT="gemini-cli-471506"
export OPENAI_API_KEY="your-new-api-key-here"

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
. "$HOME/.cargo/env"
